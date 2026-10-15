#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include "qurt/qurt_error.h"
#include "qurt/qurt_hvx.h"

// qurt_event
/*architecture version information type*/
typedef struct qurt_sysenv_arch_version {
   /** @cond */
    unsigned int arch_version; /*architecture version*/
    /** @endcond */
}qurt_arch_version_t;

/*maximum hardware threads information type*/
typedef struct qurt_sysenv_max_hthreads {
   /** @cond */
   unsigned int max_hthreads; /*maximum number of hardware threads*/
   /** @endcond */
}qurt_sysenv_max_hthreads_t;

int qurt_sysenv_get_arch_version(qurt_arch_version_t *vers);
int qurt_sysenv_get_max_hw_threads(qurt_sysenv_max_hthreads_t *mhwt);

// qurt_thread
unsigned int qurt_api_version(void);

#ifdef __cplusplus
}
#endif
