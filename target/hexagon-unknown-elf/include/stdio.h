#pragma once

#include <stdarg.h>
#include <types.h>

#ifdef __cplusplus
extern "C" {
#endif

int snprintf(char *, size_t, const char *, ...);
int vsnprintf(char *, size_t, const char *, va_list);

#ifdef __cplusplus
}
#endif
