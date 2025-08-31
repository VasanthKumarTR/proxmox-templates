#!/bin/bash
# GitHub Self-Hosted Runner setup for Ubuntu 22.04 LXC (Proxmox)
# Supports running Docker inside a privileged LXC with nesting enabled.
# Falls back to Podman (rootless) if Docker cannot run.
#
# This revision allows execution as root (common inside LXC) and will create a
# dedicated non-root user (default: 'runner') automatically for the GitHub Actions runner.
# You can override the username with:  ./setup-runner-lxc.sh --user espresso
# It also self-detects if the script body was replaced by an HTML error page
# (common when a download failed) and aborts with guidance.
set -euo pipefail

GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; BLUE="\e[34m"; NC="\e[0m"
log(){ echo -e "${BLUE}[INFO]${NC} $*"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $*"; }
err(){ echo -e "${RED}[ERR ]${NC} $*"; }
ok(){ echo -e "${GREEN}[ OK ]${NC} $*"; }

# --- HTML / corruption guard ------------------------------------------------------
if head -n1 "$0" | grep -qi '<!DOCTYPE html'; then
  err "This script appears to be an HTML page (bad download)."
  err "Re-download with: curl -L -o setup-runner-lxc.sh https://raw.githubusercontent.com/OWNER/REPO/main/setup-runner-lxc.sh"
  exit 2
fi

# ---- 0. Pre-flight (LXC/Nesting) -------------------------------------------------
log "Detecting LXC environment & nesting support"
if grep -qa container=lxc /proc/1/environ 2>/dev/null || [ -f /run/.containerenv ]; then
  ok "Running inside container (LXC detected)"
else
  warn "Not detected as LXC (continuing anyway)"
fi

# Check nesting (needed for Docker)
if [ -f /proc/1/cgroup ]; then
  if ! grep -q "docker" /proc/filesystems 2>/dev/null; then
    warn "If Docker fails later: Ensure 'nesting=1' feature is enabled for this CT (pct set <CTID> -features nesting=1)"
  fi
fi

# ---- 1. Packages -----------------------------------------------------------------
log "Updating apt indexes"
apt-get update -y

# --- Argument parsing -------------------------------------------------------------
RUNNER_SYSUSER_DEFAULT="runner"
RUNNER_SYSUSER="$RUNNER_SYSUSER_DEFAULT"

while [ $# -gt 0 ]; do
  case "$1" in
    -u|--user)
      RUNNER_SYSUSER="$2"; shift 2;;
    -h|--help)
      echo "Usage: $0 [--user <username>]"; exit 0;;
    *) echo "Unknown argument: $1"; exit 1;;
  esac
done

log "Selected runner user: $RUNNER_SYSUSER"

# --- User / privilege handling ----------------------------------------------------
if [ "${EUID}" -eq 0 ]; then
  if ! id -u "$RUNNER_SYSUSER" >/dev/null 2>&1; then
    log "Creating dedicated user '$RUNNER_SYSUSER'"
    useradd -m -s /bin/bash "$RUNNER_SYSUSER"
  else
    ok "User '$RUNNER_SYSUSER' already exists"
  fi
  SUDO_USER="$RUNNER_SYSUSER"
  HOME_DIR="/home/$RUNNER_SYSUSER"
else
  if [ "$USER" != "$RUNNER_SYSUSER" ]; then
    warn "Script not run as root; will use current user '$USER' instead of requested '$RUNNER_SYSUSER'"
    RUNNER_SYSUSER="$USER"
  fi
  SUDO_USER="$USER"
  HOME_DIR="$HOME"
fi

log "Installing base dependencies"
DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates gnupg lsb-release jq tar sudo git build-essential apt-transport-https software-properties-common uidmap fuse-overlayfs

# ---- 2. Docker (attempt) ---------------------------------------------------------
install_docker(){
  log "Attempting Docker Engine installation"
  if command -v docker >/dev/null 2>&1; then ok "Docker already present"; return 0; fi
  # Prefer upstream; fallback to Ubuntu docker.io if fails
  if install -m 0755 -d /etc/apt/keyrings 2>/dev/null; then
    if curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null; then
      chmod a+r /etc/apt/keyrings/docker.gpg || true
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list
      apt-get update -y || true
      DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || \
        DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io || return 1
    else
      warn "Falling back to docker.io (GPG fetch failed)"
      DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io || return 1
    fi
  fi
  systemctl enable --now docker 2>/dev/null || true
  usermod -aG docker "${SUDO_USER}" || true
  ok "Docker installation attempted"
}

