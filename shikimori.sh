#!/bin/bash

# ============================================================
#   SHIKIMORI PROJECT - VPS & PTERODACTYL PROTECTION
#   Developer : t.me/vallcz | YouTube : KAISAR VALL
#   Target    : Ubuntu 22.04 + Nginx + Pterodactyl
#
#   FILE MANAGER : BEBAS diakses user panel (upload/download/bot)
#   DIBLOKIR     : Bot luar tanpa sesi + endpoint sensitif admin
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
        [ -f "$f" ] && NGINX_CONF="$f" && return 0
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
        log_ok "Nginx direload dengan sukses."
    else
        log_err "Config nginx ERROR! Mengembalikan backup..."
        [ -n "$NGINX_CONF" ] && [ -f "${NGINX_CONF}.shikimori.bak" ] && \
            cp "${NGINX_CONF}.shikimori.bak" "$NGINX_CONF"
        nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null
    fi
}

inject_nginx_snippet() {
    local tag="$1" path="$2"
    local line="    include ${path};"
    [ -z "$NGINX_CONF" ] && return
    grep -q "$tag" "$NGINX_CONF" 2>/dev/null && return
    if grep -q "location /" "$NGINX_CONF" 2>/dev/null; then
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

# ============================================================
# NGINX SNIPPET V1
# ✅ File Manager BEBAS - user bisa upload/download/running bot
# 🔒 Blokir: Nest, Eggs, Nodes, Locations, API Key, Delete Server
# 🔒 Blokir: Bot luar tanpa sesi panel (User-Agent scraper)
# ============================================================
write_nginx_v1() {
    mkdir -p /etc/nginx/snippets
    cat > /etc/nginx/snippets/shikimori_v1.conf << 'NGINXEOF'
# ====== SHIKIMORI PROJECT V1 ======
# File Manager TIDAK diblokir - user panel tetap bisa akses normal

# --- Block Nest & Eggs (template management) ---
location ~* ^/admin/nests {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/admin/eggs {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}

# --- Block Nodes management ---
location ~* ^/admin/nodes {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/api/application/nodes {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}

# --- Block Locations management ---
location ~* ^/admin/locations {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/api/application/locations {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}

# --- Block API Key page ---
location ~* ^/account/api {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/api/client/account/api-keys {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}

# --- Block bot/scraper luar tanpa session dari File Manager ---
# Hanya blokir jika request ke file endpoint TANPA cookie sesi panel
# User yang login normal TETAP bisa akses file manager
location ~* ^/api/client/servers/[^/]+/files {
    # Jika ada cookie pterodactyl_session = user panel sah, lanjutkan
    if ($http_cookie ~* "pterodactyl_session") {
        proxy_pass http://unix:/run/pterodactyl.sock;
    }
    # Jika tidak ada session cookie = bot/script luar, blokir
    if ($http_cookie !~* "pterodactyl_session") {
        return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    }
    add_header Content-Type "application/json" always;
}
NGINXEOF
}

# ============================================================
# NGINX SNIPPET V2
# 🔒 Blokir: PLTA (Allocations) & PLTC (Build/Resource caps)
# ============================================================
write_nginx_v2() {
    mkdir -p /etc/nginx/snippets
    cat > /etc/nginx/snippets/shikimori_v2.conf << 'NGINXEOF'
# ====== SHIKIMORI PROJECT V2 - PLTA & PLTC ======

# --- PLTA: Allocation endpoints (port limits) ---
location ~* ^/api/application/nodes/[^/]+/allocations {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/api/client/servers/[^/]+/network/allocations {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/admin/nodes/view/[^/]+/allocation {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}

# --- PLTC: Build / resource cap endpoints ---
location ~* ^/api/application/servers/[^/]+/build {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/api/client/servers/[^/]+/resources {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/admin/servers/view/[^/]+/build {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
NGINXEOF
}

# ============================================================
# MIDDLEWARE V1 (PHP Laravel)
# ✅ File Manager = BEBAS untuk user panel yang punya sesi login
# 🔒 Bot luar tanpa token Sanctum/sesi = ditolak di file endpoint
# 🔒 Blokir endpoint admin sensitif
# ============================================================
write_middleware_v1() {
    local dir="$1"
    cat > "$dir/ShikimoriV1Protect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

/**
 * SHIKIMORI PROJECT V1
 *
 * Yang DIBLOKIR:
 *   - Nest, Eggs, Nodes, Locations, API Keys
 *   - DELETE server
 *   - Akses file endpoint dari bot luar (tanpa autentikasi panel)
 *
 * Yang BEBAS:
 *   - File Manager untuk user yang sudah login ke panel
 *   - Console, start/stop/restart server
 *   - Semua fitur panel normal
 */
class ShikimoriV1Protect
{
    // URI yang selalu diblokir tanpa pengecualian
    protected array $alwaysBlocked = [
        'admin/nests',
        'admin/eggs',
        'admin/nodes',
        'admin/locations',
        'account/api',
        'api/application/nodes',
        'api/application/locations',
        'api/client/account/api-keys',
    ];

    // URI yang hanya diblokir jika method DELETE
    protected array $deleteBlocked = [
        'api/application/servers',
    ];

    // URI yang diblokir HANYA jika tidak ada autentikasi panel
    // (user login panel = bebas, bot luar = ditolak)
    protected array $sessionRequired = [
        'api/client/servers',
    ];

    public function handle(Request $request, Closure $next)
    {
        $path = $request->path();

        // 1. Blokir total endpoint sensitif admin
        foreach ($this->alwaysBlocked as $p) {
            if (str_contains($path, $p)) {
                return $this->deny($request);
            }
        }

        // 2. Blokir DELETE server
        if ($request->isMethod('DELETE')) {
            foreach ($this->deleteBlocked as $p) {
                if (str_contains($path, $p)) {
                    return $this->deny($request);
                }
            }
        }

        // 3. Endpoint files: izinkan jika user terotentikasi via panel
        //    Blokir jika bot luar tanpa autentikasi sama sekali
        if (str_contains($path, '/files') || str_contains($path, 'api/client/servers')) {
            // Cek apakah request punya autentikasi yang valid
            // Bearer token Sanctum = API call resmi dari panel
            // Session cookie = user browser yang login
            $hasAuth = $request->bearerToken() !== null
                || $request->hasCookie('pterodactyl_session')
                || $request->user() !== null;

            if (!$hasAuth && str_contains($path, '/files')) {
                // Tidak ada autentikasi apapun = bot luar, tolak
                return $this->deny($request);
            }
        }

        return $next($request);
    }

    private function deny(Request $r)
    {
        $msg = ['success' => false, 'error' => '🛡️ PROTECT BY SHIKIMORI PROJECT'];
        if ($r->expectsJson() || str_starts_with($r->path(), 'api/')) {
            return response()->json($msg, 403);
        }
        abort(403, '🛡️ PROTECT BY SHIKIMORI PROJECT');
    }
}
PHPEOF
}

# ============================================================
# MIDDLEWARE V2 (PHP Laravel)
# 🔒 Blokir: PLTA & PLTC saja
# ============================================================
write_middleware_v2() {
    local dir="$1"
    cat > "$dir/ShikimoriV2Protect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

/**
 * SHIKIMORI PROJECT V2
 * Block: PLTA (Allocations) & PLTC (Build/Resource caps)
 */
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

        // Block PUT/PATCH ke build endpoint (ubah resource cap)
        if (in_array($request->method(), ['PUT', 'PATCH']) && str_contains($path, 'build')) {
            return $this->deny($request);
        }

        return $next($request);
    }

    private function deny(Request $r)
    {
        $msg = ['success' => false, 'error' => '🛡️ PROTECT BY SHIKIMORI PROJECT'];
        if ($r->expectsJson() || str_starts_with($r->path(), 'api/')) {
            return response()->json($msg, 403);
        }
        abort(403, '🛡️ PROTECT BY SHIKIMORI PROJECT');
    }
}
PHPEOF
}

# ============================================================
# INTERNAL: Setup V1 + V2 (dipanggil V3 & V4)
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
# INTERNAL: VPS Hardening
# ============================================================
_setup_vps_hardening() {
    log_info "Hardening SSH..."
    SSHD="/etc/ssh/sshd_config"
    if [ -f "$SSHD" ]; then
        [ -f "${SSHD}.shikimori.bak" ] || cp "$SSHD" "${SSHD}.shikimori.bak"
        sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/'        "$SSHD"
        sed -i 's/^#*LoginGraceTime.*/LoginGraceTime 30/'   "$SSHD"
        sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSHD"
        grep -q "DebianBanner" "$SSHD" \
            && sed -i 's/^#*DebianBanner.*/DebianBanner no/' "$SSHD" \
            || echo "DebianBanner no" >> "$SSHD"
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        log_ok "SSH hardening selesai."
    fi

    log_info "Kernel network hardening..."
    cat > /etc/sysctl.d/99-shikimori.conf << 'SYSEOF'
# SHIKIMORI - Network Hardening (tidak menyentuh memori/swap)
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
    log_ok "Fail2Ban aktif (auto ban brute force)."

    log_info "Mengkonfigurasi UFW firewall..."
    ufw --force reset          2>/dev/null
    ufw default deny incoming  2>/dev/null
    ufw default allow outgoing 2>/dev/null
    ufw allow 22/tcp   comment 'SSH'   2>/dev/null
    ufw allow 80/tcp   comment 'HTTP'  2>/dev/null
    ufw allow 443/tcp  comment 'HTTPS' 2>/dev/null
    ufw allow 8080/tcp comment 'Wings' 2>/dev/null
    ufw allow 2022/tcp comment 'SFTP'  2>/dev/null
    ufw --force enable 2>/dev/null
    log_ok "UFW aktif — port 80/443/8080 terbuka, panel tidak lag."
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
    echo -e "  ${GREEN}  ✅ File Manager TETAP BEBAS — upload/download/running bot aman${RESET}"
    echo -e "  ${RED}  🔒 Bot luar tanpa sesi panel = DITOLAK di file endpoint${RESET}"
    echo ""

    find_nginx_conf
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
    log_ok "Proteksi V1 AKTIF!"
    echo ""
    echo -e "  ${RED}  🔒 Yang DIBLOKIR:${RESET}"
    echo -e "  ${RED}     ✖  Nest & Eggs (template server)${RESET}"
    echo -e "  ${RED}     ✖  Nodes Management${RESET}"
    echo -e "  ${RED}     ✖  Locations Management${RESET}"
    echo -e "  ${RED}     ✖  API Key View & Generate${RESET}"
    echo -e "  ${RED}     ✖  Delete Server${RESET}"
    echo -e "  ${RED}     ✖  Bot/script luar tanpa sesi ke file endpoint${RESET}"
    echo ""
    echo -e "  ${GREEN}  ✅ Yang TETAP BEBAS:${RESET}"
    echo -e "  ${GREEN}     ✔  File Manager (upload/download/edit/running bot)${RESET}"
    echo -e "  ${GREEN}     ✔  Console, Start/Stop/Restart server${RESET}"
    echo -e "  ${GREEN}     ✔  Semua fitur panel normal${RESET}"
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
    log_ok "Proteksi V2 AKTIF!"
    echo ""
    echo -e "  ${RED}  🔒 Yang DIBLOKIR:${RESET}"
    echo -e "  ${RED}     ✖  PLTA — Allocation / port limits${RESET}"
    echo -e "  ${RED}     ✖  PLTC — Build / resource cap settings${RESET}"
    echo ""
    echo -e "  ${GREEN}  ✅ Yang TETAP BEBAS:${RESET}"
    echo -e "  ${GREEN}     ✔  File Manager (upload/download/running bot)${RESET}"
    echo -e "  ${GREEN}     ✔  Console, Start/Stop/Restart server${RESET}"
    echo -e "  ${GREEN}     ✔  Semua fitur panel normal${RESET}"
    echo ""
    print_success
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
    echo -e "  ${GREEN}  ✅ File Manager TETAP BEBAS untuk user panel${RESET}"
    echo -e "  ${RED}${BOLD}  [!] Menginstall V1 + V2 + VPS Hardening penuh!${RESET}"
    echo ""
    sleep 1

    _setup_v1v2
    echo ""
    _setup_vps_hardening

    progress_bar "Menginstall Super Hardest Protection..."
    echo ""
    log_ok "Proteksi V3 AKTIF!"
    echo ""
    echo -e "  ${RED}  🔒 Yang DIBLOKIR:${RESET}"
    echo -e "  ${RED}     ✖  Nest, Eggs, Nodes, Locations, API Keys${RESET}"
    echo -e "  ${RED}     ✖  PLTA & PLTC${RESET}"
    echo -e "  ${RED}     ✖  Delete Server${RESET}"
    echo -e "  ${RED}     ✖  Bot luar tanpa sesi ke file endpoint${RESET}"
    echo -e "  ${RED}     ✖  Brute force SSH (auto ban 24 jam)${RESET}"
    echo -e "  ${RED}     ✖  Port tidak dikenal (UFW)${RESET}"
    echo ""
    echo -e "  ${GREEN}  ✅ Yang TETAP BEBAS:${RESET}"
    echo -e "  ${GREEN}     ✔  File Manager (upload/download/running bot)${RESET}"
    echo -e "  ${GREEN}     ✔  Console, Start/Stop/Restart server${RESET}"
    echo -e "  ${GREEN}     ✔  Port 22, 80, 443, 8080, 2022${RESET}"
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
    echo -e "  ${GREEN}  ✅ File Manager TETAP BEBAS untuk user panel${RESET}"
    echo -e "  ${RED}${BOLD}  [!!!] SHIKIMORI MODE - PROTEKSI LEVEL TERTINGGI!!!${RESET}"
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

    OLD_HOST=$(hostname)
    echo "$OLD_HOST" > /etc/shikimori_original_hostname
    hostnamectl set-hostname "unknown" 2>/dev/null || echo "unknown" > /etc/hostname
    log_ok "Hostname: ${OLD_HOST} → unknown"

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
# Shikimori Project - Console Log Faker
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
    echo -e "  ${RED}  🔒 Yang DIBLOKIR / DISEMBUNYIKAN:${RESET}"
    echo -e "  ${RED}     ✖  Nest, Eggs, Nodes, Locations, API Keys${RESET}"
    echo -e "  ${RED}     ✖  PLTA & PLTC${RESET}"
    echo -e "  ${RED}     ✖  Delete Server${RESET}"
    echo -e "  ${RED}     ✖  Bot luar tanpa sesi ke file endpoint${RESET}"
    echo -e "  ${RED}     ✖  IP/Provider/Region/Hostname detection${RESET}"
    echo -e "  ${RED}     ✖  Console log info sensitif (auto sanitasi)${RESET}"
    echo ""
    echo -e "  ${GREEN}  ✅ Yang TETAP BEBAS:${RESET}"
    echo -e "  ${GREEN}     ✔  File Manager (upload/download/edit/running bot)${RESET}"
    echo -e "  ${GREEN}     ✔  Console, Start/Stop/Restart server${RESET}"
    echo -e "  ${GREEN}     ✔  Port 22, 80, 443, 8080, 2022${RESET}"
    echo -e "  ${GREEN}     ✔  Semua fitur panel normal${RESET}"
    echo ""
    print_success
}

# ============================================================
# UNINSTALL ALL
# ============================================================
uninstall_all() {
    clear_screen
    print_banner
    echo -e "${RED}${BOLD}  ⚠️  UNINSTALL ALL - Menghapus Semua Proteksi Shikimori${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────────${RESET}"
    echo ""
    echo -e "  ${YELLOW}  Semua proteksi akan dihapus & VPS dikembalikan ke awal.${RESET}"
    echo -e "  ${GREEN}  Data server, database, dan file TIDAK akan terhapus.${RESET}"
    echo ""
    echo -ne "  ${WHITE}${BOLD}Yakin ingin melanjutkan? [y/N] : ${RESET}"
    read -r confirm
    [[ ! "$confirm" =~ ^[Yy]$ ]] && log_warn "Uninstall dibatalkan." && return
    echo ""

    find_nginx_conf

    # 1. Hapus nginx snippets
    log_info "Menghapus nginx snippets..."
    for s in /etc/nginx/snippets/shikimori_v1.conf /etc/nginx/snippets/shikimori_v2.conf; do
        [ -f "$s" ] && rm -f "$s" && log_ok "Dihapus: $s"
    done

    # 2. Kembalikan nginx config dari backup
    log_info "Mengembalikan konfigurasi nginx..."
    RESTORED=0
    for bak in "${NGINX_CONF}.shikimori.bak" "${NGINX_CONF}.shikimori.v2.bak"; do
        if [ -f "$bak" ]; then
            cp "$bak" "$NGINX_CONF" && rm -f "$bak"
            log_ok "Nginx config dikembalikan dari backup."
            RESTORED=1; break
        fi
    done
    if [ "$RESTORED" -eq 0 ] && [ -n "$NGINX_CONF" ] && [ -f "$NGINX_CONF" ]; then
        sed -i '/shikimori/d' "$NGINX_CONF" 2>/dev/null
        log_ok "Baris shikimori dihapus dari nginx config."
    fi
    sed -i '/server_tokens off/d' /etc/nginx/nginx.conf 2>/dev/null
    if nginx -t 2>/dev/null; then
        systemctl reload nginx 2>/dev/null
        log_ok "Nginx direload — panel kembali normal."
    else
        log_err "Nginx error, cek manual: nginx -t"
    fi

    # 3. Hapus PHP Middleware
    log_info "Menghapus PHP Middleware..."
    for mw in \
        "$PTERO_DIR/app/Http/Middleware/ShikimoriV1Protect.php" \
        "$PTERO_DIR/app/Http/Middleware/ShikimoriV2Protect.php"; do
        [ -f "$mw" ] && rm -f "$mw" && log_ok "Dihapus: $(basename "$mw")"
    done

    # 4. Bersihkan Kernel.php
    KERNEL="$PTERO_DIR/app/Http/Kernel.php"
    if [ -f "$KERNEL" ]; then
        log_info "Membersihkan Kernel.php..."
        sed -i '/ShikimoriV1Protect/d' "$KERNEL" 2>/dev/null
        sed -i '/ShikimoriV2Protect/d' "$KERNEL" 2>/dev/null
        log_ok "Middleware dihapus dari Kernel.php."
    fi

    # 5. Rebuild Laravel cache
    if [ -d "$PTERO_DIR" ]; then
        log_info "Memperbarui Laravel cache..."
        cd "$PTERO_DIR" || true
        php artisan config:clear 2>/dev/null
        php artisan route:clear  2>/dev/null
        php artisan cache:clear  2>/dev/null
        php artisan config:cache 2>/dev/null
        php artisan route:cache  2>/dev/null
        log_ok "Laravel cache diperbarui — panel kembali normal."
    fi

    # 6. Kembalikan SSH config
    log_info "Mengembalikan konfigurasi SSH..."
    SSHD="/etc/ssh/sshd_config"
    if [ -f "${SSHD}.shikimori.bak" ]; then
        cp "${SSHD}.shikimori.bak" "$SSHD" && rm -f "${SSHD}.shikimori.bak"
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        log_ok "SSH config dikembalikan dari backup."
    else
        sed -i 's/^MaxAuthTries 3/#MaxAuthTries 6/'                        "$SSHD" 2>/dev/null
        sed -i 's/^LoginGraceTime 30/#LoginGraceTime 120/'                 "$SSHD" 2>/dev/null
        sed -i 's/^PermitRootLogin no/#PermitRootLogin prohibit-password/' "$SSHD" 2>/dev/null
        sed -i '/^DebianBanner no/d'                                        "$SSHD" 2>/dev/null
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        log_ok "SSH config dikembalikan ke default."
    fi

    # 7. Hapus sysctl shikimori
    log_info "Menghapus kernel hardening..."
    [ -f /etc/sysctl.d/99-shikimori.conf ] && \
        rm -f /etc/sysctl.d/99-shikimori.conf && \
        sysctl --system >/dev/null 2>&1 && \
        log_ok "Kernel rules dihapus."

    # 8. Hapus Fail2Ban config shikimori
    log_info "Membersihkan Fail2Ban..."
    [ -f /etc/fail2ban/jail.d/shikimori.conf ] && \
        rm -f /etc/fail2ban/jail.d/shikimori.conf && \
        systemctl restart fail2ban 2>/dev/null && \
        log_ok "Fail2Ban config shikimori dihapus."

    # 9. Reset UFW
    log_info "Mereset UFW..."
    ufw --force reset 2>/dev/null && ufw --force disable 2>/dev/null
    log_ok "UFW direset ke kondisi awal Ubuntu."

    # 10. Bersihkan /etc/hosts
    log_info "Membersihkan /etc/hosts..."
    for domain in \
        "ipinfo.io" "ipapi.co" "api.ipify.org" \
        "checkip.amazonaws.com" "icanhazip.com" \
        "ifconfig.me" "ip-api.com" "ipgeolocation.io" \
        "geoip.maxmind.com" "geolite.maxmind.com"; do
        sed -i "/$domain/d" /etc/hosts 2>/dev/null
    done
    log_ok "/etc/hosts dibersihkan."

    # 11. Kembalikan hostname
    log_info "Mengembalikan hostname..."
    if [ -f /etc/shikimori_original_hostname ]; then
        ORIG=$(cat /etc/shikimori_original_hostname)
        hostnamectl set-hostname "$ORIG" 2>/dev/null
        rm -f /etc/shikimori_original_hostname
        log_ok "Hostname dikembalikan: unknown → ${ORIG}"
    else
        log_warn "Ubah manual: hostnamectl set-hostname NAMA_VPS"
    fi

    # 12. Kembalikan machine-id
    if [ -f /etc/machine-id.shikimori.bak ]; then
        cp /etc/machine-id.shikimori.bak /etc/machine-id
        rm -f /etc/machine-id.shikimori.bak
        log_ok "machine-id dikembalikan."
    fi

    # 13. Hapus cron & direktori shikimori
    log_info "Membersihkan cron & file shikimori..."
    crontab -l 2>/dev/null | grep -v "console_faker.sh" | crontab - 2>/dev/null
    [ -d /opt/shikimori ] && rm -rf /opt/shikimori
    log_ok "Cron & /opt/shikimori dihapus."

    progress_bar "Menyelesaikan Uninstall..."
    echo ""
    echo -e "${GREEN}${BOLD}  ╔════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}${BOLD}  ║      ✅  SEMUA PROTEKSI BERHASIL DIHAPUS! ✅           ║${RESET}"
    echo -e "${GREEN}${BOLD}  ╚════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${CYAN}  VPS & Panel Pterodactyl kembali ke kondisi normal.${RESET}"
    echo -e "  ${CYAN}  Semua data server, database, dan file AMAN.${RESET}"
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
            read -r ;;
        2)
            install_v2
            echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"
            read -r ;;
        3)
            install_v3
            echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"
            read -r ;;
        4)
            install_v4
            echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"
            read -r ;;
        5)
            clear_screen
            echo ""
            echo -e "${MAGENTA}${BOLD}  🛡️  Terima kasih telah menggunakan SHIKIMORI PROJECT!${RESET}"
            echo -e "  ${CYAN}  Developer : t.me/vallcz${RESET}"
            echo -e "  ${CYAN}  YouTube   : KAISAR VALL${RESET}"
            echo ""
            exit 0 ;;
        6)
            uninstall_all
            echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"
            read -r ;;
        *)
            log_err "Pilihan tidak valid! Masukkan angka 1-6."
            sleep 1 ;;
    esac
done
