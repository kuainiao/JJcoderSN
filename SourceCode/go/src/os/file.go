// Copyright 2009 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// 软件包os为操作系统功能提供了平台无关的接口。设计类似于Unix，尽管错误处理类似于 Go。
// 失败的调用返回错误类型而不是错误编号的值。通常，错误中会提供更多信息。例如，如果调用某个文件名的调用失败，
// 例如Open或Stat，则错误将在打印时包含失败的文件名，并且类型为*PathError，可以将其解压缩以获取更多信息。
//
// os接口旨在在所有操作系统上保持统一。通常不可用的功能出现在系统特定的软件包syscall中。
// 这是一个简单的示例，打开一个文件并读取其中的一些文件。
//
//	file, err := os.Open("file.go") // 用于读取访问
//	if err != nil {
//		log.Fatal(err)
//	}
//
// 如果打开失败，错误字符串将是不言自明的，例如打开file.go：没有这样的文件或目录然后可以将文件的数据读取为一个字节片。
// 读取和写入从参数切片的长度中获取字节数。
//
//	data := make([]byte, 100)
//	count, err := file.Read(data)
//	if err != nil {
//		log.Fatal(err)
//	}
//	fmt.Printf("read %d bytes: %q\n", count, data[:count])
//
// 注意：对文件的最大并行操作数可能受操作系统或系统的限制。该数字应该很高，但超过该数字可能会降低性能或引起其他问题。
//
package os

import (
	"errors"
	"internal/poll"
	"internal/testlog"
	"io"
	"runtime"
	"syscall"
	"time"
)

// 名称返回显示给“Open”的文件名。
func (f *File) Name() string { return f.name }

// Stdin，Stdout和Stderr是打开的文件，它们指向标准输入，标准输出和标准错误文件描述符。
//
// 请注意，Go运行时会为恐慌和崩溃写入标准错误；关闭Stderr可能会使这些消息转到其他地方，也许到达以后打开的文件。
var (
	Stdin  = NewFile(uintptr(syscall.Stdin), "/dev/stdin")
	Stdout = NewFile(uintptr(syscall.Stdout), "/dev/stdout")
	Stderr = NewFile(uintptr(syscall.Stderr), "/dev/stderr")
)

// OpenFile的标志包装了基础系统的标志。并非所有标志都可以在给定的系统上实现。
const (
	// 必须指定O_RDONLY，O_WRONLY或O_RDWR之一。
	O_RDONLY int = syscall.O_RDONLY // 以只读方式打开文件。
	O_WRONLY int = syscall.O_WRONLY // 打开文件只写。
	O_RDWR   int = syscall.O_RDWR   // 以读写方式打开文件。
	// 剩余的值可以被控制以控制行为。
	O_APPEND int = syscall.O_APPEND // 写入时将数据追加到文件中。
	O_CREATE int = syscall.O_CREAT  // 如果不存在，请创建一个新文件。
	O_EXCL   int = syscall.O_EXCL   // 与O_CREATE一起使用时，文件必须不存在。
	O_SYNC   int = syscall.O_SYNC   // 为同步I / O打开。
	O_TRUNC  int = syscall.O_TRUNC  // 打开时截断常规可写文件。
)

// Seek whence values.
//
// 不推荐使用：使用io.SeekStart，io.SeekCurrent和io.SeekEnd。
const (
	SEEK_SET int = 0 // 相对于文件的原点查找
	SEEK_CUR int = 1 // 相对于当前偏移量的搜索
	SEEK_END int = 2 // 相对于终点寻求
)

// LinkError记录链接或符号链接或重命名系统调用期间的错误，以及引起该错误的路径。
type LinkError struct {
	Op  string
	Old string
	New string
	Err error
}

func (e *LinkError) Error() string {
	return e.Op + " " + e.Old + " " + e.New + ": " + e.Err.Error()
}

func (e *LinkError) Unwrap() error {
	return e.Err
}

// Read:从文件中读取多达len（b）个字节。返回读取的字节数和遇到的任何错误。在文件末尾，Read返回0，即io.EOF。
func (f *File) Read(b []byte) (n int, err error) {
	if err := f.checkValid("read"); err != nil {
		return 0, err
	}
	n, e := f.read(b)
	return n, f.wrapErr("read", e)
}

// ReadAt:从字节偏移量开始从文件读取len（b）个字节。返回读取的字节数和错误（如果有）。
// 当n <len（b）时，ReadAt总是返回非nil错误。在文件末尾，该错误是io.EOF。
func (f *File) ReadAt(b []byte, off int64) (n int, err error) {
	if err := f.checkValid("read"); err != nil {
		return 0, err
	}

	if off < 0 {
		return 0, &PathError{"readat", f.name, errors.New("negative offset")}
	}

	for len(b) > 0 {
		m, e := f.pread(b, off)
		if e != nil {
			err = f.wrapErr("read", e)
			break
		}
		n += m
		b = b[m:]
		off += int64(m)
	}
	return
}

