// Copyright 2009 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package strconv

// ParseBool返回由字符串表示的布尔值。 接受1，t，T，TRUE，true，True，0，f，F，FALSE，false，False。
// 其他任何值都会返回错误。
func ParseBool(str string) (bool, error) {
	switch str {
	case "1", "t", "T", "true", "TRUE", "True":
		return true, nil
	case "0", "f", "F", "false", "FALSE", "False":
		return false, nil
	}
	return false, syntaxError("ParseBool", str)
}

// FormatBool根据b的值返回“ true”或“ false”。
func FormatBool(b bool) string {
	if b {
		return "true"
	}
	return "false"
}

// AppendBool根据b的值将“ true”或“ false”追加到dst并返回扩展缓冲区。
func AppendBool(dst []byte, b bool) []byte {
	if b {
		return append(dst, "true"...)
	}
	return append(dst, "false"...)
}