if install_docker; then
  if docker ps >/dev/null 2>&1; then
    ok "Docker is operational"
    ENGINE="docker"
  else
    warn "Docker installed but cannot run (likely cgroup / nesting). Will try Podman."
    ENGINE="podman"
  fi
else
  warn "Docker install failed. Falling back to Podman."
  ENGINE="podman"
fi

# ---- 3. Podman fallback ----------------------------------------------------------
if [ "$ENGINE" = "podman" ]; then
  log "Installing Podman (rootless)"
  DEBIAN_FRONTEND=noninteractive apt-get install -y podman
  # Enable docker alias compat (optional)
  if ! command -v docker >/dev/null 2>&1; then
    ln -sf /usr/bin/podman /usr/local/bin/docker
    warn "Created docker -> podman shim. Some flags may differ; adjust workflow if needed."
  fi
  podman info >/dev/null 2>&1 && ok "Podman operational"
fi

log "Pulling required images (may use docker OR podman)"
${ENGINE} pull docker.io/hashicorp/packer:1.12.0 || ${ENGINE} pull hashicorp/packer:1.12.0
${ENGINE} pull docker.io/hashicorp/terraform:1.9.0 || ${ENGINE} pull hashicorp/terraform:1.9.0

# ---- 4. Runner download ----------------------------------------------------------
RUNNER_BASE="/opt/github-runner"
mkdir -p "$RUNNER_BASE"
chown -R "$SUDO_USER:$SUDO_USER" "$RUNNER_BASE"
cd "$RUNNER_BASE"

if [ ! -f latest.txt ]; then
  RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name | sed 's/^v//')
  echo "$RUNNER_VERSION" > latest.txt
else
  RUNNER_VERSION=$(cat latest.txt)
fi
log "Latest runner version: $RUNNER_VERSION"
TAR="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
if [ ! -f "$TAR" ]; then
  curl -L -o "$TAR" "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${TAR}"
  ok "Downloaded runner archive"
fi
if [ ! -f run.sh ]; then
  tar xzf "$TAR"
  ok "Extracted runner"
fi

# ---- 5. Service setup helper -----------------------------------------------------
cat > /usr/local/bin/register-runner.sh <<'EOF'
#!/bin/bash
set -euo pipefail
if [ $# -lt 3 ]; then
  echo "Usage: register-runner.sh <repo_url> <registration_token> <labels> [name]" >&2
  exit 1
fi
REPO_URL="$1"; TOKEN="$2"; LABELS="$3"; NAME="${4:-lxc-runner-$(hostname)}"
cd /opt/github-runner
RUNNER_USER_PLACEHOLDER="__RUNNER_USER__"
su - "${RUNNER_USER_PLACEHOLDER}" -c "cd /opt/github-runner && ./config.sh --url '$REPO_URL' --token '$TOKEN' --labels '$LABELS' --name '$NAME' --unattended --replace" || exit 1
./svc.sh install || true
./svc.sh start
EOF
chmod +x /usr/local/bin/register-runner.sh
ok "Helper script /usr/local/bin/register-runner.sh created"

# Replace placeholder with actual user
sed -i "s/__RUNNER_USER__/${RUNNER_SYSUSER}/g" /usr/local/bin/register-runner.sh

# ---- 6. Summary ------------------------------------------------------------------
cat <<SUMMARY

${GREEN}✔ Runner base installed${NC}

Next steps:
  1. Generate a registration token in GitHub:
     Repo: Settings > Actions > Runners > New self-hosted runner > Linux x64
  2. Register runner (example):
     sudo register-runner.sh https://github.com/OWNER/REPO YOUR_TOKEN "self-hosted,proxmox,docker" proxmox-lxc-01
  3. Confirm runner shows online in GitHub UI.
  4. Push a change to trigger the workflow.

Engine selected: $ENGINE
If using Podman: consider adjusting workflow to remove '--network host' if unsupported.

Troubleshooting Docker in LXC:
  - Ensure CT is PRIVILEGED.
  - Enable nesting: pct set <CTID> -features nesting=1
  - Mount cgroups: add to CT config ( /etc/pve/lxc/<CTID>.conf ):
        lxc.apparmor.profile: unconfined
        lxc.cap.drop:
        lxc.cgroup2.devices.allow: a
  - Restart container: pct restart <CTID>

To reconfigure runner:
  cd /opt/github-runner && sudo ./svc.sh stop && sudo -u runner ./config.sh remove && sudo ./svc.sh uninstall

SUMMARY
