// Copyright 2011 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package sync

import (
	"internal/race"
	"sync/atomic"
	"unsafe"
)

// WaitGroup等待goroutine的集合完成。
// 主goroutine调用Add来设置等待的goroutine的数量。然后，每个goroutines运行并在完成后调用Done。
// 同时，等待可以用来阻塞，直到所有goroutine完成。
//
// 首次使用后，不得复制WaitGroup。
type WaitGroup struct {
	noCopy noCopy

	// 64-bit value: 高32位是计数器，低32位是waiter计数。
	// 64位原子操作需要64位对齐，但是32位编译器不能确保对齐。
	// 因此，我们分配了12个字节，然后将其中对齐的8个字节用作状态，并将另外4个字节用于存储信号。
	state1 [3]uint32
}

// state返回指向存储在wg.state1中的state和sema字段的指针。
func (wg *WaitGroup) state() (statep *uint64, semap *uint32) {
	if uintptr(unsafe.Pointer(&wg.state1))%8 == 0 {
		return (*uint64)(unsafe.Pointer(&wg.state1)), &wg.state1[2]
	} else {
		return (*uint64)(unsafe.Pointer(&wg.state1[1])), &wg.state1[0]
	}
}

// Add将可能为负数的增量添加到WaitGroup计数器中。如果计数器变为零，则释放等待时阻塞的所有goroutine。如果计数器变为负数，请添加恐慌。
//
// 请注意，当计数器为零时发生增量为正的调用必须在等待之前发生。可能会在任何时候在计数器大于零时开始以负增量进行调用，或以正增量进行调用。
// 通常，这意味着对Add的调用应在创建等待的goroutine或其他事件之前执行。
// 如果将WaitGroup重用于等待几个独立的事件集，则必须在所有先前的Wait调用返回之后才进行新的Add调用。请参见WaitGroup示例。
func (wg *WaitGroup) Add(delta int) {
	statep, semap := wg.state()
	if race.Enabled {
		_ = *statep // 尽早触发nil deref
		if delta < 0 {
			// 将减量与Wait同步。
			race.ReleaseMerge(unsafe.Pointer(wg))
		}
		race.Disable()
		defer race.Enable()
	}
	state := atomic.AddUint64(statep, uint64(delta)<<32)
	v := int32(state >> 32)
	w := uint32(state)
	if race.Enabled && delta > 0 && v == int32(delta) {
		// 第一个增量必须与Wait同步。需要将此模型建模为读取，因为从0开始可能会有多个并发的wg.counter转换。
		race.Read(unsafe.Pointer(semap))
	}
	if v < 0 {
		panic("sync: negative WaitGroup counter")
	}
	if w != 0 && delta > 0 && v == int32(delta) {
		panic("sync: WaitGroup misuse: Add called concurrently with Wait")
	}
	if v > 0 || w == 0 {
		return
	}
	// 当waiter > 0时，此goroutine已将计数器设置为0。现在不能存在并发的状态突变：-不能与Wait同时发生加法，-如果看到counter ==，
	// 则Wait不会使服务员递增0. 仍然进行廉价的完整性检查以检测WaitGroup的滥用。
	if *statep != state {
		panic("sync: WaitGroup misuse: Add called concurrently with Wait")
	}
	// 重置waiter计数为0。
	*statep = 0
	for ; w != 0; w-- {
		runtime_Semrelease(semap, false, 0)
	}
}

// 完成将WaitGroup计数器减一。
func (wg *WaitGroup) Done() {
	wg.Add(-1)
}

// 等待块，直到WaitGroup计数器为零。
func (wg *WaitGroup) Wait() {
	statep, semap := wg.state()
	if race.Enabled {
		_ = *statep // 尽早触发nil deref
		race.Disable()
	}
	for {
		state := atomic.LoadUint64(statep)
		v := int32(state >> 32)
		w := uint32(state)
		if v == 0 {
			// 计数器为0，无需等待。
			if race.Enabled {
				race.Enable()
				race.Acquire(unsafe.Pointer(wg))
			}
			return
		}
		// Increment waiters count.
		if atomic.CompareAndSwapUint64(statep, state, state+1) {
			if race.Enabled && w == 0 {
				// 等待必须与第一个添加同步。需要将其建模为与Add中的read竞争的写入。
				// 因此，只能对第一个服务员进行写操作，否则并发等待将相互竞争。
				race.Write(unsafe.Pointer(semap))
			}
			runtime_Semacquire(semap)
			if *statep != 0 {
				panic("sync: WaitGroup is reused before previous Wait has returned")
			}
			if race.Enabled {
				race.Enable()
				race.Acquire(unsafe.Pointer(wg))
			}
			return
		}
	}
}
