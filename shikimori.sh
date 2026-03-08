#!/bin/bash

# ============================================================
#   SHIKIMORI PROJECT - VPS & PTERODACTYL PROTECTION
#   Developer : t.me/vallcz | YouTube : KAISAR VALL
#   Target    : Ubuntu 22.04 + Nginx + Pterodactyl
#
#   UPGRADE: Block cloud-init user-data, /proc environ,
#            provider info, public IP dari console log
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
# BLOCK CLOUD-INIT & USER-DATA
# Ini yang menyebabkan Provider, Password, Public IP bocor
# di console log Pterodactyl
# ============================================================
block_cloud_init() {
    log_info "Memblokir akses cloud-init & user-data..."

    # 1. Blokir metadata endpoint DigitalOcean/AWS/GCP/Vultr
    #    Script bot membaca dari http://169.254.169.254/latest/user-data
    #    atau http://169.254.169.254/metadata/v1/user-data (DO)
    METADATA_IP="169.254.169.254"

    # Blokir via iptables OUTPUT (container tidak bisa baca metadata)
    iptables -I OUTPUT -d "$METADATA_IP" -j DROP 2>/dev/null
    ip6tables -I OUTPUT -d "$METADATA_IP" -j DROP 2>/dev/null

    # Simpan iptables supaya persist setelah reboot
    mkdir -p /etc/iptables
    iptables-save > /etc/iptables/rules.v4 2>/dev/null

    # Install iptables-persistent agar rules survive reboot
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q iptables-persistent 2>/dev/null

    log_ok "Metadata endpoint ($METADATA_IP) DIBLOKIR via iptables."

    # 2. Kosongkan & kunci cloud-init user-data
    #    File ini berisi password root & konfigurasi awal VPS
    for f in \
        /var/lib/cloud/instance/user-data.txt \
        /var/lib/cloud/instance/user-data.txt.i \
        /var/lib/cloud/instances/*/user-data.txt \
        /var/lib/cloud/seed/nocloud/user-data \
        /run/cloud-init/instance-data.json \
        /run/cloud-init/instance-data-sensitive.json; do
        if [ -f "$f" ]; then
            # Backup dulu
            cp "$f" "${f}.shikimori.bak" 2>/dev/null
            # Kosongkan isinya
            echo "# PROTECTED BY SHIKIMORI PROJECT" > "$f"
            # Kunci file (tidak bisa dibaca/ditulis siapapun kecuali root)
            chmod 000 "$f" 2>/dev/null
            chattr +i "$f" 2>/dev/null
            log_ok "Dikosongkan & dikunci: $f"
        fi
    done

    # 3. Kunci seluruh direktori cloud-init instance
    if [ -d /var/lib/cloud/instance ]; then
        chmod 700 /var/lib/cloud/instance 2>/dev/null
        chmod 700 /var/lib/cloud/instances 2>/dev/null
        log_ok "Direktori cloud-init dikunci (chmod 700)."
    fi

    # 4. Matikan layanan cloud-init agar tidak bisa dijalankan ulang
    systemctl stop cloud-init 2>/dev/null
    systemctl disable cloud-init 2>/dev/null
    systemctl stop cloud-init-local 2>/dev/null
    systemctl disable cloud-init-local 2>/dev/null
    systemctl stop cloud-config 2>/dev/null
    systemctl disable cloud-config 2>/dev/null
    systemctl stop cloud-final 2>/dev/null
    systemctl disable cloud-final 2>/dev/null
    log_ok "Layanan cloud-init dinonaktifkan."

    # 5. Blokir akses /proc/1/environ dari dalam container
    #    Script bot juga membaca environment variable dari /proc
    #    Kita pasang wrapper yang memalsukan outputnya
    if [ -f /proc/1/environ ]; then
        # Tidak bisa langsung edit /proc, tapi kita bisa
        # set environment variable palsu di systemd wings
        WINGS_ENV="/etc/systemd/system/wings.service.d"
        mkdir -p "$WINGS_ENV"
        cat > "$WINGS_ENV/shikimori-env.conf" << 'ENVEOF'
[Service]
# SHIKIMORI PROJECT - Override env vars yang bisa bocorkan info VPS
Environment="DIGITALOCEAN_ACCESS_TOKEN="
Environment="DO_ACCESS_TOKEN="
Environment="VULTR_API_KEY="
Environment="AWS_ACCESS_KEY_ID="
Environment="AWS_SECRET_ACCESS_KEY="
Environment="GCE_SERVICE_ACCOUNT="
Environment="PROVIDER=Unknown"
Environment="CLOUD_PROVIDER=Unknown"
Environment="DATACENTER=Unknown"
Environment="REGION=Unknown"
ENVEOF
        systemctl daemon-reload 2>/dev/null
        log_ok "Wings environment vars dioverride."
    fi

    # 6. Hapus/kosongkan file yang bisa dibaca bot untuk cari info VPS
    for sensitive_file in \
        /etc/digitalocean \
        /etc/vultr \
        /etc/do-agent \
        /var/lib/cloud/instance/datasource; do
        if [ -f "$sensitive_file" ]; then
            cp "$sensitive_file" "${sensitive_file}.shikimori.bak" 2>/dev/null
            echo "unknown" > "$sensitive_file"
            chmod 000 "$sensitive_file" 2>/dev/null
            log_ok "File provider dikosongkan: $sensitive_file"
        fi
    done

    log_ok "Semua sumber bocoran Provider/IP/Password DIBLOKIR."
}

# ============================================================
# NGINX SNIPPET V1
# ✅ File Manager BEBAS untuk user panel
# 🔒 Blokir: Nest, Eggs, Nodes, Locations, API Key, Delete Server
# 🔒 Bot luar tanpa sesi = ditolak di file endpoint
# ============================================================
write_nginx_v1() {
    mkdir -p /etc/nginx/snippets
    cat > /etc/nginx/snippets/shikimori_v1.conf << 'NGINXEOF'
# ====== SHIKIMORI PROJECT V1 ======

location ~* ^/admin/nests {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/admin/eggs {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/admin/nodes {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/api/application/nodes {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/admin/locations {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/api/application/locations {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/account/api {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
location ~* ^/api/client/account/api-keys {
    return 403 '{"success":false,"error":"🛡️ PROTECT BY SHIKIMORI PROJECT"}';
    add_header Content-Type "application/json" always;
}
NGINXEOF
}

# ============================================================
# NGINX SNIPPET V2 - PLTA & PLTC
# ============================================================
write_nginx_v2() {
    mkdir -p /etc/nginx/snippets
    cat > /etc/nginx/snippets/shikimori_v2.conf << 'NGINXEOF'
# ====== SHIKIMORI PROJECT V2 - PLTA & PLTC ======

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
# MIDDLEWARE V1 - PHP Laravel
# ============================================================
write_middleware_v1() {
    local dir="$1"
    cat > "$dir/ShikimoriV1Protect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ShikimoriV1Protect
{
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

    protected array $deleteBlocked = [
        'api/application/servers',
    ];

    public function handle(Request $request, Closure $next)
    {
        $path = $request->path();

        foreach ($this->alwaysBlocked as $p) {
            if (str_contains($path, $p)) {
                return $this->deny($request);
            }
        }

        if ($request->isMethod('DELETE')) {
            foreach ($this->deleteBlocked as $p) {
                if (str_contains($path, $p)) {
                    return $this->deny($request);
                }
            }
        }

        // File endpoint: izinkan user panel, blokir bot tanpa auth
        if (str_contains($path, '/files')) {
            $hasAuth = $request->bearerToken() !== null
                || $request->hasCookie('pterodactyl_session')
                || $request->user() !== null;
            if (!$hasAuth) {
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
# MIDDLEWARE V2 - PHP Laravel
# ============================================================
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
# INTERNAL: Setup V1 + V2
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
# SHIKIMORI - Network Hardening
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
    log_ok "Fail2Ban aktif."

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
    log_ok "UFW aktif — port 80/443/8080 terbuka."
}

# ============================================================
# INTERNAL: Identity Masking + Console Log Faker
# ============================================================
_setup_identity_masking() {
    log_info "Mengaktifkan Identity Masking..."

    # Block domain IP-lookup
    HOSTS_BLOCK=(
        "ipinfo.io" "ipapi.co" "api.ipify.org"
        "checkip.amazonaws.com" "icanhazip.com"
        "ifconfig.me" "ip-api.com" "ipgeolocation.io"
        "geoip.maxmind.com" "geolite.maxmind.com"
        "metadata.digitalocean.com"
        "169.254.169.254"
    )
    for domain in "${HOSTS_BLOCK[@]}"; do
        grep -q "$domain" /etc/hosts 2>/dev/null || echo "0.0.0.0 $domain" >> /etc/hosts
    done
    log_ok "Domain IP-lookup & metadata diblokir via /etc/hosts."

    # Spoof hostname
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

    # Console Log Faker
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
            -e 's/Provider\s*:\s*[a-zA-Z0-9]*/Provider   : Unknown/g' \
            -e 's/provider: [A-Za-z0-9 .,_-]*/provider: Unknown/g' \
            -e 's/"hostname":"[^"]*"/"hostname":"unknown"/g' \
            -e 's/hostname: [A-Za-z0-9._-]*/hostname: unknown/g' \
            -e 's/Public IP\s*:\s*[0-9.]\+/Public IP  : N\/A/g' \
            -e 's/Public IP\s*:\s*[0-9a-fA-F:]\+/Public IP  : N\/A/g' \
            -e 's/"region":"[^"]*"/"region":"N\/A"/g' \
            -e 's/"country":"[^"]*"/"country":"N\/A"/g' \
            -e 's/"city":"[^"]*"/"city":"N\/A"/g' \
            -e 's/"org":"[^"]*"/"org":"Unknown"/g' \
            -e 's/"isp":"[^"]*"/"isp":"Unknown"/g' \
            -e 's/User Data\s*:.*$/User Data  : PROTECTED/g' \
            "$f" 2>/dev/null
    done
done
FAKEEOF
    chmod +x /opt/shikimori/console_faker.sh
    (crontab -l 2>/dev/null | grep -v "console_faker.sh"; \
        echo "* * * * * /opt/shikimori/console_faker.sh") | crontab -
    log_ok "Console Log Faker aktif (tiap menit via cron)."
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
    echo -e "  ${GREEN}  ✅ File Manager BEBAS — upload/download/running bot aman${RESET}"
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
    echo -e "  ${RED}  🔒 DIBLOKIR:${RESET}"
    echo -e "  ${RED}     ✖  Nest & Eggs, Nodes, Locations, API Keys${RESET}"
    echo -e "  ${RED}     ✖  Delete Server${RESET}"
    echo -e "  ${RED}     ✖  Bot luar tanpa sesi ke file endpoint${RESET}"
    echo ""
    echo -e "  ${GREEN}  ✅ BEBAS DIAKSES:${RESET}"
    echo -e "  ${GREEN}     ✔  File Manager (upload/download/running bot)${RESET}"
    echo -e "  ${GREEN}     ✔  Console, Start/Stop/Restart server${RESET}"
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
    echo -e "  ${RED}  🔒 DIBLOKIR:${RESET}"
    echo -e "  ${RED}     ✖  PLTA — Allocation / port limits${RESET}"
    echo -e "  ${RED}     ✖  PLTC — Build / resource cap settings${RESET}"
    echo ""
    echo -e "  ${GREEN}  ✅ BEBAS DIAKSES:${RESET}"
    echo -e "  ${GREEN}     ✔  File Manager (upload/download/running bot)${RESET}"
    echo -e "  ${GREEN}     ✔  Console, Start/Stop/Restart${RESET}"
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
    echo -e "  ${GREEN}  ✅ File Manager BEBAS untuk user panel${RESET}"
    echo -e "  ${RED}${BOLD}  [!] Menginstall V1 + V2 + VPS Hardening!${RESET}"
    echo ""
    sleep 1

    _setup_v1v2
    echo ""
    _setup_vps_hardening

    progress_bar "Menginstall Super Hardest Protection..."
    echo ""
    log_ok "Proteksi V3 AKTIF!"
    echo ""
    echo -e "  ${RED}  🔒 DIBLOKIR:${RESET}"
    echo -e "  ${RED}     ✖  Nest, Eggs, Nodes, Locations, API Keys${RESET}"
    echo -e "  ${RED}     ✖  PLTA & PLTC, Delete Server${RESET}"
    echo -e "  ${RED}     ✖  Brute force SSH (auto ban 24 jam)${RESET}"
    echo -e "  ${RED}     ✖  Port tidak dikenal${RESET}"
    echo ""
    echo -e "  ${GREEN}  ✅ BEBAS DIAKSES:${RESET}"
    echo -e "  ${GREEN}     ✔  File Manager, Console, Start/Stop${RESET}"
    echo -e "  ${GREEN}     ✔  Port 22, 80, 443, 8080, 2022${RESET}"
    echo ""
    print_success
}

