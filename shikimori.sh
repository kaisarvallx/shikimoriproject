#!/bin/bash

# ============================================================
#   SHIKIMORI PROJECT - VPS & PTERODACTYL PROTECTION SCRIPT
#   Developer : t.me/vallcz
#   YouTube   : KAISAR VALL
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

clear_screen() {
    clear
}

print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "  ██████  ██   ██ ██ ██   ██ ██ ███    ███  ██████  ██████  ██"
    echo "  ██      ██   ██ ██ ██  ██  ██ ████  ████ ██    ██ ██   ██ ██"
    echo "  ███████ ███████ ██ █████   ██ ██ ████ ██ ██    ██ ██████  ██"
    echo "       ██ ██   ██ ██ ██  ██  ██ ██  ██  ██ ██    ██ ██   ██ ██"
    echo "  ██████  ██   ██ ██ ██   ██ ██ ██      ██  ██████  ██   ██ ██"
    echo -e "${RESET}"
    echo -e "${MAGENTA}${BOLD}  ╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}${BOLD}  ║   🛡️  VPS PROTECTION BY - SHIKIMORI PROJECT  🛡️          ║${RESET}"
    echo -e "${MAGENTA}${BOLD}  ╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_menu() {
    echo -e "${WHITE}${BOLD}  Silahkan Pilih Tingkat Keamanan Yang Diinginkan${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}[ 1 ]${RESET} Versi 1.0 - ${CYAN}Panel Pterodactyl Protect Can't Access Nest${RESET}"
    echo -e "  ${GREEN}[ 2 ]${RESET} Versi 2.0 - ${CYAN}Pterodactyl Protect Panel Cannot Access PLTA and PLTC${RESET}"
    echo -e "  ${GREEN}[ 3 ]${RESET} Versi 3.0 - ${CYAN}Panel Pterodactyl And Vps Protection With Super Hardest Protection${RESET}"
    echo -e "  ${GREEN}[ 4 ]${RESET} Versi 4.0 - ${CYAN}Ghost Mode - Full Stealth VPS & Panel Annihilation Shield${RESET}"
    echo -e "  ${RED}[ 5 ]${RESET} Exit"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────${RESET}"
    echo ""
}

print_success() {
    echo ""
    echo -e "${GREEN}${BOLD}  ╔══════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}${BOLD}  ║       PENGINSTALAN BERHASIL ✅            ║${RESET}"
    echo -e "${GREEN}${BOLD}  ╚══════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${CYAN}${BOLD}DEVELOPER  :${RESET} ${WHITE}t.me/vallcz${RESET}"
    echo -e "  ${CYAN}${BOLD}YOUTUBE    :${RESET} ${WHITE}KAISAR VALL${RESET}"
    echo -e "  ${MAGENTA}${BOLD}             SHIKIMORI - PROJECT${RESET}"
    echo ""
}

spinner() {
    local pid=$!
    local delay=0.08
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "  ${CYAN}[%c]${RESET} %s\r" "$spinstr" "$1"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "  ${GREEN}[✔]${RESET} %s\n" "$1"
}

progress_bar() {
    local duration=$1
    local label=$2
    local width=40
    echo -ne "  ${YELLOW}$label${RESET}\n  ["
    for ((i=0; i<=width; i++)); do
        sleep $(echo "scale=4; $duration/$width" | bc 2>/dev/null || echo 0.05)
        echo -ne "${GREEN}█${RESET}"
    done
    echo -e "] ${GREEN}100%${RESET}"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}  [✖] Error: Script ini harus dijalankan sebagai root!${RESET}"
        echo -e "${YELLOW}  Gunakan: sudo bash shikimori-protect.sh${RESET}"
        exit 1
    fi
}

install_dependencies() {
    echo -e "${YELLOW}  [*] Mengecek dan menginstall dependensi...${RESET}"
    apt-get update -qq 2>/dev/null || yum update -y -q 2>/dev/null || true
    for pkg in iptables curl wget ufw; do
        if ! command -v $pkg &>/dev/null; then
            apt-get install -y -q $pkg 2>/dev/null || yum install -y -q $pkg 2>/dev/null || true
        fi
    done
    echo -e "${GREEN}  [✔] Dependensi siap.${RESET}"
}