// Write将len（b）个字节写入文件。返回写入的字节数和错误（如果有）。 当n！= len（b）时，Write返回一个非nil错误。
func (f *File) Write(b []byte) (n int, err error) {
	if err := f.checkValid("write"); err != nil {
		return 0, err
	}
	n, e := f.write(b)
	if n < 0 {
		n = 0
	}
	if n != len(b) {
		err = io.ErrShortWrite
	}

	epipecheck(f, e)

	if e != nil {
		err = f.wrapErr("write", e)
	}

	return n, err
}

var errWriteAtInAppendMode = errors.New("os: invalid use of WriteAt on file opened with O_APPEND")

// WriteAt从字节偏移量开始将len（b）字节写入文件。返回写入的字节数和错误（如果有）。
// 当n！= len（b）时，WriteAt返回非nil错误。如果使用O_APPEND标志打开了文件，则WriteAt返回错误。
func (f *File) WriteAt(b []byte, off int64) (n int, err error) {
	if err := f.checkValid("write"); err != nil {
		return 0, err
	}
	if f.appendMode {
		return 0, errWriteAtInAppendMode
	}

	if off < 0 {
		return 0, &PathError{"writeat", f.name, errors.New("negative offset")}
	}

	for len(b) > 0 {
		m, e := f.pwrite(b, off)
		if e != nil {
			err = f.wrapErr("write", e)
			break
		}
		n += m
		b = b[m:]
		off += int64(m)
	}
	return
}

// Seek 将下一个文件上读或写的偏移量设置为偏移量，
// 根据whence解释： 0表示相对于文件的原点，1表示相对于当前偏移量，2表示相对于末尾。
// 返回新的偏移量和错误（如果有）。 未指定使用O_APPEND打开的文件的Seek行为。
func (f *File) Seek(offset int64, whence int) (ret int64, err error) {
	if err := f.checkValid("seek"); err != nil {
		return 0, err
	}
	r, e := f.seek(offset, whence)
	if e == nil && f.dirinfo != nil && r != 0 {
		e = syscall.EISDIR
	}
	if e != nil {
		return 0, f.wrapErr("seek", e)
	}
	return r, nil
}

// WriteString类似于Write，但是写入字符串s的内容，而不是字节切片。
func (f *File) WriteString(s string) (n int, err error) {
	return f.Write([]byte(s))
}

// Mkdir使用指定的名称和权限位（在umask之前）创建一个新目录。如果有错误，它将是* PathError类型。
func Mkdir(name string, perm FileMode) error {
	if runtime.GOOS == "windows" && isWindowsNulName(name) {
		return &PathError{"mkdir", name, syscall.ENOTDIR}
	}
	e := syscall.Mkdir(fixLongPath(name), syscallMode(perm))

	if e != nil {
		return &PathError{"mkdir", name, e}
	}

	// mkdir（2）本身不会处理* BSD和Solaris上的粘性位
	if !supportsCreateWithStickyBit && perm&ModeSticky != 0 {
		e = setStickyBit(name)

		if e != nil {
			Remove(name)
			return e
		}
	}

	return nil
}

// setStickyBit将ModeSticky添加到非原子路径的权限位。
func setStickyBit(name string) error {
	fi, err := Stat(name)
	if err != nil {
		return err
	}
	return Chmod(name, fi.Mode()|ModeSticky)
}

// Chdir将当前工作目录更改为命名目录。如果有错误，它将是*PathError类型。
func Chdir(dir string) error {
	if e := syscall.Chdir(dir); e != nil {
		testlog.Open(dir) // observe likely non-existent directory
		return &PathError{"chdir", dir, e}
	}
	if log := testlog.Logger(); log != nil {
		wd, err := Getwd()
		if err == nil {
			log.Chdir(wd)
		}
	}
	return nil
}

// Open 打开命名文件以供读取。如果成功，则可以使用返回文件上的方法进行读取；关联的文件描述符的模式为O_RDONLY。
// 如果有错误，它将是*PathError类型。
func Open(name string) (*File, error) {
	return OpenFile(name, O_RDONLY, 0)
}

// Create 创建或截断命名文件。如果文件已经存在，将被截断。如果文件不存在，则使用模式0666 创建（在umask之前）。
// 如果成功，则可以将返回的File上的方法用于I/O；关联的文件描述符的模式为O_RDWR。如果有错误，它将是* PathError类型。
func Create(name string) (*File, error) {
	return OpenFile(name, O_RDWR|O_CREATE|O_TRUNC, 0666)
}

