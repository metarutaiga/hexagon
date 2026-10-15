#pragma once

#include <types.h>

#ifdef __cplusplus
extern "C" {
#endif

#define NULL 0

void free(void *);
void *malloc(size_t);
void *memalign(size_t, size_t);

#ifdef __cplusplus
}
#endif