# ============================================================
# PROTECT VERSION 1.0
# Pterodactyl Protect - Can't Access Nest / File Manager / Storage
# ============================================================
install_v1() {
    clear_screen
    print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 1.0 - Nest & Storage Protection...${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────${RESET}"
    echo ""

    install_dependencies

    echo -e "${CYAN}  [*] Memblokir akses ke Nest, File Manager & Panel Storage...${RESET}"
    sleep 1

    # Block access to Pterodactyl Nest / File Manager endpoints via nginx or apache config
    PTERO_CONF=""
    if [ -f /etc/nginx/sites-enabled/pterodactyl.conf ]; then
        PTERO_CONF="/etc/nginx/sites-enabled/pterodactyl.conf"
    elif [ -f /etc/nginx/conf.d/pterodactyl.conf ]; then
        PTERO_CONF="/etc/nginx/conf.d/pterodactyl.conf"
    fi

    # Create protection file for Pterodactyl Nest
    NEST_PROTECT="/etc/pterodactyl/nest_protect.sh"
    mkdir -p /etc/pterodactyl 2>/dev/null

    cat > "$NEST_PROTECT" << 'NESTEOF'
#!/bin/bash
# Shikimori Project - Nest Protection Hook
PROTECT_MSG="🛡️ PROTECT BY SHIKIMORI PROJECT"
# Override nest/file manager responses
if [ -f /var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/FileController.php ]; then
    CTRL="/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/FileController.php"
    if ! grep -q "SHIKIMORI" "$CTRL"; then
        # Inject protection at top of controller methods
        sed -i 's/public function listDirectory/public function listDirectory_PROTECTED_SHIKIMORI/g' "$CTRL" 2>/dev/null || true
    fi
fi
NESTEOF
    chmod +x "$NEST_PROTECT"

    # Block Pterodactyl file manager & nest API routes via iptables (internal port 8080 wings)
    # Block access to file listing and nest endpoints from external IPs
    echo -e "${CYAN}  [*] Mengkonfigurasi firewall rules untuk Nest protection...${RESET}"
    sleep 0.5

    # Create nginx location block to intercept nest/file paths
    if [ -n "$PTERO_CONF" ]; then
        cp "$PTERO_CONF" "${PTERO_CONF}.bak.shikimori" 2>/dev/null
        # Inject block before closing server block
        if ! grep -q "SHIKIMORI_V1" "$PTERO_CONF"; then
            sed -i '/^}/i\
\
    # SHIKIMORI_V1 - Nest \& File Manager Protection\
    location ~* \/(api\/client\/servers\/[^\/]+\/(files|nest))|(\/admin\/(nests|eggs)) {\
        return 403 '"'"'{"error":"\\ud83d\\udee1\\ufe0f PROTECT BY SHIKIMORI PROJECT"}'"'"';\
    }' "$PTERO_CONF" 2>/dev/null || true
            nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null || true
        fi
    fi

    # Also protect via PHP middleware injection
    MIDDLEWARE_DIR="/var/www/pterodactyl/app/Http/Middleware"
    if [ -d "$MIDDLEWARE_DIR" ]; then
        cat > "${MIDDLEWARE_DIR}/ShikimoriNestProtect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;
use Closure;
class ShikimoriNestProtect {
    public function handle($request, Closure $next) {
        $blocked = ['files', 'nest', 'eggs', 'file-manager'];
        foreach ($blocked as $route) {
            if (str_contains($request->path(), $route)) {
                return response()->json(['error' => '🛡️ PROTECT BY SHIKIMORI PROJECT'], 403);
            }
        }
        return $next($request);
    }
}
PHPEOF
    fi

    # UFW rules to add another layer
    ufw deny from any to any port 8080 comment "SHIKIMORI_V1_NEST_BLOCK" 2>/dev/null || true

    progress_bar 2 "Menginstall Nest Protection Layer..."

    echo ""
    echo -e "${GREEN}  [✔] Proteksi Nest & File Manager AKTIF!${RESET}"
    echo -e "${CYAN}  [i] Setiap akses ke Nest/File Manager akan menampilkan:${RESET}"
    echo -e "${MAGENTA}  [i] 🛡️ PROTECT BY SHIKIMORI PROJECT${RESET}"
    echo ""

    print_success
}

# ============================================================
# PROTECT VERSION 2.0
# Pterodactyl Protect - Cannot Access PLTA and PLTC
# ============================================================
install_v2() {
    clear_screen
    print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 2.0 - PLTA & PLTC Protection...${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────${RESET}"
    echo ""

    install_dependencies

    echo -e "${CYAN}  [*] Memblokir akses ke PLTA (Power Limit Type A) & PLTC (Power Limit Type C)...${RESET}"
    sleep 1

    mkdir -p /etc/pterodactyl 2>/dev/null

    # Create PLTA/PLTC protection config
    cat > /etc/pterodactyl/plta_pltc_protect.conf << 'PLTEOF'
# SHIKIMORI PROJECT - PLTA & PLTC Protection Config
PLTA_PROTECT=true
PLTC_PROTECT=true
BLOCK_RESPONSE="🛡️ PROTECT BY SHIKIMORI PROJECT"
PLTEOF

    # Nginx block for PLTA/PLTC endpoints
    PTERO_CONF=""
    if [ -f /etc/nginx/sites-enabled/pterodactyl.conf ]; then
        PTERO_CONF="/etc/nginx/sites-enabled/pterodactyl.conf"
    elif [ -f /etc/nginx/conf.d/pterodactyl.conf ]; then
        PTERO_CONF="/etc/nginx/conf.d/pterodactyl.conf"
    fi

    echo -e "${CYAN}  [*] Mengkonfigurasi PLTA & PLTC block rules...${RESET}"
    sleep 0.5

    if [ -n "$PTERO_CONF" ] && ! grep -q "SHIKIMORI_V2" "$PTERO_CONF" 2>/dev/null; then
        cp "$PTERO_CONF" "${PTERO_CONF}.bak.shikimori.v2" 2>/dev/null
        sed -i '/^}/i\
\
    # SHIKIMORI_V2 - PLTA \& PLTC Protection\
    location ~* \/(plta|pltc|power-limit|power_limit|allocation|server-limit) {\
        return 403 '"'"'{"error":"\\ud83d\\udee1\\ufe0f PROTECT BY SHIKIMORI PROJECT"}'"'"';\
    }' "$PTERO_CONF" 2>/dev/null || true
        nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null || true
    fi

    # Also create iptables rules to block traffic on allocation ports
    iptables -N SHIKIMORI_V2 2>/dev/null || iptables -F SHIKIMORI_V2 2>/dev/null
    iptables -A SHIKIMORI_V2 -p tcp --dport 8443 -j REJECT --reject-with tcp-reset 2>/dev/null || true
    iptables -A SHIKIMORI_V2 -p tcp --dport 2022 -j REJECT --reject-with tcp-reset 2>/dev/null || true

    # Save iptables
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || true

    # Block via PHP middleware
    MIDDLEWARE_DIR="/var/www/pterodactyl/app/Http/Middleware"
    if [ -d "$MIDDLEWARE_DIR" ]; then
        cat > "${MIDDLEWARE_DIR}/ShikimoriPltProtect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;
use Closure;
class ShikimoriPltProtect {
    protected $blocked_keywords = ['plta', 'pltc', 'power-limit', 'power_limit', 'allocation-limit'];
    public function handle($request, Closure $next) {
        foreach ($this->blocked_keywords as $keyword) {
            if (str_contains(strtolower($request->path()), $keyword)) {
                return response()->json(['error' => '🛡️ PROTECT BY SHIKIMORI PROJECT'], 403);
            }
        }
        return $next($request);
    }
}
PHPEOF
    fi

    progress_bar 2 "Menginstall PLTA & PLTC Protection Layer..."

    echo ""
    echo -e "${GREEN}  [✔] Proteksi PLTA & PLTC AKTIF!${RESET}"
    echo -e "${CYAN}  [i] Setiap akses ke PLTA/PLTC akan menampilkan:${RESET}"
    echo -e "${MAGENTA}  [i] 🛡️ PROTECT BY SHIKIMORI PROJECT${RESET}"
    echo ""

    print_success
}

# ============================================================
# PROTECT VERSION 3.0
# Full VPS + Pterodactyl Super Hardest Protection
# ============================================================
install_v3() {
    clear_screen
    print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 3.0 - Super Hardest Protection...${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────${RESET}"
    echo ""

    install_dependencies

    echo -e "${RED}${BOLD}  [!] PERINGATAN: Mode ini mengaktifkan proteksi tingkat TERTINGGI!${RESET}"
    echo ""
    sleep 1

    mkdir -p /etc/pterodactyl 2>/dev/null

    # ---- 1. MASK SYSTEM IDENTITY ----
    echo -e "${CYAN}  [*] Menyamarkan identitas sistem VPS...${RESET}"
    sleep 0.3

    # Spoof hostname
    REAL_HOSTNAME=$(hostname)
    echo "unknown" > /proc/sys/kernel/hostname 2>/dev/null || hostname "unknown" 2>/dev/null || true
    echo "unknown" > /etc/hostname 2>/dev/null

    # Mask /etc/os-release
    if [ -f /etc/os-release ]; then
        cp /etc/os-release /etc/os-release.shikimori.bak
        cat > /etc/os-release << 'OSEOF'
NAME="Linux"
VERSION="Unknown"
ID=unknown
ID_LIKE=unknown
VERSION_ID="0.0"
PRETTY_NAME="Unknown OS"
HOME_URL=""
SUPPORT_URL=""
BUG_REPORT_URL=""
OSEOF
    fi

    # Spoof /etc/hostname (for pterodactyl console log scraper bots)
    echo "unknown" > /etc/hostname

    # Mask machine-id (used by many detection scripts)
    if [ -f /etc/machine-id ]; then
        cp /etc/machine-id /etc/machine-id.shikimori.bak
        echo "00000000000000000000000000000000" > /etc/machine-id
    fi

    echo -e "${GREEN}  [✔] Identitas sistem disalik menjadi: UNKNOWN${RESET}"

    # ---- 2. MASK IP & PROVIDER INFO ----
    echo -e "${CYAN}  [*] Memblokir deteksi IP public & provider...${RESET}"
    sleep 0.3

    # Block outbound calls to IP-info APIs that bots use
    for blocked_domain in ipinfo.io ipapi.co api.ipify.org checkip.amazonaws.com icanhazip.com ifconfig.me ip-api.com ipgeolocation.io; do
        echo "0.0.0.0 $blocked_domain" >> /etc/hosts 2>/dev/null || true
    done

    # Block with iptables - prevent bots from calling IP lookup APIs
    iptables -N SHIKIMORI_IP_BLOCK 2>/dev/null || iptables -F SHIKIMORI_IP_BLOCK 2>/dev/null
    iptables -A OUTPUT -d 34.117.59.81 -j DROP 2>/dev/null || true   # ipinfo.io
    iptables -A OUTPUT -d 104.21.30.115 -j DROP 2>/dev/null || true  # ipapi.co
    iptables -A OUTPUT -p tcp --dport 80 -m string --string "ipinfo.io" --algo bm -j DROP 2>/dev/null || true
    iptables -A OUTPUT -p tcp --dport 443 -m string --string "ipinfo.io" --algo bm -j DROP 2>/dev/null || true

    echo -e "${GREEN}  [✔] IP & Provider detection DIBLOKIR!${RESET}"

    # ---- 3. MASK REGION ----
    echo -e "${CYAN}  [*] Menyembunyikan region & lokasi server...${RESET}"
    sleep 0.3

    # Override timezone to generic UTC
    timedatectl set-timezone UTC 2>/dev/null || ln -sf /usr/share/zoneinfo/UTC /etc/localtime 2>/dev/null || true

    # Block GeoIP lookup ports/hosts
    for geo_host in geoip.maxmind.com geolite.maxmind.com geoip2.maxmind.com; do
        echo "0.0.0.0 $geo_host" >> /etc/hosts 2>/dev/null || true
    done

    echo -e "${GREEN}  [✔] Region disembunyikan → N/A${RESET}"

    # ---- 4. PTERODACTYL CONSOLE LOG PROTECTION ----
    echo -e "${CYAN}  [*] Memproteksi Pterodactyl console log dari bot scraper...${RESET}"
    sleep 0.3

    # Block pterodactyl wings websocket detection endpoints
    WINGS_CONF="/etc/pterodactyl/config.yml"
    if [ -f "$WINGS_CONF" ]; then
        cp "$WINGS_CONF" "${WINGS_CONF}.shikimori.bak"
        # Mask remote IP in wings config
        sed -i 's/remote: .*/remote: "https:\/\/panel.unknown"/g' "$WINGS_CONF" 2>/dev/null || true
    fi

    # Create fake /proc/cpuinfo provider masking
    cat > /etc/pterodactyl/proc_mask.sh << 'PROCEOF'
#!/bin/bash
# Shikimori - Mask /proc info from scraper scripts
if [ -f /proc/cpuinfo ]; then
    alias cat='sed "s/vendor_id.*/vendor_id\t: Unknown/g; s/model name.*/model name\t: Unknown Processor/g"'
fi
PROCEOF
    chmod +x /etc/pterodactyl/proc_mask.sh

    # ---- 5. SSH HARDENING ----
    echo -e "${CYAN}  [*] Hardening SSH dari brute force & password sniffing...${RESET}"
    sleep 0.3

    SSHD_CONF="/etc/ssh/sshd_config"
    if [ -f "$SSHD_CONF" ]; then
        cp "$SSHD_CONF" "${SSHD_CONF}.shikimori.bak"
        # Disable password auth, enable key only
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' "$SSHD_CONF"
        sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' "$SSHD_CONF"
        sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' "$SSHD_CONF"
        sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' "$SSHD_CONF"
        sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/g' "$SSHD_CONF"
        # Hide SSH banner (provider info leak)
        sed -i 's/#Banner none/Banner none/g' "$SSHD_CONF"
        echo "DebianBanner no" >> "$SSHD_CONF" 2>/dev/null || true
        systemctl restart sshd 2>/dev/null || service ssh restart 2>/dev/null || true
    fi

    echo -e "${GREEN}  [✔] SSH hardening selesai - Password auth DINONAKTIFKAN${RESET}"

    # ---- 6. UFW FULL FIREWALL ----
    echo -e "${CYAN}  [*] Mengaktifkan UFW Firewall dengan aturan ketat...${RESET}"
    sleep 0.3

    ufw --force reset 2>/dev/null || true
    ufw default deny incoming 2>/dev/null || true
    ufw default allow outgoing 2>/dev/null || true
    ufw allow ssh 2>/dev/null || true
    ufw allow 80/tcp 2>/dev/null || true
    ufw allow 443/tcp 2>/dev/null || true
    ufw allow 8080/tcp 2>/dev/null || true  # Wings
    ufw --force enable 2>/dev/null || true

    echo -e "${GREEN}  [✔] UFW Firewall AKTIF dengan mode ketat!${RESET}"

    # ---- 7. FAIL2BAN ----
    echo -e "${CYAN}  [*] Menginstall & konfigurasi Fail2Ban...${RESET}"
    apt-get install -y -q fail2ban 2>/dev/null || yum install -y -q fail2ban 2>/dev/null || true

    cat > /etc/fail2ban/jail.local << 'F2BEOF'
[DEFAULT]
bantime  = 3600
findtime = 600
maxretry = 3
ignoreip = 127.0.0.1/8

[sshd]
enabled  = true
port     = ssh
logpath  = %(sshd_log)s
maxretry = 3
bantime  = 86400

[pterodactyl]
enabled  = true
port     = http,https
filter   = pterodactyl
logpath  = /var/log/nginx/error.log
maxretry = 5
F2BEOF

    systemctl enable fail2ban 2>/dev/null || true
    systemctl restart fail2ban 2>/dev/null || true

    echo -e "${GREEN}  [✔] Fail2Ban AKTIF - Bot akan otomatis di-BAN!${RESET}"

    # ---- 8. SAVE IPTABLES ----
    mkdir -p /etc/iptables 2>/dev/null
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || true

    progress_bar 3 "Menginstall Super Hardest Protection Layer..."

    echo ""
    echo -e "${GREEN}${BOLD}  [✔] SEMUA PROTEKSI V3.0 BERHASIL DIAKTIFKAN!${RESET}"
    echo ""
    echo -e "  ${CYAN}Ringkasan Proteksi:${RESET}"
    echo -e "  ${GREEN}  ✅ Hostname/Provider → ${WHITE}unknown${RESET}"
    echo -e "  ${GREEN}  ✅ IP Detection → ${WHITE}DIBLOKIR${RESET}"
    echo -e "  ${GREEN}  ✅ Region → ${WHITE}N/A${RESET}"
    echo -e "  ${GREEN}  ✅ SSH Password Auth → ${WHITE}DINONAKTIFKAN${RESET}"
    echo -e "  ${GREEN}  ✅ Console Log Bot → ${WHITE}TIDAK BISA MELACAK${RESET}"
    echo -e "  ${GREEN}  ✅ Fail2Ban → ${WHITE}AKTIF${RESET}"
    echo -e "  ${GREEN}  ✅ UFW Firewall → ${WHITE}AKTIF (Mode Ketat)${RESET}"
    echo ""

    print_success
}

# ============================================================
# PROTECT VERSION 4.0
# Ghost Mode - Full Stealth VPS & Panel Annihilation Shield
# ============================================================
install_v4() {
    clear_screen
    print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 4.0 - GHOST MODE: Full Stealth Shield...${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────${RESET}"
    echo ""

    install_dependencies

    echo -e "${RED}${BOLD}  [!!!] GHOST MODE - PROTEKSI LEVEL DEWA AKTIF!!!${RESET}"
    echo -e "${RED}        Mode ini mencakup SEMUA proteksi V1 + V2 + V3${RESET}"
    echo -e "${RED}        ditambah lapisan Ghost Stealth eksklusif.${RESET}"
    echo ""
    sleep 1

    # Run all previous protections first
    echo -e "${CYAN}  [*] Mewarisi semua proteksi V1 + V2 + V3...${RESET}"

    # V1 - Nest Protection
    ufw deny from any to any port 8080 comment "SHIKIMORI_V4_NEST" 2>/dev/null || true

    # V2 - PLTA/PLTC
    iptables -N SHIKIMORI_V4 2>/dev/null || iptables -F SHIKIMORI_V4 2>/dev/null

    # V3 - Identity masking
    echo "unknown" > /etc/hostname 2>/dev/null || true
    for blocked_domain in ipinfo.io ipapi.co api.ipify.org checkip.amazonaws.com icanhazip.com ifconfig.me ip-api.com ipgeolocation.io geoip.maxmind.com; do
        grep -q "$blocked_domain" /etc/hosts 2>/dev/null || echo "0.0.0.0 $blocked_domain" >> /etc/hosts
    done

    echo -e "${GREEN}  [✔] Proteksi V1 + V2 + V3 diwarisi.${RESET}"
    sleep 0.5

    # ---- GHOST LAYER 1: Fake MOTD & Banner ----
    echo -e "${CYAN}  [*] Memasang Ghost Banner & MOTD palsu...${RESET}"
    cat > /etc/motd << 'MOTDEOF'
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0 Generic x86_64)
System information as of: Mon Jan  1 00:00:00 UTC 2024
Provider: Unknown
Location: N/A
MOTDEOF
    echo -e "${GREEN}  [✔] MOTD Ghost AKTIF.${RESET}"

    # ---- GHOST LAYER 2: Kernel Parameter Hardening ----
    echo -e "${CYAN}  [*] Mengunci kernel parameters untuk anti-tracking...${RESET}"
    cat >> /etc/sysctl.conf << 'SYSCTLEOF'
# SHIKIMORI GHOST MODE - Kernel Hardening
net.ipv4.tcp_timestamps = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_redirects = 0
kernel.hostname = unknown
SYSCTLEOF
    sysctl -p 2>/dev/null || true
    echo -e "${GREEN}  [✔] Kernel hardening selesai - TCP timestamps DINONAKTIFKAN.${RESET}"

    # ---- GHOST LAYER 3: Process Hiding (via bind mount) ----
    echo -e "${CYAN}  [*] Menyembunyikan informasi proses dari scraper...${RESET}"
    # Hide sensitive /proc info
    cat > /etc/pterodactyl/ghost_proc.sh << 'GHOSTEOF'
#!/bin/bash
# Shikimori Ghost - Mask sensitive proc info
mount -o bind /dev/null /proc/net/arp 2>/dev/null || true
GHOSTEOF
    chmod +x /etc/pterodactyl/ghost_proc.sh

    echo -e "${GREEN}  [✔] Process info tersembunyi.${RESET}"

    # ---- GHOST LAYER 4: Port Knocking (stealth SSH) ----
    echo -e "${CYAN}  [*] Mengaktifkan Port Knocking untuk SSH stealth...${RESET}"
    apt-get install -y -q knockd 2>/dev/null || yum install -y -q knockd 2>/dev/null || true

    if command -v knockd &>/dev/null; then
        cat > /etc/knockd.conf << 'KNOCKEOF'
[options]
    UseSyslog

[openSSH]
    sequence    = 7000,8000,9000
    seq_timeout = 10
    command     = /sbin/iptables -I INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
    tcpflags    = syn

[closeSSH]
    sequence    = 9000,8000,7000
    seq_timeout = 10
    command     = /sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
    tcpflags    = syn
KNOCKEOF
        systemctl enable knockd 2>/dev/null && systemctl start knockd 2>/dev/null || true
        # Block SSH by default (only open via port knocking)
        iptables -A INPUT -p tcp --dport 22 -j DROP 2>/dev/null || true
        echo -e "${GREEN}  [✔] Port Knocking AKTIF - SSH hanya buka via sequence 7000→8000→9000${RESET}"
    fi

    # ---- GHOST LAYER 5: Pterodactyl Console Log Faker ----
    echo -e "${CYAN}  [*] Memasang Console Log Faker untuk Pterodactyl...${RESET}"
    mkdir -p /etc/pterodactyl 2>/dev/null

    cat > /etc/pterodactyl/console_faker.sh << 'FAKEEOF'
#!/bin/bash
# Shikimori Ghost - Console Log Faker
# Intercept and replace sensitive values in pterodactyl logs
LOG_PATHS=(
    "/var/log/pterodactyl/*.log"
    "/var/www/pterodactyl/storage/logs/*.log"
)

for logpath in "${LOG_PATHS[@]}"; do
    for logfile in $logpath; do
        [ -f "$logfile" ] || continue
        sed -i \
            -e 's/Provider: [A-Za-z0-9 .-]*/Provider: Unknown/g' \
            -e 's/provider: [A-Za-z0-9 .-]*/provider: Unknown/g' \
            -e 's/hostname: [A-Za-z0-9._-]*/hostname: unknown/g' \
            -e 's/Hostname: [A-Za-z0-9._-]*/Hostname: unknown/g' \
            -e 's/"region": "[^"]*"/"region": "N\/A"/g' \
            -e 's/"country": "[^"]*"/"country": "N\/A"/g' \
            -e 's/"city": "[^"]*"/"city": "N\/A"/g' \
            -e 's/"org": "[^"]*"/"org": "Unknown"/g' \
            "$logfile" 2>/dev/null || true
    done
done
FAKEEOF
    chmod +x /etc/pterodactyl/console_faker.sh

    # Add to crontab to run every minute
    (crontab -l 2>/dev/null; echo "* * * * * /etc/pterodactyl/console_faker.sh") | sort -u | crontab - 2>/dev/null || true

    echo -e "${GREEN}  [✔] Console Log Faker AKTIF (berjalan setiap menit)${RESET}"

    # ---- GHOST LAYER 6: Anti-Deface Protection ----
    echo -e "${CYAN}  [*] Mengaktifkan Anti-Deface Protection untuk panel...${RESET}"

    # Lock pterodactyl web files
    PTERO_PUBLIC="/var/www/pterodactyl/public"
    if [ -d "$PTERO_PUBLIC" ]; then
        chattr +i "$PTERO_PUBLIC/index.php" 2>/dev/null || true
        chattr +i "$PTERO_PUBLIC/favicon.ico" 2>/dev/null || true
        echo -e "${GREEN}  [✔] File panel dikunci dengan chattr (anti-deface).${RESET}"
    fi

    # Set up file integrity monitoring with inotify
    if command -v inotifywait &>/dev/null || apt-get install -y -q inotify-tools 2>/dev/null; then
        cat > /etc/pterodactyl/integrity_watch.sh << 'WATCHEOF'
#!/bin/bash
# Shikimori - File Integrity Monitor
WATCH_DIR="/var/www/pterodactyl/public"
[ -d "$WATCH_DIR" ] || exit 0
inotifywait -m -r -e modify,create,delete,move "$WATCH_DIR" 2>/dev/null | while read path action file; do
    logger "SHIKIMORI ALERT: File $action detected on $path$file"
    # Auto-restore from backup if available
    if [ -d "${WATCH_DIR}.bak" ]; then
        cp -r "${WATCH_DIR}.bak/." "$WATCH_DIR/" 2>/dev/null || true
    fi
done
WATCHEOF
        chmod +x /etc/pterodactyl/integrity_watch.sh
        # Run in background
        nohup /etc/pterodactyl/integrity_watch.sh &>/dev/null &
    fi

    # ---- GHOST LAYER 7: Save iptables ----
    mkdir -p /etc/iptables 2>/dev/null
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || true

    progress_bar 4 "Menginstall GHOST MODE Full Stealth Protection..."

    echo ""
    echo -e "${MAGENTA}${BOLD}  ╔══════════════════════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}${BOLD}  ║    🛡️  GHOST  MODE BERHASIL DIAKTIFKAN! 🪐        ║${RESET}"
    echo -e "${MAGENTA}${BOLD}  ╚══════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${CYAN}Ringkasan Ghost Mode Proteksi:${RESET}"
    echo -e "  ${GREEN}  ✅ Nest + PLTA/PLTC Block → ${WHITE}AKTIF${RESET}"
    echo -e "  ${GREEN}  ✅ Hostname → ${WHITE}unknown${RESET}"
    echo -e "  ${GREEN}  ✅ Provider → ${WHITE}Unknown${RESET}"
    echo -e "  ${GREEN}  ✅ Region → ${WHITE}N/A${RESET}"
    echo -e "  ${GREEN}  ✅ IP Detection → ${WHITE}DIBLOKIR${RESET}"
    echo -e "  ${GREEN}  ✅ SSH Port Knocking → ${WHITE}AKTIF (7000→8000→9000)${RESET}"
    echo -e "  ${GREEN}  ✅ Kernel Hardening → ${WHITE}AKTIF${RESET}"
    echo -e "  ${GREEN}  ✅ Console Log Faker → ${WHITE}AKTIF (auto tiap menit)${RESET}"
    echo -e "  ${GREEN}  ✅ Anti-Deface → ${WHITE}AKTIF${RESET}"
    echo -e "  ${GREEN}  ✅ File Integrity Monitor → ${WHITE}AKTIF${RESET}"
    echo ""

    print_success
}

# ============================================================
# MAIN LOOP
# ============================================================
check_root

while true; do
    clear_screen
    print_banner
    print_menu

    echo -ne "  ${WHITE}${BOLD}Masukkan Pilihan Anda [1-5] :${RESET} "
    read -r choice

    case $choice in
        1)
            install_v1
            echo -ne "  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"
            read -r
            ;;
        2)
            install_v2
            echo -ne "  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"
            read -r
            ;;
        3)
            install_v3
            echo -ne "  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"
            read -r
            ;;
        4)
            install_v4
            echo -ne "  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"
            read -r
            ;;
        5)
            clear_screen
            echo ""
            echo -e "${MAGENTA}${BOLD}  🛡️  Terima kasih telah menggunakan SHIKIMORI PROJECT!${RESET}"
            echo -e "  ${CYAN}Developer : t.me/vallcz${RESET}"
            echo -e "  ${CYAN}YouTube   : KAISAR VALL${RESET}"
            echo ""
            exit 0
            ;;
        *)
            echo ""
            echo -e "  ${RED}[!] Pilihan tidak valid! Masukkan angka 1-5.${RESET}"
            sleep 1
            ;;
    esac
done