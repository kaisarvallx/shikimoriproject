#!/bin/bash

# ============================================================
#   SHIKIMORI PROJECT - VPS & PTERODACTYL PROTECTION
#   Developer : t.me/vallcz | YouTube : KAISAR VALL
#   Target    : Ubuntu 22.04 + Nginx + Pterodactyl
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

PTERO_DIR="/var/www/pterodactyl"
NGINX_CONF=""

# ============================================================
# HELPERS
# ============================================================

clear_screen() { clear; }

print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "  ░██████╗██╗░░██╗██╗██╗░░██╗██╗███╗░░░███╗░█████╗░██████╗░██╗"
    echo "  ██╔════╝██║░░██║██║██║░██╔╝██║████╗░████║██╔══██╗██╔══██╗██║"
    echo "  ╚█████╗░███████║██║█████╔╝░██║██╔████╔██║██║░░██║██████╔╝██║"
    echo "  ░╚═══██╗██╔══██║██║██╔═██╗░██║██║╚██╔╝██║██║░░██║██╔══██╗██║"
    echo "  ██████╔╝██║░░██║██║██║░╚██╗██║██║░╚═╝░██║╚█████╔╝██║░░██║██║"
    echo "  ╚═════╝░╚═╝░░╚═╝╚═╝╚═╝░░╚═╝╚═╝╚═╝░░░╚═╝░╚════╝░╚═╝░░╚═╝╚═╝"
    echo -e "${RESET}"
    echo -e "${MAGENTA}${BOLD}  ╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}${BOLD}  ║      🛡️  VPS PROTECTION BY - SHIKIMORI PROJECT  🛡️            ║${RESET}"
    echo -e "${MAGENTA}${BOLD}  ╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_menu() {
    echo -e "${WHITE}${BOLD}  Silahkan Pilih Tingkat Keamanan Yang Diinginkan${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}[ 1 ]${RESET} Versi 1.0 - ${CYAN}Panel Pterodactyl Protect Can't Access Nest${RESET}"
    echo -e "  ${GREEN}[ 2 ]${RESET} Versi 2.0 - ${CYAN}Pterodactyl Protect Panel Cannot Access PLTA and PLTC${RESET}"
    echo -e "  ${GREEN}[ 3 ]${RESET} Versi 3.0 - ${CYAN}Panel Pterodactyl And Vps Protection With Super Hardest Protection${RESET}"
    echo -e "  ${GREEN}[ 4 ]${RESET} Versi 4.0 - ${CYAN}Shikimori Mode - Full Stealth VPS & Panel Annihilation Shield${RESET}"
    echo -e "  ${RED}[ 5 ]${RESET} Exit"
    echo -e "  ${RED}[ 6 ]${RESET} ${BOLD}Uninstall All${RESET} - ${YELLOW}Hapus Semua Proteksi Shikimori${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────────${RESET}"
    echo ""
}

print_success() {
    echo ""
    echo -e "${GREEN}${BOLD}  ╔══════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}${BOLD}  ║        PENGINSTALAN BERHASIL ✅               ║${RESET}"
    echo -e "${GREEN}${BOLD}  ╚══════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${CYAN}${BOLD}DEVELOPER  :${RESET} ${WHITE}t.me/vallcz${RESET}"
    echo -e "  ${CYAN}${BOLD}YOUTUBE    :${RESET} ${WHITE}KAISAR VALL${RESET}"
    echo -e "  ${MAGENTA}${BOLD}               SHIKIMORI - PROJECT${RESET}"
    echo ""
}

log_ok()   { echo -e "  ${GREEN}[✔]${RESET} $1"; }
log_info() { echo -e "  ${CYAN}[*]${RESET} $1"; }
log_warn() { echo -e "  ${YELLOW}[!]${RESET} $1"; }
log_err()  { echo -e "  ${RED}[✖]${RESET} $1"; }

progress_bar() {
    local total=30
    echo -ne "  ${YELLOW}$1${RESET}\n  ["
    for ((i=0; i<total; i++)); do
        echo -ne "${GREEN}█${RESET}"
        sleep 0.04
    done
    echo -e "] ${GREEN}SELESAI${RESET}"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_err "Script ini HARUS dijalankan sebagai root!"
        echo -e "  ${YELLOW}Gunakan: sudo bash shikimori.sh${RESET}"
        exit 1
    fi
}

