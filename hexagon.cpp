#include <hexagon_types.h>
#include <remote.h>
#include <stdlib.h>
#include "qurt.h"
#include "hexagon.h"

int hexagon_open(const char *uri, remote_handle64 *handle) {
    void *tptr = NULL;
    tptr = (void *)malloc(1);
    *handle = (remote_handle64)tptr;
    return 0;
}

int hexagon_close(remote_handle64 handle) {
    if (handle) free((void *)handle);
    return 0;
}

int hexagon_info(remote_handle64 _h, 
                 unsigned int* arch, 
                 unsigned int* units, 
                 unsigned int* thread,
                 unsigned int* version) {
    qurt_arch_version_t arch_info = {};
    qurt_sysenv_get_arch_version(&arch_info);

    qurt_sysenv_max_hthreads_t thread_info = {};
    if (qurt_sysenv_get_max_hw_threads(&thread_info) != QURT_EOK) {
        thread_info.max_hthreads = 4;
    }

    (*arch) = arch_info.arch_version;
    (*units) = qurt_hvx_get_units();
    (*thread) = thread_info.max_hthreads;
    (*version) = qurt_api_version();

    return 0;    
}