// OpenFile是广义的open调用；大多数用户将使用Open或Create代替。它打开带有指定标志的命名文件（O_RDONLY等）。
// 如果文件不存在，并且传递了O_CREATE标志，则使用模式perm（在umask之前）创建文件。
// 如果成功，返回文件的方法可以用于I/O。如果有错误，它将是* PathError类型。
func OpenFile(name string, flag int, perm FileMode) (*File, error) {
	testlog.Open(name)
	f, err := openFileNolog(name, flag, perm)
	if err != nil {
		return nil, err
	}
	f.appendMode = flag&O_APPEND != 0

	return f, nil
}

// lstat在测试中被覆盖。
var lstat = Lstat

// Rename 重命名（移动）旧路径为新路径。如果newpath已经存在并且不是目录，则使用重命名替换它。
// 当oldpath和newpath位于不同目录中时，可能会应用特定于操作系统的限制。如果有错误，它将是*LinkError类型。
func Rename(oldpath, newpath string) error {
	return rename(oldpath, newpath)
}

// 软件包syscall中的许多函数返回的计数是-1而不是0。使用fixCount（call（））而不是call（）可以更正计数。
func fixCount(n int, err error) (int, error) {
	if n < 0 {
		n = 0
	}
	return n, err
}

// wrapErr包装在打开文件操作期间发生的错误。
// 它将io.EOF保持不变，否则将poll.ErrFileClosing转换为ErrClosed并将错误包装在PathError中。
func (f *File) wrapErr(op string, err error) error {
	if err == nil || err == io.EOF {
		return err
	}
	if err == poll.ErrFileClosing {
		err = ErrClosed
	}
	return &PathError{op, f.name, err}
}

// TempDir returns the default directory to use for temporary files.
//
// On Unix systems, it returns $TMPDIR if non-empty, else /tmp.
// On Windows, it uses GetTempPath, returning the first non-empty
// value from %TMP%, %TEMP%, %USERPROFILE%, or the Windows directory.
// On Plan 9, it returns /tmp.
//
// The directory is neither guaranteed to exist nor have accessible
// permissions.
func TempDir() string {
	return tempDir()
}

// UserCacheDir returns the default root directory to use for user-specific
// cached data. Users should create their own application-specific subdirectory
// within this one and use that.
//
// On Unix systems, it returns $XDG_CACHE_HOME as specified by
// https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html if
// non-empty, else $HOME/.cache.
// On Darwin, it returns $HOME/Library/Caches.
// On Windows, it returns %LocalAppData%.
// On Plan 9, it returns $home/lib/cache.
//
// If the location cannot be determined (for example, $HOME is not defined),
// then it will return an error.
func UserCacheDir() (string, error) {
	var dir string

	switch runtime.GOOS {
	case "windows":
		dir = Getenv("LocalAppData")
		if dir == "" {
			return "", errors.New("%LocalAppData% is not defined")
		}

	case "darwin":
		dir = Getenv("HOME")
		if dir == "" {
			return "", errors.New("$HOME is not defined")
		}
		dir += "/Library/Caches"

	case "plan9":
		dir = Getenv("home")
		if dir == "" {
			return "", errors.New("$home is not defined")
		}
		dir += "/lib/cache"

	default: // Unix
		dir = Getenv("XDG_CACHE_HOME")
		if dir == "" {
			dir = Getenv("HOME")
			if dir == "" {
				return "", errors.New("neither $XDG_CACHE_HOME nor $HOME are defined")
			}
			dir += "/.cache"
		}
	}

	return dir, nil
}

// UserConfigDir returns the default root directory to use for user-specific
// configuration data. Users should create their own application-specific
// subdirectory within this one and use that.
//
// On Unix systems, it returns $XDG_CONFIG_HOME as specified by
// https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html if
// non-empty, else $HOME/.config.
// On Darwin, it returns $HOME/Library/Application Support.
// On Windows, it returns %AppData%.
// On Plan 9, it returns $home/lib.
//
// If the location cannot be determined (for example, $HOME is not defined),
// then it will return an error.
func UserConfigDir() (string, error) {
	var dir string

	switch runtime.GOOS {
	case "windows":
		dir = Getenv("AppData")
		if dir == "" {
			return "", errors.New("%AppData% is not defined")
		}

	case "darwin":
		dir = Getenv("HOME")
		if dir == "" {
			return "", errors.New("$HOME is not defined")
		}
		dir += "/Library/Application Support"

	case "plan9":
		dir = Getenv("home")
		if dir == "" {
			return "", errors.New("$home is not defined")
		}
		dir += "/lib"

	default: // Unix
		dir = Getenv("XDG_CONFIG_HOME")
		if dir == "" {
			dir = Getenv("HOME")
			if dir == "" {
				return "", errors.New("neither $XDG_CONFIG_HOME nor $HOME are defined")
			}
			dir += "/.config"
		}
	}

	return dir, nil
}

