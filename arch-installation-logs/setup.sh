#!/usr/bin/env bash

# ==============================================================================
# 🛠️ ARCH LINUX POST-INSTALLATION AUTOMATION SCRIPT (setup.sh)
# 🚀 Phase 3: Idempotent Systems Provisioning Matrix
# ==============================================================================

# Exit immediately if a command exits with a non-zero status,
# if an undefined variable is referenced, or if a piped command fails.
set -euo pipefail

# ------------------------------------------------------------------------------
# 🟢 ENVIRONMENTAL CONTEXT & LOGGING CONSTANTS
# ------------------------------------------------------------------------------
readonly LOG_FILE="/var/log/arch_post_install.log"
readonly TARGET_MIRROR="https://geo.mirror.pkgbuild.com/\$repo/os/\$arch"

# ANSI Terminal Color Escapes
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'

log_info()    { echo -e "${BLUE}[INFO]${NC}  $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $1" | tee -a "$LOG_FILE"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE" >&2; }

# ------------------------------------------------------------------------------
# 🛡️ PRE-FLIGHT PRIVILEGE & ARCHITECTURE CHECKS
# ------------------------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    log_error "This orchestration script must be executed with root privileges (sudo)."
    exit 1
fi

log_info "Initializing production-grade post-installation automation lifecycle..."
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# ------------------------------------------------------------------------------
# 📦 STEP 1: PACMAN REPOSITORY REALIGNMENT & MULTILIB PROVISIONS
# ------------------------------------------------------------------------------
log_info "Configuring pacman system boundaries and mirror routing..."

# Idempotently inject upstream global geo-mirror pool
if ! grep -q "geo.mirror.pkgbuild.com" /etc/pacman.d/mirrorlist; then
    log_info "Injecting verified upstream geo-mirror array targets..."
    echo "Server = $TARGET_MIRROR" |安全_tee=/etc/pacman.d/mirrorlist
fi

# Idempotently enable the multilib repository structure
if grep -q "#\[multilib\]" /etc/pacman.conf; then
    log_info "Unlinking 32-bit multilib dependency array closures..."
    sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
fi

log_info "Forcing database synchronization and filesystem upgrades..."
pacman -Syyu --noconfirm

# ------------------------------------------------------------------------------
# 🖥️ STEP 2: METROPOLIS CORE GUI & COMPOSITOR PROVISIONS
# ------------------------------------------------------------------------------
log_info "Deploying target X11/Wayland display server and KDE Plasma dependencies..."

readonly CORE_PACKAGES=(
    # Display Server & Workspace Ecosystem
    "plasma" "sddm" "konsole" "dolphin"
    # Audio Subsystem Array (PipeWire Protocol)
    "pipewire" "pipewire-alsa" "pipewire-pulse" "pipewire-jack" "wireplumber"
    # Essential Tooling Utilities
    "git" "base-devel" "fastfetch" "htop" "ufw"
)

pacman -S --needed --noconfirm "${CORE_PACKAGES[@]}"

# ------------------------------------------------------------------------------
# 🏎️ STEP 3: PROPRIETARY NVIDIA GRAPHICS PIPELINE INTEGRATION
# ------------------------------------------------------------------------------
log_info "Injecting monolithic NVIDIA driver matrices (RTX 2070 Specific)..."

readonly NVIDIA_PACKAGES=(
    "nvidia" "nvidia-utils" "lib32-nvidia-utils" 
    "nvidia-settings" "opencl-nvidia"
)

pacman -S --needed --noconfirm "${NVIDIA_PACKAGES[@]}"

# Idempotently configure Early Kernel Mode Setting (KMS) modules
if [ -f /etc/mkinitcpio.conf ]; then
    log_info "Auditing Linux kernel RAM disk image directives..."
    if ! grep -q "nvidia nvidia_modeset" /etc/mkinitcpio.conf; then
        sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
        log_info "Regenerating active initramfs binary trees..."
        mkinitcpio -P
    fi
fi

# Idempotently inject hardware acceleration kernel parameters
readonly MODPROBE_CONF="/etc/modprobe.d/nvidia.conf"
if [ ! -f "$MODPROBE_CONF" ] || ! grep -q "nvidia_drm modeset=1" "$MODPROBE_CONF"; then
    log_info "Enforcing DRM modesetting and PowerMizer clock parameters..."
    cat << EOF > "$MODPROBE_CONF"
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_RegistryDwords="PowerMizerEnable=0x1; PowerMizerDefaultAC=0x1; PerfLevelSrc=0x2222; PowerMizerDefault=0x3"
options nvidia_drm modeset=1
EOF
fi

# ------------------------------------------------------------------------------
# ⚙️ STEP 4: ENVIRONMENT COMPOSITOR STRATIFICATION
# ------------------------------------------------------------------------------
log_info "Binding the window manager compositor directly to hardware layers..."

readonly ENV_CONF="/etc/environment"
readonly INTENDED_ENV_FLAGS=(
    "KWIN_DRM_USE_EGL_STREAMS=1"
    "GBM_BACKEND=nvidia-drm"
    "__GLX_VENDOR_LIBRARY_NAME=nvidia"
)

for flag in "${INTENDED_ENV_FLAGS[@]}"; do
    if ! grep -q "$flag" "$ENV_CONF"; then
        echo "$flag" >> "$ENV_CONF"
    fi
done

# ------------------------------------------------------------------------------
# 🔒 STEP 5: SECURITY PROFILE & SYSTEM DAEMON SCHEDULING
# ------------------------------------------------------------------------------
log_info "Configuring system services and local firewall zones..."

# Enable Core Infrastructure Daemons
systemctl enable sddm.service
systemctl enable NetworkManager.service

# Initialize firewall profiles
if systemctl is-active --quiet ufw; then
    log_warn "UFW daemon active. Resetting standard profiles..."
else
    systemctl enable ufw.service
    systemctl start ufw.service
fi
ufw default deny incoming
ufw default allow outgoing
ufw limit ssh
ufw --force enable

# ------------------------------------------------------------------------------
# 🏁 PIPELINE CLOSURE & SYSTEM HEALTH VERIFICATION
# ------------------------------------------------------------------------------
log_success "Automation runtime completed cleanly without execution state drift."
log_warn "A system restart is required to mount the NVIDIA kernel frames and launch SDDM."
echo -e "\n${YELLOW}[ACTION REQUIRED]${NC} Execute: sudo reboot"
