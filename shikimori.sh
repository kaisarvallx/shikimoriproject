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
NGINX_CONF_DIR="/etc/nginx/sites-enabled"
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
    echo -e "${MAGENTA}${BOLD}  ╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}${BOLD}  ║     🛡️  VPS PROTECTION BY - SHIKIMORI PROJECT  🛡️           ║${RESET}"
    echo -e "${MAGENTA}${BOLD}  ╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_menu() {
    echo -e "${WHITE}${BOLD}  Silahkan Pilih Tingkat Keamanan Yang Diinginkan${RESET}"
    echo -e "${YELLOW}  ────────────────────────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}[ 1 ]${RESET} Versi 1.0 - ${CYAN}Panel Pterodactyl Protect Can't Access Nest${RESET}"
    echo -e "  ${GREEN}[ 2 ]${RESET} Versi 2.0 - ${CYAN}Pterodactyl Protect Panel Cannot Access PLTA and PLTC${RESET}"
    echo -e "  ${GREEN}[ 3 ]${RESET} Versi 3.0 - ${CYAN}Panel Pterodactyl And Vps Protection With Super Hardest Protection${RESET}"
    echo -e "  ${GREEN}[ 4 ]${RESET} Versi 4.0 - ${CYAN}Shikimori Mode - Full Stealth VPS & Panel Annihilation Shield${RESET}"
    echo -e "  ${RED}[ 5 ]${RESET} Exit"
    echo -e "${YELLOW}  ────────────────────────────────────────────────────────────${RESET}"
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
    # fallback: cari file apapun di sites-enabled yang ada server_name
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
        log_err "Konfigurasi nginx ERROR! Mengembalikan backup..."
        [ -f "${NGINX_CONF}.shikimori.bak" ] && cp "${NGINX_CONF}.shikimori.bak" "$NGINX_CONF"
        nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null
    fi
}

# Daftarkan middleware ke Laravel Kernel.php
register_middleware() {
    local alias_name="$1"
    local class_name="$2"
    local kernel="$PTERO_DIR/app/Http/Kernel.php"

    [ -f "$kernel" ] || return 1

    # Cek sudah terdaftar belum
    grep -q "$alias_name" "$kernel" && return 0

    # Cari baris routeMiddleware atau middlewareAliases lalu inject
    if grep -q "routeMiddleware\|middlewareAliases" "$kernel"; then
        sed -i "/routeMiddleware\|middlewareAliases/,/\];/{
            /\];/i\\        '$alias_name' => \\\\Pterodactyl\\\\Http\\\\Middleware\\\\$class_name::class,
        }" "$kernel" 2>/dev/null
        log_ok "Middleware '$alias_name' terdaftar di Kernel.php"
    fi
}