find_nginx_conf() {
    NGINX_CONF=""
    for f in \
        /etc/nginx/sites-enabled/pterodactyl.conf \
        /etc/nginx/sites-enabled/default \
        /etc/nginx/conf.d/pterodactyl.conf \
        /etc/nginx/conf.d/default.conf; do
        if [ -f "$f" ]; then
            NGINX_CONF="$f"
            return 0
        fi
    done
    NGINX_CONF=$(grep -rl "server_name" /etc/nginx/sites-enabled/ 2>/dev/null | head -1)
}

check_pterodactyl() {
    if [ ! -d "$PTERO_DIR" ]; then
        log_warn "Direktori Pterodactyl tidak ditemukan di $PTERO_DIR"
        log_warn "Proteksi nginx tetap dipasang, middleware PHP dilewati."
        return 1
    fi
    return 0
}

reload_nginx() {
    if nginx -t 2>/dev/null; then
        systemctl reload nginx 2>/dev/null
        log_ok "Nginx berhasil direload."
    else
        log_err "Config nginx ERROR! Mengembalikan backup..."
        if [ -n "$NGINX_CONF" ] && [ -f "${NGINX_CONF}.shikimori.bak" ]; then
            cp "${NGINX_CONF}.shikimori.bak" "$NGINX_CONF"
            nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null
        fi
    fi
}

inject_nginx_snippet() {
    local tag="$1"
    local path="$2"
    local line="    include ${path};"
    [ -z "$NGINX_CONF" ] && return
    grep -q "$tag" "$NGINX_CONF" 2>/dev/null && return
    if grep -q "location /" "$NGINX_CONF"; then
        sed -i "0,/location \//s||${line}\n    location /|" "$NGINX_CONF" 2>/dev/null
    else
        sed -i "/server_name/a\\${line}" "$NGINX_CONF" 2>/dev/null
    fi
}

inject_middleware_kernel() {
    local class="$1"
    local kernel="$PTERO_DIR/app/Http/Kernel.php"
    [ -f "$kernel" ] || return
    grep -q "$class" "$kernel" 2>/dev/null && return
    sed -i "/protected \\\$middleware = \[/a\\        \\\\Pterodactyl\\\\Http\\\\Middleware\\\\${class}::class," \
        "$kernel" 2>/dev/null && log_ok "Middleware ${class} terdaftar di Kernel.php."
}

clear_laravel_cache() {
    [ -d "$PTERO_DIR" ] || return
    cd "$PTERO_DIR" || return
    php artisan config:clear 2>/dev/null
    php artisan route:clear  2>/dev/null
    php artisan config:cache 2>/dev/null
    php artisan route:cache  2>/dev/null
    log_ok "Laravel cache diperbarui."
}

write_middleware_v1() {
    local dir="$1"
    cat > "$dir/ShikimoriV1Protect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ShikimoriV1Protect
{
    protected array $blocked = [
        'admin/nests',
        'admin/eggs',
        'admin/nodes',
        'admin/locations',
        'account/api',
        '/files',
        'api-keys',
        'api/application/nodes',
        'api/application/locations',
        'api/client/account/api-keys',
    ];

    protected array $noDelete = [
        'api/application/servers',
        'api/client/servers',
    ];

    public function handle(Request $request, Closure $next)
    {
        $path = $request->path();
        foreach ($this->blocked as $p) {
            if (str_contains($path, $p)) {
                return $this->deny($request);
            }
        }
        if ($request->isMethod('DELETE')) {
            foreach ($this->noDelete as $p) {
                if (str_contains($path, $p)) {
                    return $this->deny($request);
                }
            }
        }
        return $next($request);
    }

    private function deny(Request $r)
    {
        $m = ['success' => false, 'error' => '🛡️ PROTECT BY SHIKIMORI PROJECT'];
        if ($r->expectsJson() || str_starts_with($r->path(), 'api/')) {
            return response()->json($m, 403);
        }
        abort(403, '🛡️ PROTECT BY SHIKIMORI PROJECT');
    }
}
PHPEOF
}