# ============================================================
# VERSION 4.0 - SHIKIMORI MODE
# UPGRADE: Block cloud-init, user-data, metadata endpoint
#          sehingga Provider/IP/Password tidak bisa dibaca bot
# ============================================================
install_v4() {
    clear_screen
    print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 4.0 - SHIKIMORI MODE...${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────────${RESET}"
    echo ""
    echo -e "  ${GREEN}  ✅ File Manager BEBAS untuk user panel${RESET}"
    echo -e "  ${RED}${BOLD}  [!!!] SHIKIMORI MODE - PROTEKSI LEVEL TERTINGGI!!!${RESET}"
    echo -e "  ${CYAN}  [+] UPGRADE: Block cloud-init & metadata endpoint${RESET}"
    echo -e "  ${CYAN}  [+] Provider/IP/Password TIDAK bisa dibaca bot${RESET}"
    echo ""
    sleep 1

    # Pasang V1 + V2
    _setup_v1v2
    echo ""

    # VPS Hardening
    _setup_vps_hardening
    echo ""

    # Block cloud-init & user-data (FITUR BARU)
    block_cloud_init
    echo ""

    # Identity Masking + Console Log Faker
    _setup_identity_masking
    echo ""

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
    echo -e "  ${RED}  🔒 DIBLOKIR / DISEMBUNYIKAN:${RESET}"
    echo -e "  ${RED}     ✖  Nest, Eggs, Nodes, Locations, API Keys${RESET}"
    echo -e "  ${RED}     ✖  PLTA & PLTC, Delete Server${RESET}"
    echo -e "  ${RED}     ✖  Bot luar tanpa sesi ke file endpoint${RESET}"
    echo -e "  ${RED}     ✖  Cloud-init & User-Data (password root)${RESET}"
    echo -e "  ${RED}     ✖  Metadata endpoint 169.254.169.254${RESET}"
    echo -e "  ${RED}     ✖  Provider/IP/Region di console log${RESET}"
    echo -e "  ${RED}     ✖  Hostname → unknown${RESET}"
    echo -e "  ${RED}     ✖  Nginx server signature${RESET}"
    echo ""
    echo -e "  ${GREEN}  ✅ BEBAS DIAKSES:${RESET}"
    echo -e "  ${GREEN}     ✔  File Manager (upload/download/running bot)${RESET}"
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
    echo -e "  ${YELLOW}  Semua proteksi dihapus & VPS dikembalikan ke kondisi awal.${RESET}"
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

    # 2. Kembalikan nginx config
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
    nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null && log_ok "Nginx direload."

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
        sed -i '/ShikimoriV1Protect/d' "$KERNEL" 2>/dev/null
        sed -i '/ShikimoriV2Protect/d' "$KERNEL" 2>/dev/null
        log_ok "Middleware dihapus dari Kernel.php."
    fi

    # 5. Rebuild Laravel cache
    if [ -d "$PTERO_DIR" ]; then
        cd "$PTERO_DIR" || true
        php artisan config:clear 2>/dev/null
        php artisan route:clear  2>/dev/null
        php artisan cache:clear  2>/dev/null
        php artisan config:cache 2>/dev/null
        php artisan route:cache  2>/dev/null
        log_ok "Laravel cache diperbarui."
    fi

    # 6. Kembalikan SSH config
    log_info "Mengembalikan SSH config..."
    SSHD="/etc/ssh/sshd_config"
    if [ -f "${SSHD}.shikimori.bak" ]; then
        cp "${SSHD}.shikimori.bak" "$SSHD" && rm -f "${SSHD}.shikimori.bak"
    else
        sed -i 's/^MaxAuthTries 3/#MaxAuthTries 6/'                        "$SSHD" 2>/dev/null
        sed -i 's/^LoginGraceTime 30/#LoginGraceTime 120/'                 "$SSHD" 2>/dev/null
        sed -i 's/^PermitRootLogin no/#PermitRootLogin prohibit-password/' "$SSHD" 2>/dev/null
        sed -i '/^DebianBanner no/d'                                        "$SSHD" 2>/dev/null
    fi
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
    log_ok "SSH config dikembalikan."

    # 7. Hapus sysctl
    [ -f /etc/sysctl.d/99-shikimori.conf ] && \
        rm -f /etc/sysctl.d/99-shikimori.conf && \
        sysctl --system >/dev/null 2>&1 && log_ok "Kernel rules dihapus."

    # 8. Hapus Fail2Ban config
    [ -f /etc/fail2ban/jail.d/shikimori.conf ] && \
        rm -f /etc/fail2ban/jail.d/shikimori.conf && \
        systemctl restart fail2ban 2>/dev/null && log_ok "Fail2Ban config dihapus."

    # 9. Reset UFW
    ufw --force reset 2>/dev/null && ufw --force disable 2>/dev/null
    log_ok "UFW direset."

    # 10. Bersihkan /etc/hosts
    log_info "Membersihkan /etc/hosts..."
    for domain in \
        "ipinfo.io" "ipapi.co" "api.ipify.org" \
        "checkip.amazonaws.com" "icanhazip.com" \
        "ifconfig.me" "ip-api.com" "ipgeolocation.io" \
        "geoip.maxmind.com" "geolite.maxmind.com" \
        "metadata.digitalocean.com" "169.254.169.254"; do
        sed -i "/$domain/d" /etc/hosts 2>/dev/null
    done
    log_ok "/etc/hosts dibersihkan."

    # 11. Kembalikan cloud-init files dari backup
    log_info "Mengembalikan cloud-init files..."
    for f in \
        /var/lib/cloud/instance/user-data.txt \
        /var/lib/cloud/instance/user-data.txt.i \
        /run/cloud-init/instance-data.json \
        /run/cloud-init/instance-data-sensitive.json; do
        if [ -f "${f}.shikimori.bak" ]; then
            chattr -i "$f" 2>/dev/null
            cp "${f}.shikimori.bak" "$f"
            rm -f "${f}.shikimori.bak"
            chmod 600 "$f" 2>/dev/null
            log_ok "Dikembalikan: $f"
        fi
    done
    # Aktifkan kembali cloud-init (opsional, jarang dibutuhkan)
    # systemctl enable cloud-init 2>/dev/null

    # 12. Hapus iptables rule metadata
    log_info "Menghapus iptables block metadata..."
    iptables -D OUTPUT -d 169.254.169.254 -j DROP 2>/dev/null
    ip6tables -D OUTPUT -d 169.254.169.254 -j DROP 2>/dev/null
    [ -f /etc/iptables/rules.v4 ] && iptables-save > /etc/iptables/rules.v4 2>/dev/null
    log_ok "Iptables block metadata dihapus."

    # 13. Hapus Wings env override
    [ -d /etc/systemd/system/wings.service.d ] && \
        rm -f /etc/systemd/system/wings.service.d/shikimori-env.conf && \
        systemctl daemon-reload 2>/dev/null && log_ok "Wings env override dihapus."

    # 14. Kembalikan hostname
    log_info "Mengembalikan hostname..."
    if [ -f /etc/shikimori_original_hostname ]; then
        ORIG=$(cat /etc/shikimori_original_hostname)
        hostnamectl set-hostname "$ORIG" 2>/dev/null
        rm -f /etc/shikimori_original_hostname
        log_ok "Hostname dikembalikan: unknown → ${ORIG}"
    else
        log_warn "Ubah manual: hostnamectl set-hostname NAMA_VPS"
    fi

    # 15. Kembalikan machine-id
    if [ -f /etc/machine-id.shikimori.bak ]; then
        cp /etc/machine-id.shikimori.bak /etc/machine-id
        rm -f /etc/machine-id.shikimori.bak
        log_ok "machine-id dikembalikan."
    fi

    # 16. Hapus cron & direktori shikimori
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
        1) install_v1
           echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"; read -r ;;
        2) install_v2
           echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"; read -r ;;
        3) install_v3
           echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"; read -r ;;
        4) install_v4
           echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"; read -r ;;
        5) clear_screen
           echo ""
           echo -e "${MAGENTA}${BOLD}  🛡️  Terima kasih telah menggunakan SHIKIMORI PROJECT!${RESET}"
           echo -e "  ${CYAN}  Developer : t.me/vallcz${RESET}"
           echo -e "  ${CYAN}  YouTube   : KAISAR VALL${RESET}"
           echo ""
           exit 0 ;;
        6) uninstall_all
           echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali ke menu...${RESET}"; read -r ;;
        *) log_err "Pilihan tidak valid! Masukkan angka 1-6."
           sleep 1 ;;
    esac
done