# ============================================================
# VERSION 1.0 - BLOCK NEST, FILE MANAGER, DELETE SERVER,
#               NODES, LOCATION, API KEY VIEW
# ============================================================
install_v1() {
    clear_screen
    print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 1.0 - Nest & Panel Protection...${RESET}"
    echo -e "${YELLOW}  ────────────────────────────────────────────────────────────${RESET}"
    echo ""

    find_nginx_conf

    # ---- NGINX: Block endpoint sensitif ----
    log_info "Memasang nginx block rules..."

    if [ -n "$NGINX_CONF" ]; then
        cp "$NGINX_CONF" "${NGINX_CONF}.shikimori.bak" 2>/dev/null

        # Buat file snippet proteksi terpisah agar tidak rusak config utama
        cat > /etc/nginx/snippets/shikimori_v1.conf << 'NGINXEOF'
# ====== SHIKIMORI PROJECT V1 - NEST & PANEL PROTECTION ======

# Block Nest (egg/template management)
location ~* ^/admin/nests { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/admin/eggs  { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }

# Block File Manager (client side)
location ~* ^/api/client/servers/[^/]+/files { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }

# Block delete server dari admin & client
location ~* ^/api/application/servers/[^/]+/force { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/client/servers/[^/]+$ {
    limit_except GET POST PATCH { deny all; }
}

# Block Nodes management
location ~* ^/admin/nodes { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/application/nodes { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }

# Block Location management
location ~* ^/admin/locations { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/application/locations { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }

# Block API Key halaman (supaya tidak bisa lihat/generate API key)
location ~* ^/account/api { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/client/account/api-keys { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }

add_header X-Protected-By "Shikimori-Project" always;
NGINXEOF

        # Include snippet ke dalam server block nginx jika belum ada
        if ! grep -q "shikimori_v1" "$NGINX_CONF"; then
            # Sisipkan include sebelum baris 'location /' pertama
            sed -i '/location \//{ /shikimori/!{ 0,//{ s|location /|include /etc/nginx/snippets/shikimori_v1.conf;\n    location /| } } }' "$NGINX_CONF" 2>/dev/null || \
            # Fallback: sisipkan setelah baris server_name
            sed -i "/server_name/a\\    include /etc/nginx/snippets/shikimori_v1.conf;" "$NGINX_CONF" 2>/dev/null
        fi

        reload_nginx
    else
        log_warn "Config nginx tidak ditemukan, skip nginx block."
    fi

    # ---- PHP MIDDLEWARE: Blokir di level Laravel ----
    if check_pterodactyl; then
        MIDDLEWARE_DIR="$PTERO_DIR/app/Http/Middleware"
        mkdir -p "$MIDDLEWARE_DIR"

        cat > "$MIDDLEWARE_DIR/ShikimoriV1Protect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ShikimoriV1Protect
{
    // Pola URI yang diblokir
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

    // Method yang diblokir untuk delete server
    protected array $deleteBlocked = [
        'api/application/servers',
        'api/client/servers',
    ];

    public function handle(Request $request, Closure $next)
    {
        $path = $request->path();

        // Block URI sensitif
        foreach ($this->blocked as $pattern) {
            if (str_contains($path, $pattern)) {
                if ($request->expectsJson() || str_starts_with($path, 'api/')) {
                    return response()->json([
                        'success' => false,
                        'error'   => '🛡️ PROTECT BY SHIKIMORI PROJECT',
                    ], 403);
                }
                abort(403, '🛡️ PROTECT BY SHIKIMORI PROJECT');
            }
        }

        // Block DELETE method untuk server
        if ($request->isMethod('DELETE')) {
            foreach ($this->deleteBlocked as $pattern) {
                if (str_contains($path, $pattern)) {
                    return response()->json([
                        'success' => false,
                        'error'   => '🛡️ PROTECT BY SHIKIMORI PROJECT',
                    ], 403);
                }
            }
        }

        return $next($request);
    }
}
PHPEOF

        register_middleware "shikimori.v1" "ShikimoriV1Protect"

        # Daftarkan sebagai global middleware agar selalu aktif tanpa perlu route
        KERNEL="$PTERO_DIR/app/Http/Kernel.php"
        if [ -f "$KERNEL" ] && ! grep -q "ShikimoriV1Protect" "$KERNEL"; then
            sed -i "/protected \$middleware = \[/a\\        \\\\Pterodactyl\\\\Http\\\\Middleware\\\\ShikimoriV1Protect::class," "$KERNEL" 2>/dev/null
            log_ok "Middleware V1 didaftarkan sebagai global middleware."
        fi

        # Clear cache Laravel supaya middleware langsung aktif
        cd "$PTERO_DIR" && php artisan config:cache 2>/dev/null && php artisan route:cache 2>/dev/null
        log_ok "Laravel cache diperbarui."
    fi

    progress_bar "Menginstall V1 Protection..."

    echo ""
    log_ok "Proteksi V1 AKTIF! Yang diblokir:"
    echo -e "  ${GREEN}  ✅ Nest & Eggs (template server)${RESET}"
    echo -e "  ${GREEN}  ✅ File Manager${RESET}"
    echo -e "  ${GREEN}  ✅ Delete Server${RESET}"
    echo -e "  ${GREEN}  ✅ Nodes Management${RESET}"
    echo -e "  ${GREEN}  ✅ Location Management${RESET}"
    echo -e "  ${GREEN}  ✅ API Key View & Generate${RESET}"
    echo ""

    print_success
}

# ============================================================
# VERSION 2.0 - BLOCK PLTA & PLTC ONLY
# PLTA = Power Limit Type A (CPU/RAM allocation limit)
# PLTC = Power Limit Type C (custom resource cap)
# Implementasi: block endpoint allocation & resource limits
# ============================================================
install_v2() {
    clear_screen
    print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 2.0 - PLTA & PLTC Protection...${RESET}"
    echo -e "${YELLOW}  ────────────────────────────────────────────────────────────${RESET}"
    echo ""

    find_nginx_conf

    # ---- NGINX: Block allocation & resource limit endpoints ----
    log_info "Memasang nginx block untuk PLTA & PLTC..."

    cat > /etc/nginx/snippets/shikimori_v2.conf << 'NGINXEOF'
# ====== SHIKIMORI PROJECT V2 - PLTA & PLTC PROTECTION ======

# PLTA = block akses ke allocation (port allocation = power limit type A)
location ~* ^/api/application/nodes/[^/]+/allocations { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/client/servers/[^/]+/network/allocations { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/admin/nodes/view/[^/]+/allocation { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }

# PLTC = block akses ke build/resource cap settings
location ~* ^/api/application/servers/[^/]+/build { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/client/servers/[^/]+/resources { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/admin/servers/view/[^/]+/build { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }

add_header X-Protected-By "Shikimori-Project-V2" always;
NGINXEOF

    if [ -n "$NGINX_CONF" ]; then
        cp "$NGINX_CONF" "${NGINX_CONF}.shikimori.v2.bak" 2>/dev/null

        if ! grep -q "shikimori_v2" "$NGINX_CONF"; then
            sed -i "/server_name/a\\    include /etc/nginx/snippets/shikimori_v2.conf;" "$NGINX_CONF" 2>/dev/null
        fi

        reload_nginx
    fi

    # ---- PHP MIDDLEWARE: Block di level Laravel ----
    if check_pterodactyl; then
        MIDDLEWARE_DIR="$PTERO_DIR/app/Http/Middleware"
        mkdir -p "$MIDDLEWARE_DIR"

        cat > "$MIDDLEWARE_DIR/ShikimoriV2Protect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ShikimoriV2Protect
{
    // PLTA = Allocation endpoints
    // PLTC = Build/resource limit endpoints
    protected array $blocked = [
        'allocations',
        '/build',
        'server-resources',
        'resources',
        'nodes/view',
        'servers/view',
    ];

    // Khusus blokir PUT/PATCH ke build (resource cap changes)
    protected array $methodBlocked = [
        'api/application/servers',
        'api/client/servers',
    ];

    public function handle(Request $request, Closure $next)
    {
        $path = $request->path();

        foreach ($this->blocked as $pattern) {
            if (str_contains($path, $pattern)) {
                if ($request->expectsJson() || str_starts_with($path, 'api/')) {
                    return response()->json([
                        'success' => false,
                        'error'   => '🛡️ PROTECT BY SHIKIMORI PROJECT',
                    ], 403);
                }
                abort(403, '🛡️ PROTECT BY SHIKIMORI PROJECT');
            }
        }

        // Block perubahan resource (PUT/PATCH) ke server build
        if (in_array($request->method(), ['PUT', 'PATCH'])) {
            foreach ($this->methodBlocked as $pattern) {
                if (str_contains($path, $pattern) && str_contains($path, 'build')) {
                    return response()->json([
                        'success' => false,
                        'error'   => '🛡️ PROTECT BY SHIKIMORI PROJECT',
                    ], 403);
                }
            }
        }

        return $next($request);
    }
}
PHPEOF

        KERNEL="$PTERO_DIR/app/Http/Kernel.php"
        if [ -f "$KERNEL" ] && ! grep -q "ShikimoriV2Protect" "$KERNEL"; then
            sed -i "/protected \$middleware = \[/a\\        \\\\Pterodactyl\\\\Http\\\\Middleware\\\\ShikimoriV2Protect::class," "$KERNEL" 2>/dev/null
            log_ok "Middleware V2 didaftarkan sebagai global middleware."
        fi

        cd "$PTERO_DIR" && php artisan config:cache 2>/dev/null && php artisan route:cache 2>/dev/null
        log_ok "Laravel cache diperbarui."
    fi

    progress_bar "Menginstall V2 PLTA & PLTC Protection..."

    echo ""
    log_ok "Proteksi V2 AKTIF! Yang diblokir:"
    echo -e "  ${GREEN}  ✅ PLTA - Allocation access (node port limits)${RESET}"
    echo -e "  ${GREEN}  ✅ PLTC - Build/Resource cap settings${RESET}"
    echo -e "  ${GREEN}  ✅ Semua akses ke panel allocation & build settings${RESET}"
    echo ""

    print_success
}

# ============================================================
# VERSION 3.0 - SUPER HARDEST: V1 + V2 + VPS HARDENING
# ============================================================
install_v3() {
    clear_screen
    print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 3.0 - Super Hardest Protection...${RESET}"
    echo -e "${YELLOW}  ────────────────────────────────────────────────────────────${RESET}"
    echo ""
    echo -e "  ${RED}${BOLD}[!] Mode ini menginstall V1 + V2 + VPS hardening penuh!${RESET}"
    echo ""
    sleep 1

    # Install V1 dan V2 terlebih dahulu (tanpa print_success)
    log_info "Menjalankan proteksi V1..."
    find_nginx_conf

    # V1 nginx
    if [ -n "$NGINX_CONF" ]; then
        cp "$NGINX_CONF" "${NGINX_CONF}.shikimori.bak" 2>/dev/null
        cat > /etc/nginx/snippets/shikimori_v1.conf << 'NGINXEOF'
# ====== SHIKIMORI PROJECT V1 ======
location ~* ^/admin/nests { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/admin/eggs  { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/client/servers/[^/]+/files { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/admin/nodes { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/application/nodes { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/admin/locations { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/application/locations { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/account/api { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/client/account/api-keys { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
NGINXEOF
        ! grep -q "shikimori_v1" "$NGINX_CONF" && \
            sed -i "/server_name/a\\    include /etc/nginx/snippets/shikimori_v1.conf;" "$NGINX_CONF" 2>/dev/null
    fi

    # V2 nginx
    cat > /etc/nginx/snippets/shikimori_v2.conf << 'NGINXEOF'
# ====== SHIKIMORI PROJECT V2 ======
location ~* ^/api/application/nodes/[^/]+/allocations { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/client/servers/[^/]+/network/allocations { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/admin/nodes/view/[^/]+/allocation { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/application/servers/[^/]+/build { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/client/servers/[^/]+/resources { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/admin/servers/view/[^/]+/build { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
NGINXEOF
    ! grep -q "shikimori_v2" "$NGINX_CONF" 2>/dev/null && [ -n "$NGINX_CONF" ] && \
        sed -i "/server_name/a\\    include /etc/nginx/snippets/shikimori_v2.conf;" "$NGINX_CONF" 2>/dev/null

    reload_nginx
    log_ok "Proteksi V1 & V2 dipasang."

    # Middleware PHP V1+V2
    if check_pterodactyl; then
        MIDDLEWARE_DIR="$PTERO_DIR/app/Http/Middleware"
        mkdir -p "$MIDDLEWARE_DIR"

        # Tulis middleware gabungan V1+V2
        cat > "$MIDDLEWARE_DIR/ShikimoriV1Protect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;
use Closure;
use Illuminate\Http\Request;
class ShikimoriV1Protect {
    protected array $blocked = ['admin/nests','admin/eggs','admin/nodes','admin/locations','account/api','/files','api-keys','api/application/nodes','api/application/locations','api/client/account/api-keys'];
    protected array $deleteBlocked = ['api/application/servers','api/client/servers'];
    public function handle(Request $request, Closure $next) {
        $path = $request->path();
        foreach ($this->blocked as $p) {
            if (str_contains($path, $p)) {
                if ($request->expectsJson() || str_starts_with($path, 'api/'))
                    return response()->json(['success'=>false,'error'=>'🛡️ PROTECT BY SHIKIMORI PROJECT'],403);
                abort(403,'🛡️ PROTECT BY SHIKIMORI PROJECT');
            }
        }
        if ($request->isMethod('DELETE'))
            foreach ($this->deleteBlocked as $p)
                if (str_contains($path,$p))
                    return response()->json(['success'=>false,'error'=>'🛡️ PROTECT BY SHIKIMORI PROJECT'],403);
        return $next($request);
    }
}
PHPEOF

        cat > "$MIDDLEWARE_DIR/ShikimoriV2Protect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;
use Closure;
use Illuminate\Http\Request;
class ShikimoriV2Protect {
    protected array $blocked = ['allocations','/build','server-resources','resources','nodes/view','servers/view'];
    public function handle(Request $request, Closure $next) {
        $path = $request->path();
        foreach ($this->blocked as $p) {
            if (str_contains($path, $p)) {
                if ($request->expectsJson() || str_starts_with($path, 'api/'))
                    return response()->json(['success'=>false,'error'=>'🛡️ PROTECT BY SHIKIMORI PROJECT'],403);
                abort(403,'🛡️ PROTECT BY SHIKIMORI PROJECT');
            }
        }
        if (in_array($request->method(),['PUT','PATCH']))
            if (str_contains($path,'api/application/servers') && str_contains($path,'build'))
                return response()->json(['success'=>false,'error'=>'🛡️ PROTECT BY SHIKIMORI PROJECT'],403);
        return $next($request);
    }
}
PHPEOF

        KERNEL="$PTERO_DIR/app/Http/Kernel.php"
        [ -f "$KERNEL" ] && ! grep -q "ShikimoriV1Protect" "$KERNEL" && \
            sed -i "/protected \$middleware = \[/a\\        \\\\Pterodactyl\\\\Http\\\\Middleware\\\\ShikimoriV1Protect::class," "$KERNEL" 2>/dev/null
        [ -f "$KERNEL" ] && ! grep -q "ShikimoriV2Protect" "$KERNEL" && \
            sed -i "/protected \$middleware = \[/a\\        \\\\Pterodactyl\\\\Http\\\\Middleware\\\\ShikimoriV2Protect::class," "$KERNEL" 2>/dev/null

        cd "$PTERO_DIR" && php artisan config:cache 2>/dev/null && php artisan route:cache 2>/dev/null
    fi

    # ---- VPS HARDENING ----
    echo ""
    log_info "Memulai VPS hardening..."

    # SSH Hardening - HANYA config, tidak disable password (agar tidak lockout)
    SSHD="/etc/ssh/sshd_config"
    if [ -f "$SSHD" ]; then
        cp "$SSHD" "${SSHD}.shikimori.bak"
        # Batasi max auth tries
        sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' "$SSHD"
        # Sembunyikan banner provider
        sed -i 's/^#*DebianBanner.*/DebianBanner no/' "$SSHD"
        grep -q "DebianBanner" "$SSHD" || echo "DebianBanner no" >> "$SSHD"
        # Matikan root login
        sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSHD"
        # Login timeout 30 detik
        sed -i 's/^#*LoginGraceTime.*/LoginGraceTime 30/' "$SSHD"
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        log_ok "SSH hardening selesai."
    fi

    # Sysctl network hardening (TIDAK sentuh memory/swap - supaya panel tidak lag)
    log_info "Mengkonfigurasi kernel network hardening..."
    cat > /etc/sysctl.d/99-shikimori.conf << 'SYSCTLEOF'
# SHIKIMORI PROJECT - Network Hardening
# Anti SYN flood
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_max_syn_backlog = 2048
# Anti IP spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
# Block ICMP redirect
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
# Ignore broadcast ping
net.ipv4.icmp_echo_ignore_broadcasts = 1
# Matikan TCP timestamps (anti fingerprinting)
net.ipv4.tcp_timestamps = 0
SYSCTLEOF
    sysctl -p /etc/sysctl.d/99-shikimori.conf 2>/dev/null
    log_ok "Kernel network hardening selesai."

    # Fail2Ban
    log_info "Menginstall & konfigurasi Fail2Ban..."
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

    # UFW - hanya allow yang dibutuhkan, JANGAN block 80/443 (supaya panel tidak lag)
    log_info "Mengkonfigurasi UFW firewall..."
    ufw --force reset 2>/dev/null
    ufw default deny incoming 2>/dev/null
    ufw default allow outgoing 2>/dev/null
    ufw allow 22/tcp   comment 'SSH'      2>/dev/null
    ufw allow 80/tcp   comment 'HTTP'     2>/dev/null
    ufw allow 443/tcp  comment 'HTTPS'    2>/dev/null
    ufw allow 8080/tcp comment 'Wings'    2>/dev/null
    ufw allow 2022/tcp comment 'SFTP'     2>/dev/null
    ufw --force enable 2>/dev/null
    log_ok "UFW aktif dengan rules minimal yang benar."

    progress_bar "Menginstall Super Hardest Protection..."

    echo ""
    log_ok "Proteksi V3 AKTIF! Ringkasan:"
    echo -e "  ${GREEN}  ✅ Semua proteksi V1 & V2${RESET}"
    echo -e "  ${GREEN}  ✅ SSH hardening (MaxAuthTries=3, no root login)${RESET}"
    echo -e "  ${GREEN}  ✅ Kernel anti-flood & anti-fingerprint${RESET}"
    echo -e "  ${GREEN}  ✅ Fail2Ban (SSH ban 24 jam, nginx ban 1 jam)${RESET}"
    echo -e "  ${GREEN}  ✅ UFW firewall (hanya port yang dibutuhkan)${RESET}"
    echo ""

    print_success
}

# ============================================================
# VERSION 4.0 - SHIKIMORI MODE
# V1 + V2 + V3 + Identity Masking + Console Log Faker
# ============================================================
install_v4() {
    clear_screen
    print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 4.0 - SHIKIMORI MODE...${RESET}"
    echo -e "${YELLOW}  ────────────────────────────────────────────────────────────${RESET}"
    echo ""
    echo -e "  ${RED}${BOLD}[!!!] SHIKIMORI MODE - PROTEKSI LEVEL TERTINGGI AKTIF!!!${RESET}"
    echo ""
    sleep 1

    # Jalankan V3 (sudah include V1+V2) tanpa exit
    # Panggil fungsi install_v3 tapi skip print_success-nya
    # Kita re-setup semua agar bersih

    find_nginx_conf

    # ---- PASANG SEMUA NGINX SNIPPETS V1 + V2 ----
    log_info "Memasang semua nginx protection rules..."

    mkdir -p /etc/nginx/snippets

    cat > /etc/nginx/snippets/shikimori_v1.conf << 'NGINXEOF'
location ~* ^/admin/nests { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/admin/eggs  { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/client/servers/[^/]+/files { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/admin/nodes { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/application/nodes { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/admin/locations { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/application/locations { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/account/api { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/client/account/api-keys { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
NGINXEOF

    cat > /etc/nginx/snippets/shikimori_v2.conf << 'NGINXEOF'
location ~* ^/api/application/nodes/[^/]+/allocations { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/client/servers/[^/]+/network/allocations { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/admin/nodes/view/[^/]+/allocation { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/application/servers/[^/]+/build { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/api/client/servers/[^/]+/resources { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
location ~* ^/admin/servers/view/[^/]+/build { return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}'; }
NGINXEOF

    if [ -n "$NGINX_CONF" ]; then
        cp "$NGINX_CONF" "${NGINX_CONF}.shikimori.bak" 2>/dev/null
        ! grep -q "shikimori_v1" "$NGINX_CONF" && \
            sed -i "/server_name/a\\    include /etc/nginx/snippets/shikimori_v1.conf;" "$NGINX_CONF" 2>/dev/null
        ! grep -q "shikimori_v2" "$NGINX_CONF" && \
            sed -i "/server_name/a\\    include /etc/nginx/snippets/shikimori_v2.conf;" "$NGINX_CONF" 2>/dev/null
        reload_nginx
    fi

    # ---- MIDDLEWARE PHP ----
    if check_pterodactyl; then
        MIDDLEWARE_DIR="$PTERO_DIR/app/Http/Middleware"
        mkdir -p "$MIDDLEWARE_DIR"

        cat > "$MIDDLEWARE_DIR/ShikimoriV1Protect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;
use Closure; use Illuminate\Http\Request;
class ShikimoriV1Protect {
    protected array $blocked = ['admin/nests','admin/eggs','admin/nodes','admin/locations','account/api','/files','api-keys','api/application/nodes','api/application/locations','api/client/account/api-keys'];
    protected array $deleteBlocked = ['api/application/servers','api/client/servers'];
    public function handle(Request $request, Closure $next) {
        $path = $request->path();
        foreach ($this->blocked as $p) { if (str_contains($path,$p)) { if($request->expectsJson()||str_starts_with($path,'api/')) return response()->json(['success'=>false,'error'=>'🛡️ PROTECT BY SHIKIMORI PROJECT'],403); abort(403,'🛡️ PROTECT BY SHIKIMORI PROJECT'); } }
        if ($request->isMethod('DELETE')) foreach($this->deleteBlocked as $p) if(str_contains($path,$p)) return response()->json(['success'=>false,'error'=>'🛡️ PROTECT BY SHIKIMORI PROJECT'],403);
        return $next($request);
    }
}
PHPEOF

        cat > "$MIDDLEWARE_DIR/ShikimoriV2Protect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;
use Closure; use Illuminate\Http\Request;
class ShikimoriV2Protect {
    protected array $blocked = ['allocations','/build','server-resources','resources'];
    public function handle(Request $request, Closure $next) {
        $path = $request->path();
        foreach ($this->blocked as $p) { if (str_contains($path,$p)) { if($request->expectsJson()||str_starts_with($path,'api/')) return response()->json(['success'=>false,'error'=>'🛡️ PROTECT BY SHIKIMORI PROJECT'],403); abort(403,'🛡️ PROTECT BY SHIKIMORI PROJECT'); } }
        if (in_array($request->method(),['PUT','PATCH']) && str_contains($path,'build')) return response()->json(['success'=>false,'error'=>'🛡️ PROTECT BY SHIKIMORI PROJECT'],403);
        return $next($request);
    }
}
PHPEOF

        KERNEL="$PTERO_DIR/app/Http/Kernel.php"
        [ -f "$KERNEL" ] && ! grep -q "ShikimoriV1Protect" "$KERNEL" && \
            sed -i "/protected \$middleware = \[/a\\        \\\\Pterodactyl\\\\Http\\\\Middleware\\\\ShikimoriV1Protect::class," "$KERNEL" 2>/dev/null
        [ -f "$KERNEL" ] && ! grep -q "ShikimoriV2Protect" "$KERNEL" && \
            sed -i "/protected \$middleware = \[/a\\        \\\\Pterodactyl\\\\Http\\\\Middleware\\\\ShikimoriV2Protect::class," "$KERNEL" 2>/dev/null
        cd "$PTERO_DIR" && php artisan config:cache 2>/dev/null && php artisan route:cache 2>/dev/null
    fi

    log_ok "Proteksi V1 + V2 dipasang."

    # ---- VPS HARDENING (sama dengan V3) ----
    log_info "Menerapkan VPS hardening..."

    SSHD="/etc/ssh/sshd_config"
    if [ -f "$SSHD" ]; then
        cp "$SSHD" "${SSHD}.shikimori.bak" 2>/dev/null
        sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' "$SSHD"
        sed -i 's/^#*DebianBanner.*/DebianBanner no/' "$SSHD"
        grep -q "DebianBanner" "$SSHD" || echo "DebianBanner no" >> "$SSHD"
        sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSHD"
        sed -i 's/^#*LoginGraceTime.*/LoginGraceTime 30/' "$SSHD"
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
    fi

    cat > /etc/sysctl.d/99-shikimori.conf << 'SYSCTLEOF'
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
SYSCTLEOF
    sysctl -p /etc/sysctl.d/99-shikimori.conf 2>/dev/null
    log_ok "VPS hardening selesai."

    # Fail2Ban
    apt-get install -y -q fail2ban 2>/dev/null
    cat > /etc/fail2ban/jail.d/shikimori.conf << 'F2BEOF'
[sshd]
enabled = true
maxretry = 3
bantime = 86400
findtime = 600
[nginx-http-auth]
enabled = true
maxretry = 5
bantime = 3600
F2BEOF
    systemctl enable fail2ban 2>/dev/null && systemctl restart fail2ban 2>/dev/null
    log_ok "Fail2Ban aktif."

    ufw --force reset 2>/dev/null
    ufw default deny incoming 2>/dev/null
    ufw default allow outgoing 2>/dev/null
    ufw allow 22/tcp 2>/dev/null
    ufw allow 80/tcp 2>/dev/null
    ufw allow 443/tcp 2>/dev/null
    ufw allow 8080/tcp 2>/dev/null
    ufw allow 2022/tcp 2>/dev/null
    ufw --force enable 2>/dev/null
    log_ok "UFW aktif."

    # ---- SHIKIMORI MODE EXCLUSIVE: IDENTITY MASKING ----
    echo ""
    log_info "Mengaktifkan Identity Masking (Shikimori Mode exclusive)..."

    # Block IP info lookup domains di /etc/hosts
    HOSTS_BLOCK=(
        "ipinfo.io"
        "ipapi.co"
        "api.ipify.org"
        "checkip.amazonaws.com"
        "icanhazip.com"
        "ifconfig.me"
        "ip-api.com"
        "ipgeolocation.io"
        "geoip.maxmind.com"
        "geolite.maxmind.com"
    )
    for domain in "${HOSTS_BLOCK[@]}"; do
        grep -q "$domain" /etc/hosts || echo "0.0.0.0 $domain" >> /etc/hosts
    done
    log_ok "Domain IP-lookup diblokir via /etc/hosts"

    # Spoof hostname sistem
    OLD_HOSTNAME=$(hostname)
    hostnamectl set-hostname "unknown" 2>/dev/null || echo "unknown" > /etc/hostname
    log_ok "Hostname diubah: ${OLD_HOSTNAME} → unknown"

    # Spoof /etc/machine-id
    if [ -f /etc/machine-id ]; then
        cp /etc/machine-id /etc/machine-id.shikimori.bak
        echo "00000000000000000000000000000000" > /etc/machine-id
    fi

    # ---- CONSOLE LOG FAKER ----
    log_info "Memasang Console Log Faker..."

    mkdir -p /opt/shikimori

    cat > /opt/shikimori/console_faker.sh << 'FAKEEOF'
#!/bin/bash
# Shikimori Project - Console Log Faker
# Menyamarkan info sensitif di log Pterodactyl

LOG_DIRS=(
    "/var/log/pterodactyl"
    "/var/www/pterodactyl/storage/logs"
)

for dir in "${LOG_DIRS[@]}"; do
    [ -d "$dir" ] || continue
    find "$dir" -name "*.log" -type f 2>/dev/null | while read -r logfile; do
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
            "$logfile" 2>/dev/null
    done
done
FAKEEOF
    chmod +x /opt/shikimori/console_faker.sh

    # Crontab setiap menit
    (crontab -l 2>/dev/null | grep -v "console_faker"; echo "* * * * * /opt/shikimori/console_faker.sh") | crontab -
    log_ok "Console Log Faker aktif (tiap menit via cron)."

    # ---- NGINX: Sembunyikan server signature ----
    if ! grep -q "server_tokens off" /etc/nginx/nginx.conf 2>/dev/null; then
        sed -i '/http {/a\\    server_tokens off;' /etc/nginx/nginx.conf 2>/dev/null
        reload_nginx
    fi
    log_ok "Nginx server signature disembunyikan."

    progress_bar "Menginstall SHIKIMORI MODE..."

    echo ""
    echo -e "${MAGENTA}${BOLD}  ╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}${BOLD}  ║    🛡️  SHIKIMORI MODE BERHASIL DIAKTIFKAN! 🛡️      ║${RESET}"
    echo -e "${MAGENTA}${BOLD}  ╚════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${CYAN}Ringkasan Shikimori Mode:${RESET}"
    echo -e "  ${GREEN}  ✅ V1 - Nest, File, Node, Location, API Key${RESET}"
    echo -e "  ${GREEN}  ✅ V2 - PLTA & PLTC (Allocation & Build)${RESET}"
    echo -e "  ${GREEN}  ✅ V3 - SSH Hardening, Fail2Ban, UFW${RESET}"
    echo -e "  ${GREEN}  ✅ Hostname → unknown${RESET}"
    echo -e "  ${GREEN}  ✅ Provider → Unknown${RESET}"
    echo -e "  ${GREEN}  ✅ Region → N/A${RESET}"
    echo -e "  ${GREEN}  ✅ IP Detection sites → DIBLOKIR${RESET}"
    echo -e "  ${GREEN}  ✅ Console Log Faker → AKTIF (tiap menit)${RESET}"
    echo -e "  ${GREEN}  ✅ Nginx signature → DISEMBUNYIKAN${RESET}"
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
        *)
            log_err "Pilihan tidak valid! Masukkan angka 1-5."
            sleep 1
            ;;
    esac
done