write_middleware_v2() {
    local dir="$1"
    cat > "$dir/ShikimoriV2Protect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ShikimoriV2Protect
{
    protected array $blocked = [
        'allocations',
        '/build',
        'server-resources',
    ];

    public function handle(Request $request, Closure $next)
    {
        $path = $request->path();
        foreach ($this->blocked as $p) {
            if (str_contains($path, $p)) {
                return $this->deny($request);
            }
        }
        if (in_array($request->method(), ['PUT', 'PATCH']) && str_contains($path, 'build')) {
            return $this->deny($request);
        }
        return $next($request);
    }

    private function deny(Request $r)
    {
        $m = ['success' => false, 'error' => '🛡️ PROTECT BY SHIKIMORI PROJECT'];
        if ($r->expectsJson() || str_starts_with($r->path(), 'api/')) {
            return response()->json($m, 403);
        }
        abort(403, '🛡️ PROTECT BY SHIKIMORI PROJECT');
    }
}
PHPEOF
}

write_nginx_v1() {
    mkdir -p /etc/nginx/snippets
    cat > /etc/nginx/snippets/shikimori_v1.conf << 'NGINXEOF'
# ====== SHIKIMORI PROJECT V1 ======
location ~* ^/admin/nests                           { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
location ~* ^/admin/eggs                            { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
location ~* ^/admin/nodes                           { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
location ~* ^/admin/locations                       { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
location ~* ^/account/api                           { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
location ~* ^/api/client/servers/[^/]+/files        { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
location ~* ^/api/application/nodes                 { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
location ~* ^/api/application/locations             { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
location ~* ^/api/client/account/api-keys           { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
NGINXEOF
}

write_nginx_v2() {
    mkdir -p /etc/nginx/snippets
    cat > /etc/nginx/snippets/shikimori_v2.conf << 'NGINXEOF'
# ====== SHIKIMORI PROJECT V2 - PLTA & PLTC ======
location ~* ^/api/application/nodes/[^/]+/allocations       { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
location ~* ^/api/client/servers/[^/]+/network/allocations  { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
location ~* ^/admin/nodes/view/[^/]+/allocation              { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
location ~* ^/api/application/servers/[^/]+/build           { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
location ~* ^/api/client/servers/[^/]+/resources            { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
location ~* ^/admin/servers/view/[^/]+/build                { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; add_header Content-Type application/json; }
NGINXEOF
}

# ============================================================
# VERSION 1.0
# ============================================================
install_v1() {
    clear_screen
    print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 1.0 - Nest & Panel Protection...${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────────${RESET}"
    echo ""

    find_nginx_conf

    log_info "Memasang nginx block rules..."
    write_nginx_v1

    if [ -n "$NGINX_CONF" ]; then
        [ -f "${NGINX_CONF}.shikimori.bak" ] || cp "$NGINX_CONF" "${NGINX_CONF}.shikimori.bak" 2>/dev/null
        inject_nginx_snippet "shikimori_v1" "/etc/nginx/snippets/shikimori_v1.conf"
        reload_nginx
    else
        log_warn "Config nginx tidak ditemukan, skip nginx block."
    fi

    if check_pterodactyl; then
        MIDDLEWARE_DIR="$PTERO_DIR/app/Http/Middleware"
        mkdir -p "$MIDDLEWARE_DIR"
        write_middleware_v1 "$MIDDLEWARE_DIR"
        inject_middleware_kernel "ShikimoriV1Protect"
        clear_laravel_cache
    fi

    progress_bar "Menginstall V1 Protection..."
    echo ""
    log_ok "Proteksi V1 AKTIF! Yang diblokir:"
    echo -e "  ${GREEN}  ✅ Nest & Eggs${RESET}"
    echo -e "  ${GREEN}  ✅ File Manager${RESET}"
    echo -e "  ${GREEN}  ✅ Delete Server${RESET}"
    echo -e "  ${GREEN}  ✅ Nodes Management${RESET}"
    echo -e "  ${GREEN}  ✅ Location Management${RESET}"
    echo -e "  ${GREEN}  ✅ API Key View & Generate${RESET}"
    echo ""
    print_success
}

# ============================================================
# VERSION 2.0
# ============================================================
install_v2() {
    clear_screen
    print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 2.0 - PLTA & PLTC Protection...${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────────${RESET}"
    echo ""

    find_nginx_conf

    log_info "Memasang nginx block untuk PLTA & PLTC..."
    write_nginx_v2

    if [ -n "$NGINX_CONF" ]; then
        [ -f "${NGINX_CONF}.shikimori.bak" ] || cp "$NGINX_CONF" "${NGINX_CONF}.shikimori.bak" 2>/dev/null
        inject_nginx_snippet "shikimori_v2" "/etc/nginx/snippets/shikimori_v2.conf"
        reload_nginx
    else
        log_warn "Config nginx tidak ditemukan, skip nginx block."
    fi

    if check_pterodactyl; then
        MIDDLEWARE_DIR="$PTERO_DIR/app/Http/Middleware"
        mkdir -p "$MIDDLEWARE_DIR"
        write_middleware_v2 "$MIDDLEWARE_DIR"
        inject_middleware_kernel "ShikimoriV2Protect"
        clear_laravel_cache
    fi

    progress_bar "Menginstall V2 PLTA & PLTC Protection..."
    echo ""
    log_ok "Proteksi V2 AKTIF! Yang diblokir:"
    echo -e "  ${GREEN}  ✅ PLTA - Allocation (node port limits)${RESET}"
    echo -e "  ${GREEN}  ✅ PLTC - Build/Resource cap settings${RESET}"
    echo ""
    print_success
}

# ============================================================
# INTERNAL: pasang V1+V2 tanpa banner/success (dipanggil V3/V4)
# ============================================================
_setup_v1v2() {
    find_nginx_conf
    write_nginx_v1
    write_nginx_v2

    if [ -n "$NGINX_CONF" ]; then
        [ -f "${NGINX_CONF}.shikimori.bak" ] || cp "$NGINX_CONF" "${NGINX_CONF}.shikimori.bak" 2>/dev/null
        inject_nginx_snippet "shikimori_v1" "/etc/nginx/snippets/shikimori_v1.conf"
        inject_nginx_snippet "shikimori_v2" "/etc/nginx/snippets/shikimori_v2.conf"
        reload_nginx
    fi

    if [ -d "$PTERO_DIR" ]; then
        MIDDLEWARE_DIR="$PTERO_DIR/app/Http/Middleware"
        mkdir -p "$MIDDLEWARE_DIR"
        write_middleware_v1 "$MIDDLEWARE_DIR"
        write_middleware_v2 "$MIDDLEWARE_DIR"
        inject_middleware_kernel "ShikimoriV1Protect"
        inject_middleware_kernel "ShikimoriV2Protect"
        clear_laravel_cache
    fi

    log_ok "Proteksi V1 + V2 terpasang."
}

# ============================================================
# INTERNAL: VPS hardening (SSH + sysctl + Fail2Ban + UFW)
# ============================================================
_setup_vps_hardening() {
    # SSH
    log_info "Hardening SSH..."
    SSHD="/etc/ssh/sshd_config"
    if [ -f "$SSHD" ]; then
        [ -f "${SSHD}.shikimori.bak" ] || cp "$SSHD" "${SSHD}.shikimori.bak"
        sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/'       "$SSHD"
        sed -i 's/^#*LoginGraceTime.*/LoginGraceTime 30/'  "$SSHD"
        sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSHD"
        grep -q "DebianBanner" "$SSHD" \
            && sed -i 's/^#*DebianBanner.*/DebianBanner no/' "$SSHD" \
            || echo "DebianBanner no" >> "$SSHD"
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        log_ok "SSH hardening selesai."
    fi

    # Sysctl - HANYA network, tidak ganggu memory/swap
    log_info "Kernel network hardening..."
    cat > /etc/sysctl.d/99-shikimori.conf << 'SYSEOF'
# SHIKIMORI PROJECT - Network Hardening
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.tcp_timestamps = 0
SYSEOF
    sysctl -p /etc/sysctl.d/99-shikimori.conf >/dev/null 2>&1
    log_ok "Kernel hardening selesai."

    # Fail2Ban
    log_info "Menginstall Fail2Ban..."
    apt-get install -y -q fail2ban 2>/dev/null
    cat > /etc/fail2ban/jail.d/shikimori.conf << 'F2BEOF'
[sshd]
enabled  = true
port     = ssh
maxretry = 3
bantime  = 86400
findtime = 600

[nginx-http-auth]
enabled  = true
port     = http,https
maxretry = 5
bantime  = 3600

[nginx-botsearch]
enabled  = true
port     = http,https
maxretry = 2
bantime  = 86400
F2BEOF
    systemctl enable fail2ban 2>/dev/null
    systemctl restart fail2ban 2>/dev/null
    log_ok "Fail2Ban aktif."

    # UFW - port 80/443 WAJIB terbuka agar panel tidak lag
    log_info "Mengkonfigurasi UFW..."
    ufw --force reset         2>/dev/null
    ufw default deny incoming  2>/dev/null
    ufw default allow outgoing 2>/dev/null
    ufw allow 22/tcp    comment 'SSH'   2>/dev/null
    ufw allow 80/tcp    comment 'HTTP'  2>/dev/null
    ufw allow 443/tcp   comment 'HTTPS' 2>/dev/null
    ufw allow 8080/tcp  comment 'Wings' 2>/dev/null
    ufw allow 2022/tcp  comment 'SFTP'  2>/dev/null
    ufw --force enable 2>/dev/null
    log_ok "UFW aktif (80/443/8080 tetap terbuka)."
}

# ============================================================
# VERSION 3.0
# ============================================================
install_v3() {
    clear_screen
    print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 3.0 - Super Hardest Protection...${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────────${RESET}"
    echo ""
    echo -e "  ${RED}${BOLD}[!] Mode ini menginstall V1 + V2 + VPS Hardening!${RESET}"
    echo ""
    sleep 1

    _setup_v1v2
    echo ""
    _setup_vps_hardening

    progress_bar "Menginstall Super Hardest Protection..."
    echo ""
    log_ok "Proteksi V3 AKTIF! Ringkasan:"
    echo -e "  ${GREEN}  ✅ Semua proteksi V1 & V2${RESET}"
    echo -e "  ${GREEN}  ✅ SSH hardening (MaxAuthTries=3, no root login)${RESET}"
    echo -e "  ${GREEN}  ✅ Kernel anti-flood & anti-fingerprint${RESET}"
    echo -e "  ${GREEN}  ✅ Fail2Ban (SSH ban 24 jam, nginx ban 1 jam)${RESET}"
    echo -e "  ${GREEN}  ✅ UFW firewall (port 80/443/8080 terbuka)${RESET}"
    echo ""
    print_success
}

# ============================================================
# VERSION 4.0 - SHIKIMORI MODE
# ============================================================
install_v4() {
    clear_screen
    print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 4.0 - SHIKIMORI MODE...${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────────${RESET}"
    echo ""
    echo -e "  ${RED}${BOLD}[!!!] SHIKIMORI MODE - PROTEKSI LEVEL TERTINGGI!!!${RESET}"
    echo ""
    sleep 1

    _setup_v1v2
    echo ""
    _setup_vps_hardening
    echo ""

    # --- Identity Masking ---
    log_info "Mengaktifkan Identity Masking..."

    HOSTS_BLOCK=(
        "ipinfo.io" "ipapi.co" "api.ipify.org"
        "checkip.amazonaws.com" "icanhazip.com"
        "ifconfig.me" "ip-api.com" "ipgeolocation.io"
        "geoip.maxmind.com" "geolite.maxmind.com"
    )
    for domain in "${HOSTS_BLOCK[@]}"; do
        grep -q "$domain" /etc/hosts 2>/dev/null || echo "0.0.0.0 $domain" >> /etc/hosts
    done
    log_ok "Domain IP-lookup diblokir via /etc/hosts."

    # Simpan hostname asli lalu spoof
    OLD_HOST=$(hostname)
    echo "$OLD_HOST" > /etc/shikimori_original_hostname
    hostnamectl set-hostname "unknown" 2>/dev/null || echo "unknown" > /etc/hostname
    log_ok "Hostname: ${OLD_HOST} → unknown"

    # machine-id
    if [ -f /etc/machine-id ]; then
        [ -f /etc/machine-id.shikimori.bak ] || cp /etc/machine-id /etc/machine-id.shikimori.bak
        echo "00000000000000000000000000000000" > /etc/machine-id
    fi
    log_ok "Machine-ID disalik."

    # --- Console Log Faker ---
    log_info "Memasang Console Log Faker..."
    mkdir -p /opt/shikimori
    cat > /opt/shikimori/console_faker.sh << 'FAKEEOF'
#!/bin/bash
LOG_DIRS=("/var/log/pterodactyl" "/var/www/pterodactyl/storage/logs")
for dir in "${LOG_DIRS[@]}"; do
    [ -d "$dir" ] || continue
    find "$dir" -name "*.log" -type f 2>/dev/null | while read -r f; do
        sed -i \
            -e 's/"provider":"[^"]*"/"provider":"Unknown"/g' \
            -e 's/"Provider":"[^"]*"/"Provider":"Unknown"/g' \
            -e 's/provider: [A-Za-z0-9 .,_-]*/provider: Unknown/g' \
            -e 's/Provider: [A-Za-z0-9 .,_-]*/Provider: Unknown/g' \
            -e 's/"hostname":"[^"]*"/"hostname":"unknown"/g' \
            -e 's/hostname: [A-Za-z0-9._-]*/hostname: unknown/g' \
            -e 's/"region":"[^"]*"/"region":"N\/A"/g' \
            -e 's/"country":"[^"]*"/"country":"N\/A"/g' \
            -e 's/"city":"[^"]*"/"city":"N\/A"/g' \
            -e 's/"org":"[^"]*"/"org":"Unknown"/g' \
            -e 's/"isp":"[^"]*"/"isp":"Unknown"/g' \
            "$f" 2>/dev/null
    done
done
FAKEEOF
    chmod +x /opt/shikimori/console_faker.sh
    (crontab -l 2>/dev/null | grep -v "console_faker.sh"; \
        echo "* * * * * /opt/shikimori/console_faker.sh") | crontab -
    log_ok "Console Log Faker aktif (tiap menit via cron)."

    # Sembunyikan nginx server signature
    if ! grep -q "server_tokens off" /etc/nginx/nginx.conf 2>/dev/null; then
        sed -i '/http {/a\\    server_tokens off;' /etc/nginx/nginx.conf 2>/dev/null
        nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null
    fi
    log_ok "Nginx server signature disembunyikan."

    progress_bar "Menginstall SHIKIMORI MODE..."
    echo ""
    echo -e "${MAGENTA}${BOLD}  ╔════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}${BOLD}  ║      🛡️  SHIKIMORI MODE BERHASIL DIAKTIFKAN! 🛡️        ║${RESET}"
    echo -e "${MAGENTA}${BOLD}  ╚════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${CYAN}Ringkasan Shikimori Mode:${RESET}"
    echo -e "  ${GREEN}  ✅ V1 - Nest, File, Node, Location, API Key${RESET}"
    echo -e "  ${GREEN}  ✅ V2 - PLTA & PLTC (Allocation & Build)${RESET}"
    echo -e "  ${GREEN}  ✅ V3 - SSH Hardening, Fail2Ban, UFW${RESET}"
    echo -e "  ${GREEN}  ✅ Hostname → unknown${RESET}"
    echo -e "  ${GREEN}  ✅ Provider/Region → Unknown / N/A${RESET}"
    echo -e "  ${GREEN}  ✅ IP Detection → DIBLOKIR${RESET}"
    echo -e "  ${GREEN}  ✅ Console Log Faker → AKTIF (tiap menit)${RESET}"
    echo -e "  ${GREEN}  ✅ Nginx signature → DISEMBUNYIKAN${RESET}"
    echo ""
    print_success
}

# ============================================================
# UNINSTALL ALL
# Menghapus semua proteksi & mengembalikan ke kondisi awal
# ============================================================
uninstall_all() {
    clear_screen
    print_banner
    echo -e "${RED}${BOLD}  ⚠️  UNINSTALL ALL - Menghapus Semua Proteksi Shikimori${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────────${RESET}"
    echo ""
    echo -e "  ${YELLOW}Proses ini akan mengembalikan VPS & Panel ke kondisi semula.${RESET}"
    echo -ne "\n  ${WHITE}${BOLD}Yakin ingin melanjutkan? [y/N] : ${RESET}"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_warn "Uninstall dibatalkan."
        return
    fi
    echo ""

    find_nginx_conf

    # --- 1. Hapus nginx snippets ---
    log_info "Menghapus nginx snippets..."
    for s in /etc/nginx/snippets/shikimori_v1.conf /etc/nginx/snippets/shikimori_v2.conf; do
        [ -f "$s" ] && rm -f "$s" && log_ok "Dihapus: $s"
    done

    # --- 2. Kembalikan nginx config dari backup ---
    log_info "Mengembalikan konfigurasi nginx..."
    RESTORED=0
    for bak in \
        "${NGINX_CONF}.shikimori.bak" \
        "${NGINX_CONF}.shikimori.v2.bak"; do
        if [ -f "$bak" ]; then
            cp "$bak" "$NGINX_CONF"
            rm -f "$bak"
            log_ok "Nginx config dikembalikan dari backup."
            RESTORED=1
            break
        fi
    done
    # Jika tidak ada backup, hapus baris include shikimori secara manual
    if [ "$RESTORED" -eq 0 ] && [ -n "$NGINX_CONF" ] && [ -f "$NGINX_CONF" ]; then
        sed -i '/shikimori/d' "$NGINX_CONF" 2>/dev/null
        log_ok "Baris include shikimori dihapus dari nginx config."
    fi
    # Kembalikan server_tokens
    sed -i '/server_tokens off/d' /etc/nginx/nginx.conf 2>/dev/null

    # Test & reload
    if nginx -t 2>/dev/null; then
        systemctl reload nginx 2>/dev/null
        log_ok "Nginx direload - panel kembali normal."
    else
        log_err "Nginx config masih error, periksa manual dengan: nginx -t"
    fi

    # --- 3. Hapus PHP Middleware ---
    log_info "Menghapus PHP Middleware..."
    for mw in \
        "$PTERO_DIR/app/Http/Middleware/ShikimoriV1Protect.php" \
        "$PTERO_DIR/app/Http/Middleware/ShikimoriV2Protect.php"; do
        [ -f "$mw" ] && rm -f "$mw" && log_ok "Dihapus: $mw"
    done

    # --- 4. Hapus dari Kernel.php ---
    KERNEL="$PTERO_DIR/app/Http/Kernel.php"
    if [ -f "$KERNEL" ]; then
        log_info "Membersihkan Kernel.php..."
        sed -i '/ShikimoriV1Protect/d' "$KERNEL" 2>/dev/null
        sed -i '/ShikimoriV2Protect/d' "$KERNEL" 2>/dev/null
        log_ok "Middleware dihapus dari Kernel.php."
    fi

    # --- 5. Rebuild Laravel cache ---
    if [ -d "$PTERO_DIR" ]; then
        log_info "Memperbarui Laravel cache..."
        cd "$PTERO_DIR" || true
        php artisan config:clear  2>/dev/null
        php artisan route:clear   2>/dev/null
        php artisan cache:clear   2>/dev/null
        php artisan config:cache  2>/dev/null
        php artisan route:cache   2>/dev/null
        log_ok "Laravel cache diperbarui."
    fi

    # --- 6. Kembalikan SSH config ---
    log_info "Mengembalikan konfigurasi SSH..."
    SSHD="/etc/ssh/sshd_config"
    if [ -f "${SSHD}.shikimori.bak" ]; then
        cp "${SSHD}.shikimori.bak" "$SSHD"
        rm -f "${SSHD}.shikimori.bak"
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        log_ok "SSH config dikembalikan dari backup."
    else
        # Kembalikan ke default Ubuntu yang aman
        sed -i 's/^MaxAuthTries 3/#MaxAuthTries 6/'            "$SSHD" 2>/dev/null
        sed -i 's/^LoginGraceTime 30/#LoginGraceTime 120/'     "$SSHD" 2>/dev/null
        sed -i 's/^PermitRootLogin no/#PermitRootLogin prohibit-password/' "$SSHD" 2>/dev/null
        sed -i '/^DebianBanner no/d'                            "$SSHD" 2>/dev/null
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        log_ok "SSH config dikembalikan ke default."
    fi

    # --- 7. Hapus sysctl shikimori ---
    log_info "Menghapus kernel hardening rules..."
    if [ -f /etc/sysctl.d/99-shikimori.conf ]; then
        rm -f /etc/sysctl.d/99-shikimori.conf
        sysctl --system >/dev/null 2>&1
        log_ok "Kernel rules dihapus & system sysctl direload."
    fi

    # --- 8. Hapus Fail2Ban shikimori config ---
    log_info "Membersihkan Fail2Ban..."
    if [ -f /etc/fail2ban/jail.d/shikimori.conf ]; then
        rm -f /etc/fail2ban/jail.d/shikimori.conf
        systemctl restart fail2ban 2>/dev/null
        log_ok "Fail2Ban config shikimori dihapus."
    fi

    # --- 9. UFW - disable & reset ke kondisi awal ---
    log_info "Mereset UFW..."
    ufw --force reset   2>/dev/null
    ufw --force disable 2>/dev/null
    log_ok "UFW direset & dinonaktifkan (kondisi awal Ubuntu)."

    # --- 10. Bersihkan /etc/hosts ---
    log_info "Membersihkan /etc/hosts..."
    HOSTS_LIST=(
        "ipinfo.io" "ipapi.co" "api.ipify.org"
        "checkip.amazonaws.com" "icanhazip.com"
        "ifconfig.me" "ip-api.com" "ipgeolocation.io"
        "geoip.maxmind.com" "geolite.maxmind.com"
    )
    for domain in "${HOSTS_LIST[@]}"; do
        sed -i "/$domain/d" /etc/hosts 2>/dev/null
    done
    log_ok "/etc/hosts dibersihkan."

    # --- 11. Kembalikan hostname ---
    log_info "Mengembalikan hostname..."
    if [ -f /etc/shikimori_original_hostname ]; then
        ORIG=$(cat /etc/shikimori_original_hostname)
        hostnamectl set-hostname "$ORIG" 2>/dev/null
        rm -f /etc/shikimori_original_hostname
        log_ok "Hostname dikembalikan: unknown → ${ORIG}"
    else
        log_warn "File hostname asli tidak ditemukan."
        log_warn "Ubah manual: hostnamectl set-hostname NAMA_VPS_KAMU"
    fi

    # --- 12. Kembalikan machine-id ---
    if [ -f /etc/machine-id.shikimori.bak ]; then
        cp /etc/machine-id.shikimori.bak /etc/machine-id
        rm -f /etc/machine-id.shikimori.bak
        log_ok "machine-id dikembalikan."
    fi

    # --- 13. Hapus cron Console Log Faker ---
    log_info "Menghapus cron Console Log Faker..."
    crontab -l 2>/dev/null | grep -v "console_faker.sh" | crontab - 2>/dev/null
    log_ok "Cron Console Log Faker dihapus."

    # --- 14. Hapus direktori & file shikimori ---
    [ -d /opt/shikimori ] && rm -rf /opt/shikimori && log_ok "/opt/shikimori dihapus."

    progress_bar "Menyelesaikan Uninstall..."

    echo ""
    echo -e "${GREEN}${BOLD}  ╔════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}${BOLD}  ║      ✅  SEMUA PROTEKSI BERHASIL DIHAPUS! ✅           ║${RESET}"
    echo -e "${GREEN}${BOLD}  ╚════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${CYAN}VPS & Panel Pterodactyl kembali ke kondisi normal.${RESET}"
    echo -e "  ${YELLOW}Tidak ada perubahan pada database atau data server kamu.${RESET}"
    echo ""
    echo -e "  ${CYAN}${BOLD}DEVELOPER  :${RESET} ${WHITE}t.me/vallcz${RESET}"
    echo -e "  ${CYAN}${BOLD}YOUTUBE    :${RESET} ${WHITE}KAISAR VALL${RESET}"
    echo -e "  ${MAGENTA}${BOLD}               SHIKIMORI - PROJECT${RESET}"
    echo ""
}

# ============================================================
# MAIN LOOP
# ============================================================
check_root

while true; do
    clear_screen
    print_banner
    print_menu

    echo -ne "  ${WHITE}${BOLD}Masukkan Pilihan Anda [1-6] :${RESET} "
    read -r choice

    case $choice in
        1)
            install_v1
            echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"
            read -r
            ;;
        2)
            install_v2
            echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"
            read -r
            ;;
        3)
            install_v3
            echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"
            read -r
            ;;
        4)
            install_v4
            echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"
            read -r
            ;;
        5)
            clear_screen
            echo ""
            echo -e "${MAGENTA}${BOLD}  🛡️  Terima kasih telah menggunakan SHIKIMORI PROJECT!${RESET}"
            echo -e "  ${CYAN}  Developer : t.me/vallcz${RESET}"
            echo -e "  ${CYAN}  YouTube   : KAISAR VALL${RESET}"
            echo ""
            exit 0
            ;;
        6)
            uninstall_all
            echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"
            read -r
            ;;
        *)
            log_err "Pilihan tidak valid! Masukkan angka 1-6."
            sleep 1
            ;;
    esac
done
