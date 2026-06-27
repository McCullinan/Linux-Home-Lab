Markdown
# Phase 2: Display Server, Desktop Environment, & NVIDIA Graphics Pipeline Integration

## 1. 🎯 Objective
This log details the post-installation deployment of the graphical subsystem on Arch Linux, specifically configuring the **KDE Plasma Display Environment** alongside the proprietary **NVIDIA Linux Driver Matrix** for an **NVIDIA RTX 2070**. The objective is to achieve a stable, low-latency Display Server pipeline (Wayland/X11 compatibility), eliminate software-fallback rendering loops, enforce direct GPU Kernel Mode Setting (KMS), and optimize power/performance profiles via hardware acceleration layers.

---

## 2. 💻 Commands Executed

### Phase A: Package Repositories Sync & Core GUI Provisions
This stage involved bypassing un-synced package mirrors, unblocking 32-bit architectural dependencies, and pulling the core graphics stack binaries.

1. **Explicit Multi-Architecture Enablement (`/etc/pacman.conf`):**
   Uncommented the `[multilib]` repository definitions to allow the downloading of 32-bit compatibility libraries required by proprietary graphics drivers.

2. **Upstream Repository Override (Manual Mirror Routing):**
   Forced pacman to sync with the primary global Arch Linux mirror array to circumvent transient mirror sync errors:
   ```bash
   echo "Server = [https://geo.mirror.pkgbuild.com/](https://geo.mirror.pkgbuild.com/)\$repo/os/\$arch" | sudo tee /etc/pacman.d/mirrorlist
Graphics Stack & Desktop Environment Bootstrap:
Synchronized package databases and deployed the full display ecosystem:

Bash
sudo pacman -Syyu --needed nvidia nvidia-utils lib32-nvidia-utils nvidia-settings plasma sddm konsole dolphin
Phase B: Kernel Module Configuration & Environment Variables
Configured the Linux kernel (initramfs) to load graphics drivers at the earliest stage of initialization to handle advanced Wayland display protocols cleanly.

Early Kernel Mode Setting (KMS) Implementation:
Edited /etc/mkinitcpio.conf to hook NVIDIA kernel modules explicitly into the initial RAM disk image:

Plaintext
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
Regenerated the kernel initial ramdisk images matrix:

Bash
sudo mkinitcpio -P
DRM Kernel Module Parameter Tuning:
Created /etc/modprobe.d/nvidia.conf to enforce Direct Rendering Manager (DRM) modesetting and configure optimal power management clocks:

Plaintext
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_RegistryDwords="PowerMizerEnable=0x1; PowerMizerDefaultAC=0x1; PerfLevelSrc=0x2222; PowerMizerDefault=0x3"
options nvidia_drm modeset=1
System-Wide Environment Variables Routing (/etc/environment):
Appended strict instructions to force hardware rendering pathways across the compositor:

Plaintext
KWIN_DRM_USE_EGL_STREAMS=1
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
Display Manager Daemon Persistence:

Bash
sudo systemctl enable sddm
3. 📊 Expected Output
NVIDIA Kernel Module & State Verification (nvidia-smi)
Plaintext
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 555.x.x              Driver Version: 555.x.x      CUDA Version: 12.x         |
|-----------------------------------------+------------------------+----------------------+
| ID  Name                        Persistence| Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |          Memory-Usage  | GPU-Util  Compute M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 2070        Off | 00000000:01:00.0    On |                  N/A |
| N/A   42C    P8              16W / 175W |    180MiB /  8192MiB |     2%      Default |
+-----------------------------------------+------------------------+----------------------+
Compositor Resource Footprint Post-Optimization (top / htop)
Plaintext
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
 1042 hameed    20   0 3421504 185420 112400 S   1.3   1.1   0:04.12 kwin_wayland
4. 🛠️ Troubleshooting & Lessons Learned
Incident Report: Hardware Acceleration Bypass & Compositor CPU Bottlenecking
The Error: Upon booting into the newly provisioned KDE Plasma environment under the Wayland protocol, system performance degraded significantly. System diagnostics revealed that the window manager process (kwin_wayland) was consuming up to 95% of available CPU resources, while the hardware graphics processing unit registered 0% utilization.

The Root Cause: The display server environment failed to discover a functional hardware rendering acceleration API path because the kernel lacked explicit DRM modesetting variables, and the compositor was missing core environmental indicators (GBM_BACKEND, __GLX_VENDOR_LIBRARY_NAME). This caused the system to fall back automatically to standard Software-Fallback Rendering (LLVMpipe), forcing the central processing unit to manually calculate every graphical element, window movement, and pixel redraw.

The Resolution Matrix:

Isolated the driver mismatch by running nvidia-smi to ensure hardware kernels were physically mapped.

Implemented Early KMS by inserting the proper hardware driver array (nvidia, nvidia_modeset, nvidia_uvm, nvidia_drm) directly inside /etc/mkinitcpio.conf and updating the ramdisk blocks via sudo mkinitcpio -P.

Formulated explicit flags inside /etc/environment to bind the compositor to the NVIDIA hardware backends (nvidia-drm).

Executed a clean system hardware cycle reset (reboot). Upon graphical session re-initialization, kwin_wayland CPU overhead dropped from 95% to <2%, and processing loads successfully shifted entirely onto the RTX 2070 GPU hardware pipelines.
