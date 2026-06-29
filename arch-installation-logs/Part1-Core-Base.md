# Phase 1: Bare-Metal Core Bootstrap & Bootloader Resolution

## 1. 🎯 Objective
This log documents the enterprise-grade bootstrap installation of Arch Linux on an `x86_64` architecture within a virtualized hardware environment. The primary objective of this phase is to establish a deep, foundational understanding of low-level system initialization, manual standard storage layout allocation, and POSIX-compliant kernel deployment. By avoiding automated installers, this deployment enforces rigorous, granular control over partitioning, filesystem creation, initialization hooks, and bootloader configuration.

---

## 2. 💻 Commands Executed

### Phase A: Pre-Installation & Storage Subsystem Provisions
In this phase, the live environment volatile memory space was initialized, network synchronization was verified, and the storage block devices were structured using a modern Guid Partition Table (GPT).

1. **Live Environment Mirror Optimization:**
```bash
reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
```

2. **Storage Partitioning via `gdisk` (GPT Explicit):**
Invoked `gdisk /dev/nvme1n1` to partition the non-volatile memory express block storage device into three distinct logical segments:
* **EFI System Partition (ESP):** 512MiB (Hex code `EF00`)
* **Linux Swap Space:** 4GiB (Hex code `8200`)
* **Linux Root Filesystem:** Remaining Capacity (Hex code `8300`)


3. **Filesystem Construction & Format Processing:**
Enforced strict cryptographic/structural layout parameters per partition type:
```bash
mkfs.vfat -F 32 /dev/nvme1n1p1
mkswap /dev/nvme1n1p2
mkfs.xfs -f /dev/nvme1n1p3

```


4. **Target Hierarchy Mounting Topology:**
```bash
mount /dev/nvme1n1p3 /mnt
mount --mkdir /dev/nvme1n1p1 /mnt/boot
swapon /dev/nvme1n1p2

```



---

### Phase B: System Chroot Environment & Base Configuration

This phase abstractly clones the core kernel runtime structures onto the physical block layer and transitions operational scope into the new root layout.

1. **Base Operating System Pacstrapping:**
Deployed the Linux Kernel matrix, firmware packages, base POSIX utilities, and text editors (`nano` explicitly leveraged for runtime edits):
```bash
pacstrap -K /mnt base linux linux-firmware nano networkmanager git amd-ucode

```


2. **Storage Persistence Matrix Generation (`/etc/fstab`):**
Generated persistent mount structures utilizing Universally Unique Identifiers (UUIDs) to mitigate drive order manipulation errors:
```bash
genfstab -U /mnt >> /mnt/etc/fstab

```


3. **Operational Realm Pivot (`arch-chroot`):**
```bash
arch-chroot /mnt

```


4. **Localization and Time-Zone Chronology Synchronization:**
```bash
ln -sf /usr/share/zoneinfo/Asia/Riyadh /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ar_SA.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "arch-pc" > /etc/hostname

```


5. **Bootloader Installation Execution (GRUB UEFI Architecture):**
```bash
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

```


6. **Network System Persistence Provisioning:**
```bash
systemctl enable NetworkManager

```



---

## 3. 📊 Expected Output

### Storage Layer Block Topology Allocation Verification (`lsblk`)

```text
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nvme1n1     259:0    0 476.9G  0 disk 
├─nvme1n1p1 259:1    0   512M  0 part /boot
├─nvme1n1p2 259:2    0     4G  0 part [SWAP]
└─nvme1n1p3 259:3    0 472.4G  0 part /

```

### Filesystem Metadata Structural Runtime Analytics (`df -hT`)

```text
Filesystem     Type      Size  Used Avail Use% Mounted on
/dev/nvme1n1p3 xfs       473G  2.1G  471G   1% /
/dev/nvme1n1p1 vfat      511M   32M  479M   7% /boot

```

### Native Initial Stage Bootloader Execution (First Boot Output)

```text
GRUB loading.
Welcome to GRUB!

Slot 1: Arch Linux, with Linux kernel (Loading initramfs-linux.img...)
[    0.000000] Linux version 6.x.x-arch1-1 (gcc version 14.x.x)
[OK] Started Journal Service.
[OK] Started Network Manager.

arch-pc login:

```

---

## 4. 🛠️ Troubleshooting & Lessons Learned

### Incident Report: Boot Vector Misconfiguration

* **The Error:** Upon execution of the baseline hardware initialization sequencing (Post-Installation Reboot), the environment catastrophically terminated into a passive `grub rescue>` prompt, declaring a failure state in resolving the primary kernel space image or bootloader target UUID.
* **The Root Cause:** A standard execution omission occurred during the system configuration orchestration phase (`Phase B`). While the active binaries for the Grand Unified Bootloader (`GRUB`) were registered successfully inside the EFI System Partition via `grub-install`, the configuration runtime compilation matrix compiler was never invoked. The deployment sequence was exited prior to executing `grub-mkconfig`, leaving a void where `/boot/grub/grub.cfg` should explicitly detail target execution boundaries.
* **The Resolution Matrix:**
1. Intercepted execution pipeline by hot-plugging the active Live ISO installation media.
2. Mounted the target root tree and peripheral ESP paths back into transient positions:
```bash
mount /dev/nvme1n1p3 /mnt
mount /dev/nvme1n1p1 /mnt/boot

```


3. Re-entered the isolation jail framework: `arch-chroot /mnt`
4. Manually recompiled the configuration allocation layout script:
```bash
grub-mkconfig -o /boot/grub/grub.cfg

```


5. Verified successful stdout rendering (`Found linux image: /boot/vmlinuz-linux`), clean unmounted the runtime hierarchies via `umount -R /mnt`, extracted peripheral media, and initiated a warm system reset (`reboot`). Persistence and target boot parameters verified operational.
