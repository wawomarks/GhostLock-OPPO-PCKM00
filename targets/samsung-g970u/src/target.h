/* Samsung Galaxy S10e SM-G970U - Kernel 4.14.190 */

#define KERNEL_VERSION_MAJOR 4
#define KERNEL_VERSION_MINOR 14
#define KERNEL_VERSION_PATCH 190

/* Offset Configuration for Linux 4.14.190 (Samsung-specific may vary) */

/* Task structure offsets */
#define INIT_TASK             ((void *)0xffff88800803e000ULL)
#define TASK_TASKS_OFF        0x120

/* Futex operations */
#define FUTEX_WAIT_REQUEUE_PI 17

/* Kallsyms for kernel symbol resolution */
#define KALLSYMS_ADDR         ((void *)0xffff8881004a6000ULL)

/* Security hook offsets */
#define SECURITY_HOOK_HEADS   0x90

/* Kernel memory management (mm_struct) */
#define MM_STRUCT_START       ((void *)0xffff88800b37c000ULL)

/* Kernel memory allocator (kmalloc_caches) */
#define KMALLOC_CACHES        ((void *)0xffff88800b36a000ULL)
#define DIRECT_MAP_BASE       ((void *)0xffff888000000000ULL)
#define DIRECT_MAP_END        ((void *)0xffff888400000000ULL)

/* Kernel image base and load addresses */
#define KIMAGE_TEXT_BASE      0xffffffc008080000ULL
#define P0_KERNEL_PHYS_LOAD   0xffffffc0080a0000ULL
#define P0_PHYS_OFFSET        0x18000

/* Pipe slab allocator offsets (Linux 4.14) */
#define PIPE_OFF              0xc20ULL
#define FOPS_OFF              0xc38ULL

/* Slab page type for pipe slabs (Linux 4.14) */
#define SLAB_TYPES            ((void *)0xffff88800b366000ULL)
#define PAGE_TYPE_SLAB        0xf5

/* Pselect fake lock route configuration */
#define ROUTE_WAIT_SECONDS    8
#define FAKE_TASK_PRIO        120
#define FAKE_WAITER_PRIO      130

/* Kernel memory aliasing */
#define P0_PAGE_OFFSET        ((void *)0xffffffc008146000ULL)

/* Boot ID and sysctl hooks */
#define SLIDE_NFULNL_LOGGER_IMAGE     ((void *)0xffffffc0082f0000ULL)
#define SLIDE_LOGGERS_0_1_IMAGE      ((void *)0xffffffc0082f4000ULL)
#define SLIDE_RANDOM_BOOT_ID_DATA_IMAGE ((void *)0xffffffc008350000ULL)
#define SLIDE_INIT_TASK_IMAGE        ((void *)0xffffffc008354000ULL)
#define SLIDE_ROOT_TASK_GROUP_IMAGE  ((void *)0xffffffc008358000ULL)
#define SLIDE_SYSCTL_BOOTID_IMAGE   ((void *)0xffffffc00835c000ULL)

/* Su daemon and wallpaper injection */
#define SU_DAEMON_PATH    "/data/local/tmp/su_daemon"
#define WALLPAPER_PATH    "/data/local/tmp/wallpaper.so"

/* ADB deployment configuration */
#define DEVICE_MODEL      "SM-G970U"
#define KERNEL_VERSION_STR "4.14.190"

/* Root mode indicators (Magisk-style) */
#define ROOT_INDICATOR_FILE "/data/adb/.ghostlocked"
#define SUPERUSER_BIN_PATH "/system/bin/su"
