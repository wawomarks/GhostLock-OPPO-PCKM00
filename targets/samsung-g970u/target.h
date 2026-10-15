#ifndef TARGET_H
#define TARGET_H

/* Samsung Galaxy S10e SM-G970U - Kernel 4.14.190 */

#define BUILD_VARIANT_LABEL "samsung_g970u_4.14.190"
#define BUILD_FINGERPRINT "samsung/g970u/g970u:10/QP1A.190711.020/G970UXXSF8DXE1:user/release-keys"

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

/* Kernel symbol offsets (relative to KIMAGE_TEXT_BASE) - Samsung S10e 4.14.190 */
#define COMMIT_CREDS_OFF      0x0006b640ULL
#define PREPARE_KERNEL_CRED_OFF 0x0006b9e8ULL
#define OVERRIDE_CREDS_OFF    0x0006b918ULL
#define GET_TASK_CRED_OFF     0x0006b068ULL
#define INIT_TASK_OFF         0x0219df00ULL
#define INIT_UTS_NS_OFF       0x0219dcb8ULL
#define INIT_CRED_OFF         0x021af810ULL
#define INIT_USER_NS_OFF      0x021ae0e0ULL
#define INIT_GROUPS_OFF       0x021af808ULL

/* KASLR / memory layout */
#define MEMSTART_ADDR_OFF     0x01ca2540ULL
#define MODULE_ALLOC_BASE_OFF 0x01ca2520ULL
#define RESERVED_MEM_OFF      0x028d8960ULL
#define EMPTY_ZERO_PAGE_OFF   0x024a9000ULL
#define ROOT_TASK_GROUP_OFF   0x024aff00ULL
#define KPTR_RESTRICT_OFF     0x0219da00ULL
#define SYSCALL_BOOTID_OFF    0x026236c0ULL
#define NFULNL_LOGGER_OFF     0x02193978ULL
#define LOGGERS_0_1_OFF       0x02193978ULL

/* Ashmem (Android) */
#define ASHMEM_MISC_FOPS_OFF  0x017f9fd0ULL
#define ASHMEM_FOPS_OFF       0x017f9fd0ULL
#define ASHMEM_MISC_OFF       0x024115f0ULL
#define ASHMEM_IOCTL_OFF      0x00d0a288ULL
#define ASHMEM_COMPAT_IOCTL_OFF 0x00d0ab68ULL
#define ASHMEM_MMAP_OFF       0x00d0abc0ULL
#define ASHMEM_OPEN_OFF       0x00d0ad30ULL
#define ASHMEM_RELEASE_OFF    0x00d0adb0ULL
#define ASHMEM_READ_ITER_OFF  0x00d0a1c8ULL
#define ASHMEM_LLSEEK_OFF     0x00d0a118ULL

/* file_operations / llseek / splice */
#define NOOP_LLSEEK_OFF       0x0020dff0ULL
#define GENERIC_FILE_LLSEEK_OFF 0x0020dda8ULL
#define GENERIC_FILE_SPLICE_READ_OFF 0x00251d30ULL
#define DEFAULT_FILE_SPLICE_READ_OFF 0x002542d0ULL
#define KERNEL_WRITE_OFF      0x0020ea10ULL
#define FGET_OFF              0x0023a340ULL
#define FPUT_OFF              0x002131a8ULL
#define SYS_IOCTL_OFF         0x00229e48ULL

/* pselect waiter word shift: 4.14 uses 2 (fd_set word layout) */
#define PSELECT_WAITER_WORD_SHIFT 2

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
#define P0_PAGE_OFFSET        0xffffffc008146000ULL

/* Boot ID and sysctl hooks */
#define SLIDE_NFULNL_LOGGER_IMAGE     0xffffffc0082f0000ULL
#define SLIDE_LOGGERS_0_1_IMAGE      0xffffffc0082f4000ULL
#define SLIDE_RANDOM_BOOT_ID_DATA_IMAGE 0xffffffc008350000ULL
#define SLIDE_INIT_TASK_IMAGE        0xffffffc008354000ULL
#define SLIDE_ROOT_TASK_GROUP_IMAGE  0xffffffc008358000ULL
#define SLIDE_SYSCTL_BOOTID_IMAGE   0xffffffc00835c000ULL

/* Su daemon and wallpaper injection */
#define SU_DAEMON_PATH    "/data/local/tmp/su_daemon"
#define WALLPAPER_PATH    "/data/local/tmp/wallpaper.so"

/* ADB deployment configuration */
#define DEVICE_MODEL      "SM-G970U"
#define KERNEL_VERSION_STR "4.14.190"

/* Root mode indicators (Magisk-style) */
#define ROOT_INDICATOR_FILE "/data/adb/.ghostlocked"
#define SUPERUSER_BIN_PATH "/system/bin/su"

#endif /* TARGET_H */
