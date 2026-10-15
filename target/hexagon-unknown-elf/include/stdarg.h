#pragma once

#ifdef __cplusplus
extern "C" {
#endif

typedef __builtin_va_list va_list;

#define va_arg(v, t)   __builtin_va_arg(v, t)
#define va_copy(d, s)  __builtin_va_copy(d, s)
#define va_end(v)      __builtin_va_end(v)
#define va_start(v, a) __builtin_va_start(v, a)

#ifdef __cplusplus
}
#endif