// UserHomeDir returns the current user's home directory.
//
// On Unix, including macOS, it returns the $HOME environment variable.
// On Windows, it returns %USERPROFILE%.
// On Plan 9, it returns the $home environment variable.
func UserHomeDir() (string, error) {
	env, enverr := "HOME", "$HOME"
	switch runtime.GOOS {
	case "windows":
		env, enverr = "USERPROFILE", "%userprofile%"
	case "plan9":
		env, enverr = "home", "$home"
	}
	if v := Getenv(env); v != "" {
		return v, nil
	}
	// On some geese the home directory is not always defined.
	switch runtime.GOOS {
	case "android":
		return "/sdcard", nil
	case "darwin":
		if runtime.GOARCH == "arm" || runtime.GOARCH == "arm64" {
			return "/", nil
		}
	}
	return "", errors.New(enverr + " is not defined")
}

// Chmod changes the mode of the named file to mode.
// If the file is a symbolic link, it changes the mode of the link's target.
// If there is an error, it will be of type *PathError.
//
// A different subset of the mode bits are used, depending on the
// operating system.
//
// On Unix, the mode's permission bits, ModeSetuid, ModeSetgid, and
// ModeSticky are used.
//
// On Windows, only the 0200 bit (owner writable) of mode is used; it
// controls whether the file's read-only attribute is set or cleared.
// The other bits are currently unused. For compatibility with Go 1.12
// and earlier, use a non-zero mode. Use mode 0400 for a read-only
// file and 0600 for a readable+writable file.
//
// On Plan 9, the mode's permission bits, ModeAppend, ModeExclusive,
// and ModeTemporary are used.
func Chmod(name string, mode FileMode) error { return chmod(name, mode) }

// Chmod changes the mode of the file to mode.
// If there is an error, it will be of type *PathError.
func (f *File) Chmod(mode FileMode) error { return f.chmod(mode) }

// SetDeadline sets the read and write deadlines for a File.
// It is equivalent to calling both SetReadDeadline and SetWriteDeadline.
//
// Only some kinds of files support setting a deadline. Calls to SetDeadline
// for files that do not support deadlines will return ErrNoDeadline.
// On most systems ordinary files do not support deadlines, but pipes do.
//
// A deadline is an absolute time after which I/O operations fail with an
// error instead of blocking. The deadline applies to all future and pending
// I/O, not just the immediately following call to Read or Write.
// After a deadline has been exceeded, the connection can be refreshed
// by setting a deadline in the future.
//
// An error returned after a timeout fails will implement the
// Timeout method, and calling the Timeout method will return true.
// The PathError and SyscallError types implement the Timeout method.
// In general, call IsTimeout to test whether an error indicates a timeout.
//
// An idle timeout can be implemented by repeatedly extending
// the deadline after successful Read or Write calls.
//
// A zero value for t means I/O operations will not time out.
func (f *File) SetDeadline(t time.Time) error {
	return f.setDeadline(t)
}

// SetReadDeadline sets the deadline for future Read calls and any
// currently-blocked Read call.
// A zero value for t means Read will not time out.
// Not all files support setting deadlines; see SetDeadline.
func (f *File) SetReadDeadline(t time.Time) error {
	return f.setReadDeadline(t)
}

// SetWriteDeadline sets the deadline for any future Write calls and any
// currently-blocked Write call.
// Even if Write times out, it may return n > 0, indicating that
// some of the data was successfully written.
// A zero value for t means Write will not time out.
// Not all files support setting deadlines; see SetDeadline.
func (f *File) SetWriteDeadline(t time.Time) error {
	return f.setWriteDeadline(t)
}

// SyscallConn returns a raw file.
// This implements the syscall.Conn interface.
func (f *File) SyscallConn() (syscall.RawConn, error) {
	if err := f.checkValid("SyscallConn"); err != nil {
		return nil, err
	}
	return newRawConn(f)
}

// isWindowsNulName reports whether name is os.DevNull ('NUL') on Windows.
// True is returned if name is 'NUL' whatever the case.
func isWindowsNulName(name string) bool {
	if len(name) != 3 {
		return false
	}
	if name[0] != 'n' && name[0] != 'N' {
		return false
	}
	if name[1] != 'u' && name[1] != 'U' {
		return false
	}
	if name[2] != 'l' && name[2] != 'L' {
		return false
	}
	return true
}
