#!/bin/bash

# ============================================================
#   SHIKIMORI PROJECT - VPS & PTERODACTYL PROTECTION
#   Developer : t.me/vallcz | YouTube : KAISAR VALL
#   Target    : Ubuntu 22.04 + Nginx + Pterodactyl
#
#   PROTEKSI LENGKAP:
#   ✅ Provider  → disembunyikan / dipalsukan
#   ✅ Region    → disembunyikan / dipalsukan
#   ✅ Password  → sumber bocor dikunci & dikosongkan
#   ℹ️ Public IP → tidak bisa disembunyikan dari luar
#                  tapi bisa disembunyikan dari script bot
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
# PROTECT PROVIDER + REGION + PASSWORD
#
# PROVIDER & REGION:
#   Sumber data provider/region ada di:
#   1. Cloud metadata endpoint 169.254.169.254
#   2. File /etc/os-release, /etc/issue
#   3. Environment variables Wings/Docker
#   4. Log Pterodactyl
#   5. /proc/version, /proc/cpuinfo (fingerprint)
#
# PASSWORD:
#   Sumber password ada di:
#   1. Cloud-init user-data (password lama saat setup VPS)
#   2. /etc/shadow (hash password sistem)
#   3. Environment variables
#   4. History bash (~/.bash_history)
#   5. Log autentikasi (/var/log/auth.log)
# ============================================================
protect_provider_region_password() {

    echo ""
    log_info "━━━ PROTEKSI PROVIDER ━━━"

    # ── 1. Blokir semua endpoint metadata cloud provider ──────────
    # Ini sumber utama provider + region yang dibaca script bot
    log_info "Memblokir metadata endpoints (provider + region + password sumber)..."

    # Hapus rule lama supaya tidak duplikat
    iptables -D OUTPUT   -d 169.254.169.254/32 -j DROP 2>/dev/null || true
    iptables -D FORWARD  -d 169.254.169.254/32 -j DROP 2>/dev/null || true
    iptables -D DOCKER-USER -d 169.254.169.254/32 -j DROP 2>/dev/null || true

    # Pasang block baru
    iptables -I OUTPUT   1 -d 169.254.169.254/32 -j DROP
    iptables -I FORWARD  1 -d 169.254.169.254/32 -j DROP
    iptables -I DOCKER-USER 1 -d 169.254.169.254/32 -j DROP 2>/dev/null || true

    # Simpan supaya persist setelah reboot
    mkdir -p /etc/iptables
    iptables-save > /etc/iptables/rules.v4 2>/dev/null
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q iptables-persistent 2>/dev/null
    log_ok "iptables: 169.254.169.254 → DROP (provider/region/password sumber)."

    # ── 2. Block domain IP-lookup & metadata via /etc/hosts ───────
    BLOCK_DOMAINS=(
        # IP-lookup (bisa baca provider & region dari sini)
        "ifconfig.me"      "ipinfo.io"         "ipapi.co"
        "api.ipify.org"    "api64.ipify.org"   "api4.my-ip.io"
        "checkip.amazonaws.com"                "icanhazip.com"
        "ip-api.com"       "ipgeolocation.io"  "extreme-ip-lookup.com"
        "ipwhois.app"      "ipwho.is"          "myip.wtf"
        "wtfismyip.com"    "ident.me"          "ipecho.net"
        # GCP metadata (provider + region GCP)
        "metadata.google.internal"             "metadata.google.com"
        # DigitalOcean metadata
        "metadata.digitalocean.com"
        # Maxmind GeoIP (lookup provider + region dari IP)
        "geoip.maxmind.com"                    "geolite.maxmind.com"
        "geoip2.maxmind.com"
    )
    for domain in "${BLOCK_DOMAINS[@]}"; do
        sed -i "/${domain}/d" /etc/hosts 2>/dev/null
        echo "0.0.0.0 ${domain}" >> /etc/hosts
    done
    # Block 169.254.169.254 di hosts juga (double block)
    sed -i '/169\.254\.169\.254/d' /etc/hosts 2>/dev/null
    echo "0.0.0.0 169.254.169.254" >> /etc/hosts
    log_ok "/etc/hosts: semua domain provider/region/IP-lookup → 0.0.0.0."

    # ── 3. Palsukan data provider & region di OS ──────────────────
    log_info "Memalsukan identitas provider & region di sistem..."

    # Backup dan palsukan /etc/os-release
    # Script bot kadang baca ini untuk deteksi provider
    if [ -f /etc/os-release ]; then
        [ -f /etc/os-release.shikimori.bak ] || \
            cp /etc/os-release /etc/os-release.shikimori.bak
        # Hapus baris yang bisa bocorkan provider
        sed -i '/^VARIANT/d'       /etc/os-release 2>/dev/null
        sed -i '/^VARIANT_ID/d'    /etc/os-release 2>/dev/null
        log_ok "os-release: info variant provider dihapus."
    fi

    # Palsukan hostname (provider kadang set hostname sesuai format mereka)
    OLD_HOST=$(hostname)
    if [ ! -f /etc/shikimori_original_hostname ]; then
        echo "$OLD_HOST" > /etc/shikimori_original_hostname
    fi
    hostnamectl set-hostname "unknown" 2>/dev/null || echo "unknown" > /etc/hostname
    log_ok "Hostname: ${OLD_HOST} → unknown (sembunyikan format hostname provider)."

    # Palsukan machine-id
    if [ -f /etc/machine-id ]; then
        [ -f /etc/machine-id.shikimori.bak ] || \
            cp /etc/machine-id /etc/machine-id.shikimori.bak
        printf '%032x\n' 0 > /etc/machine-id
    fi
    log_ok "Machine-ID dipalsukan → 00000000000000000000000000000000."

    echo ""
    log_info "━━━ PROTEKSI REGION ━━━"

    # ── 4. Override timezone jadi UTC (region bisa ketahuan dari timezone) ──
    if command -v timedatectl &>/dev/null; then
        [ -f /etc/timezone.shikimori.bak ] || \
            cp /etc/timezone /etc/timezone.shikimori.bak 2>/dev/null
        timedatectl set-timezone UTC 2>/dev/null
        log_ok "Timezone → UTC (sembunyikan region dari timezone)."
    fi

    # ── 5. Palsukan locale (region bisa ketahuan dari locale) ─────
    if [ -f /etc/default/locale ]; then
        [ -f /etc/default/locale.shikimori.bak ] || \
            cp /etc/default/locale /etc/default/locale.shikimori.bak
        cat > /etc/default/locale << 'LOCEOF'
LANG=en_US.UTF-8
LANGUAGE=en_US:en
LC_ALL=en_US.UTF-8
LOCEOF
        log_ok "Locale → en_US.UTF-8 (netral, tidak bocorkan region)."
    fi

    echo ""
    log_info "━━━ PROTEKSI PASSWORD ━━━"

    # ── 6. Kosongkan & kunci semua file user-data ─────────────────
    # Ini sumber utama password lama VPS (cloud-init script)
    FAKE_USERDATA='{"provider":"unknown","user_data":"","region":"unknown","hostname":"unknown"}'

    for f in \
        /var/lib/cloud/instance/user-data.txt \
        /var/lib/cloud/instance/user-data.txt.i \
        /var/lib/cloud/seed/nocloud/user-data \
        /run/cloud-init/instance-data.json \
        /run/cloud-init/instance-data-sensitive.json; do
        if [ -f "$f" ]; then
            [ -f "${f}.shikimori.bak" ] || cp "$f" "${f}.shikimori.bak" 2>/dev/null
            chattr -i "$f" 2>/dev/null || true
            echo "$FAKE_USERDATA" > "$f"
            chattr +i "$f" 2>/dev/null || true
            chmod 000 "$f" 2>/dev/null
            log_ok "Dikosongkan & dikunci: $(basename "$f")"
        fi
    done

    # Kunci direktori cloud-init
    chmod 700 /var/lib/cloud/instance  2>/dev/null || true
    chmod 700 /var/lib/cloud/instances 2>/dev/null || true

    # Matikan cloud-init service
    for svc in cloud-init cloud-init-local cloud-config cloud-final; do
        systemctl stop    "$svc" 2>/dev/null || true
        systemctl disable "$svc" 2>/dev/null || true
    done
    log_ok "cloud-init service dimatikan (tidak bisa baca user-data lagi)."

    # ── 7. Bersihkan bash history root ────────────────────────────
    # History bash bisa berisi password yang pernah diketik
    if [ -f /root/.bash_history ]; then
        [ -f /root/.bash_history.shikimori.bak ] || \
            cp /root/.bash_history /root/.bash_history.shikimori.bak 2>/dev/null
        # Hapus baris yang mengandung kata-kata sensitif
        sed -i '/password\|passwd\|chpasswd\|echo.*root\|usermod/Id' \
            /root/.bash_history 2>/dev/null
        log_ok "Bash history dibersihkan dari baris berisi password."
    fi
    # Matikan penyimpanan history ke depannya
    export HISTFILESIZE=0
    export HISTSIZE=0
    # Tambahkan ke bashrc supaya permanen
    grep -q "HISTFILESIZE=0" /root/.bashrc 2>/dev/null || \
        echo -e "\n# SHIKIMORI - Disable bash history\nexport HISTFILESIZE=0\nexport HISTSIZE=0\nunset HISTFILE" \
        >> /root/.bashrc
    log_ok "Bash history dinonaktifkan untuk root."

    # ── 8. Bersihkan auth log dari info sensitif ──────────────────
    # /var/log/auth.log kadang berisi username + IP yang mencoba login
    for authlog in /var/log/auth.log /var/log/secure; do
        [ -f "$authlog" ] || continue
        # Hapus baris yang berisi password atau credential
        sed -i '/pam_unix.*password/Id' "$authlog" 2>/dev/null
        sed -i '/Accepted password/Id'  "$authlog" 2>/dev/null
        log_ok "Auth log dibersihkan: $(basename "$authlog")"
    done

    # ── 9. Override Wings & Docker environment vars ───────────────
    # Supaya tidak bisa baca provider/region dari env container
    WINGS_DIR="/etc/systemd/system/wings.service.d"
    mkdir -p "$WINGS_DIR"
    cat > "$WINGS_DIR/shikimori-env.conf" << 'ENVEOF'
[Service]
# SHIKIMORI PROJECT - Override semua env var sensitif
# Provider & Region
Environment="PROVIDER=unknown"
Environment="CLOUD_PROVIDER=unknown"
Environment="DATACENTER=unknown"
Environment="REGION=unknown"
Environment="AVAILABILITY_ZONE=unknown"
Environment="DATACENTER_REGION=unknown"
# DigitalOcean
Environment="DO_ACCESS_TOKEN="
Environment="DIGITALOCEAN_ACCESS_TOKEN="
# AWS
Environment="AWS_ACCESS_KEY_ID="
Environment="AWS_SECRET_ACCESS_KEY="
Environment="AWS_DEFAULT_REGION=unknown"
Environment="AWS_REGION=unknown"
# Vultr
Environment="VULTR_API_KEY="
# GCP
Environment="GCE_SERVICE_ACCOUNT="
Environment="GOOGLE_APPLICATION_CREDENTIALS="
# Linode
Environment="LINODE_TOKEN="
Environment="LINODE_CLI_TOKEN="
ENVEOF
    systemctl daemon-reload 2>/dev/null
    log_ok "Wings env vars di-override (provider/region/credentials → unknown)."

    # ── 10. Hapus & kunci file identitas provider ─────────────────
    for id_file in \
        /etc/digitalocean \
        /etc/vultr \
        /etc/do-agent \
        /var/lib/cloud/instance/datasource; do
        if [ -f "$id_file" ]; then
            [ -f "${id_file}.shikimori.bak" ] || \
                cp "$id_file" "${id_file}.shikimori.bak" 2>/dev/null
            chattr -i "$id_file" 2>/dev/null || true
            echo '{"provider":"unknown","region":"unknown"}' > "$id_file"
            chattr +i "$id_file" 2>/dev/null || true
            chmod 000 "$id_file" 2>/dev/null
            log_ok "File provider dikosongkan: $(basename "$id_file")"
        fi
    done

    # Simpan iptables final
    iptables-save > /etc/iptables/rules.v4 2>/dev/null

    echo ""
    log_ok "✅ Provider, Region & Password TERLINDUNGI PENUH."
}

# ============================================================
# CONSOLE LOG FAKER
# Sanitasi log Pterodactyl dari Provider, Region, IP, Password
# ============================================================
setup_console_faker() {
    log_info "Memasang Console Log Faker (Provider + Region + Password)..."
    mkdir -p /opt/shikimori

    cat > /opt/shikimori/console_faker.sh << 'FAKEEOF'
#!/bin/bash
# Shikimori Project - Console Log Faker
# Sanitasi log dari: Provider, Region, Password, IP, Hostname
LOG_DIRS=(
    "/var/log/pterodactyl"
    "/var/www/pterodactyl/storage/logs"
    "/var/log/wings"
)
for dir in "${LOG_DIRS[@]}"; do
    [ -d "$dir" ] || continue
    find "$dir" -name "*.log" -type f 2>/dev/null | while read -r f; do
        sed -i \
            -e 's/Provider\s*:\s*[a-zA-Z0-9._-]*/Provider   : unknown/gI' \
            -e 's/"provider":"[^"]*"/"provider":"unknown"/g' \
            -e 's/provider: [A-Za-z0-9 .,_-]*/provider: unknown/g' \
            -e 's/"vendor":"[^"]*"/"vendor":"unknown"/g' \
            -e 's/"datacenter":"[^"]*"/"datacenter":"unknown"/g' \
            -e 's/Region\s*:\s*[a-zA-Z0-9._-]*/Region     : unknown/gI' \
            -e 's/"region":"[^"]*"/"region":"unknown"/g' \
            -e 's/region: [A-Za-z0-9 .,_-]*/region: unknown/g' \
            -e 's/"availability_zone":"[^"]*"/"availability_zone":"unknown"/g' \
            -e 's/"country":"[^"]*"/"country":"unknown"/g' \
            -e 's/"city":"[^"]*"/"city":"unknown"/g' \
            -e 's/"org":"[^"]*"/"org":"unknown"/g' \
            -e 's/"isp":"[^"]*"/"isp":"unknown"/g' \
            -e 's/Public IP\s*:\s*[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/Public IP  : N\/A/g' \
            -e 's/"public_ip":"[^"]*"/"public_ip":"N\/A"/g' \
            -e 's/"ip":"[^"]*"/"ip":"N\/A"/g' \
            -e 's/"hostname":"[^"]*"/"hostname":"unknown"/g' \
            -e 's/hostname: [A-Za-z0-9._-]*/hostname: unknown/g' \
            -e 's/User Data\s*:.*$/User Data  : PROTECTED/g' \
            -e 's/user_data.*:.*$/user_data: PROTECTED/g' \
            -e 's/password[=: ][^ \t]*/password: HIDDEN/gI' \
            -e 's/passwd[=: ][^ \t]*/passwd: HIDDEN/gI' \
            -e 's/chpasswd.*$/chpasswd: HIDDEN/g' \
            "$f" 2>/dev/null
    done
done
FAKEEOF
    chmod +x /opt/shikimori/console_faker.sh

    # Crontab tiap menit, cegah duplikat
    (crontab -l 2>/dev/null | grep -v "console_faker.sh"; \
        echo "* * * * * /opt/shikimori/console_faker.sh") | crontab -

    log_ok "Console Log Faker aktif — Provider/Region/Password disanitasi tiap menit."
}

# ============================================================
# NGINX V1
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
# NGINX V2
# ============================================================
write_nginx_v2() {
    mkdir -p /etc/nginx/snippets
    cat > /etc/nginx/snippets/shikimori_v2.conf << 'NGINXEOF'
# ====== SHIKIMORI PROJECT V2 - PLTA & PLTC ======
# CATATAN: Blokir hanya di level middleware PHP (ShikimoriV2Protect)
# supaya admin utama Pterodactyl tetap bisa akses PLTA & PLTC.
# Nginx tidak memblokir di sini karena nginx tidak bisa
# membedakan admin vs user biasa.
# Semua logika izin admin ada di middleware Laravel.
NGINXEOF
}

# ============================================================
# MIDDLEWARE V1
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
        'admin/nests','admin/eggs','admin/nodes','admin/locations',
        'account/api','api/application/nodes','api/application/locations',
        'api/client/account/api-keys',
    ];
    protected array $deleteBlocked = ['api/application/servers'];

    public function handle(Request $request, Closure $next)
    {
        $path = $request->path();
        foreach ($this->alwaysBlocked as $p) {
            if (str_contains($path, $p)) return $this->deny($request);
        }
        if ($request->isMethod('DELETE')) {
            foreach ($this->deleteBlocked as $p) {
                if (str_contains($path, $p)) return $this->deny($request);
            }
        }
        if (str_contains($path, '/files')) {
            $hasAuth = $request->bearerToken() !== null
                || $request->hasCookie('pterodactyl_session')
                || $request->user() !== null;
            if (!$hasAuth) return $this->deny($request);
        }
        return $next($request);
    }

    private function deny(Request $r)
    {
        $msg = ['success' => false, 'error' => '🛡️ PROTECT BY SHIKIMORI PROJECT'];
        if ($r->expectsJson() || str_starts_with($r->path(), 'api/'))
            return response()->json($msg, 403);
        abort(403, '🛡️ PROTECT BY SHIKIMORI PROJECT');
    }
}
PHPEOF
}

# ============================================================
# MIDDLEWARE V2
# ============================================================
write_middleware_v2() {
    local dir="$1"
    cat > "$dir/ShikimoriV2Protect.php" << 'PHPEOF'
<?php
namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

/**
 * SHIKIMORI PROJECT V2 - PLTA & PLTC Protection
 *
 * SIAPA YANG BISA AKSES PLTA & PLTC:
 *   ✅ Admin pertama / pemilik VPS (user ID = 1)
 *
 * SIAPA YANG DIBLOKIR:
 *   🔒 Admin lain (root_admin = true tapi ID bukan 1)
 *   🔒 User biasa / subuser
 *
 * Mengapa ID = 1?
 *   User pertama yang dibuat saat install Pterodactyl
 *   selalu mendapat ID = 1. Ini adalah pemilik VPS yang
 *   sesungguhnya. Admin lain yang ditambahkan belakangan
 *   mendapat ID lebih besar dari 1.
 *
 * Jika ID pemilik VPS kamu bukan 1, ubah konstanta
 * OWNER_ID di bawah sesuai ID akun kamu.
 */
class ShikimoriV2Protect
{
    /**
     * ID user pemilik VPS yang boleh akses PLTA & PLTC.
     * Default = 1 (admin pertama saat install Pterodactyl).
     * Ubah angka ini jika ID kamu berbeda.
     */
    const OWNER_ID = 1;

    // Endpoint PLTA (Allocation / port limits)
    protected array $pltaEndpoints = [
        'allocations',
        'network/allocations',
    ];

    // Endpoint PLTC (Build / resource caps)
    protected array $pltcEndpoints = [
        '/build',
        'server-resources',
    ];

    // Path admin panel PLTA & PLTC (halaman web)
    protected array $adminPaths = [
        'admin/nodes/view',
        'admin/servers/view',
    ];

    public function handle(Request $request, Closure $next)
    {
        $path = $request->path();

        // Cek apakah path ini termasuk PLTA, PLTC, atau admin path-nya
        $isPlta = false;
        $isPltc = false;
        $isAdminPath = false;

        foreach ($this->pltaEndpoints as $p) {
            if (str_contains($path, $p)) { $isPlta = true; break; }
        }
        foreach ($this->pltcEndpoints as $p) {
            if (str_contains($path, $p)) { $isPltc = true; break; }
        }
        foreach ($this->adminPaths as $p) {
            if (str_contains($path, $p)) { $isAdminPath = true; break; }
        }
        // PUT/PATCH ke build = PLTC
        if (in_array($request->method(), ['PUT', 'PATCH'])
            && str_contains($path, 'build')) {
            $isPltc = true;
        }

        // Jika bukan endpoint PLTA/PLTC sama sekali → lanjutkan normal
        if (!$isPlta && !$isPltc && !$isAdminPath) {
            return $next($request);
        }

        // ══════════════════════════════════════════════
        // CEK APAKAH USER ADALAH PEMILIK VPS (ID = 1)
        // Hanya pemilik VPS pertama yang boleh akses
        // Admin lain dan user biasa tetap diblokir
        // ══════════════════════════════════════════════
        $user = $request->user();

        if ($user && (int)$user->id === self::OWNER_ID) {
            // Pemilik VPS → izinkan akses PLTA & PLTC
            return $next($request);
        }

        // Semua yang lain → blokir
        $type = $isPlta ? 'PLTA' : 'PLTC';
        return $this->deny($request, $type);
    }

    private function deny(Request $r, string $type = '')
    {
        $msg = [
            'success' => false,
            'error'   => "🛡️ SHIKIMORI PROJECT — Akses {$type} hanya untuk pemilik VPS.",
        ];
        if ($r->expectsJson() || str_starts_with($r->path(), 'api/')) {
            return response()->json($msg, 403);
        }
        abort(403, "🛡️ SHIKIMORI PROJECT — Akses {$type} hanya untuk pemilik VPS.");
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
        [ -f "${NGINX_CONF}.shikimori.bak" ] || \
            cp "$NGINX_CONF" "${NGINX_CONF}.shikimori.bak" 2>/dev/null
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
# ANTI KILL PANEL, ANTI DISK ABUSE, ANTI SSH KILL,
# ANTI OVERLOAD, ANTI FORK BOMB, ANTI RESOURCE EXHAUSTION
# ============================================================
_setup_anti_kill() {
    log_info "━━━ ANTI KILL PANEL & ANTI OVERLOAD ━━━"

    # ── 1. WATCHDOG - Auto restart panel jika mati ────────────────
    # Jika nginx, wings, atau pterodactyl mati karena serangan,
    # watchdog akan otomatis menghidupkannya kembali dalam 30 detik
    log_info "Memasang Watchdog auto-restart..."
    mkdir -p /opt/shikimori

    cat > /opt/shikimori/watchdog.sh << 'WDEOF'
#!/bin/bash
# SHIKIMORI WATCHDOG - Auto restart services jika mati
SERVICES=("nginx" "wings" "mariadb" "mysql")
LOG="/var/log/shikimori-watchdog.log"

for svc in "${SERVICES[@]}"; do
    if systemctl is-enabled "$svc" &>/dev/null; then
        if ! systemctl is-active --quiet "$svc"; then
            echo "[$(date)] WATCHDOG: $svc mati! Memulai ulang..." >> "$LOG"
            systemctl restart "$svc" 2>/dev/null
            echo "[$(date)] WATCHDOG: $svc berhasil dihidupkan kembali." >> "$LOG"
        fi
    fi
done

# Cek disk usage - jika > 90% kirim warning ke log
DISK_USAGE=$(df / | awk 'NR==2{print $5}' | tr -d '%')
if [ "$DISK_USAGE" -gt 90 ]; then
    echo "[$(date)] WARNING: Disk usage ${DISK_USAGE}% - hampir penuh!" >> "$LOG"
fi
WDEOF
    chmod +x /opt/shikimori/watchdog.sh

    # Jalankan watchdog tiap 1 menit
    (crontab -l 2>/dev/null | grep -v "watchdog.sh"; \
        echo "* * * * * /opt/shikimori/watchdog.sh") | crontab -
    log_ok "Watchdog aktif — nginx/wings/mariadb auto-restart jika mati."

    # ── 2. SYSTEMD RESTART POLICY - Auto restart pada crash ───────
    # Pasang override restart policy untuk nginx dan wings
    for svc in nginx wings; do
        OVERRIDE_DIR="/etc/systemd/system/${svc}.service.d"
        mkdir -p "$OVERRIDE_DIR"
        # Jangan timpa shikimori-env.conf yang sudah ada untuk wings
        cat > "$OVERRIDE_DIR/shikimori-restart.conf" << 'RSEOF'
[Service]
Restart=always
RestartSec=10s
StartLimitIntervalSec=60s
StartLimitBurst=5
RSEOF
    done
    systemctl daemon-reload 2>/dev/null
    log_ok "Systemd restart policy: nginx & wings auto-restart dalam 10 detik jika crash."

    # ── 3. ANTI DISK ABUSE - Limit disk write per container ───────
    log_info "Memasang proteksi anti disk abuse..."

    # Konfigurasi limit inode dan disk untuk mencegah disk penuh
    # Pasang via /etc/security/limits.conf
    grep -q "shikimori-disk" /etc/security/limits.conf 2>/dev/null || \
    cat >> /etc/security/limits.conf << 'LIMEOF'
# SHIKIMORI - Anti disk abuse
*    hard    fsize       10485760
*    soft    fsize       10485760
root hard    fsize       unlimited
root soft    fsize       unlimited
LIMEOF
    log_ok "Disk write limit dipasang via limits.conf (max 10GB per proses non-root)."

    # Monitor dan bersihkan file sampah secara berkala
    cat > /opt/shikimori/disk_guard.sh << 'DISKEOF'
#!/bin/bash
# SHIKIMORI DISK GUARD - Monitor dan protect disk
LOG="/var/log/shikimori-watchdog.log"

# Bersihkan log nginx yang sudah tua (lebih dari 7 hari)
find /var/log/nginx -name "*.log.*" -mtime +7 -delete 2>/dev/null

# Bersihkan log pterodactyl yang tua (lebih dari 14 hari)
find /var/www/pterodactyl/storage/logs -name "*.log" -mtime +14 -delete 2>/dev/null

# Bersihkan log wings yang tua (lebih dari 7 hari)
find /var/log/wings -name "*.log.*" -mtime +7 -delete 2>/dev/null

# Cek apakah ada file sangat besar mencurigakan (>500MB) di /tmp
find /tmp -size +500M -type f 2>/dev/null | while read -r bigfile; do
    echo "[$(date)] DISK GUARD: File besar mencurigakan ditemukan: $bigfile" >> "$LOG"
    rm -f "$bigfile" 2>/dev/null
done

# Cek disk usage critical (>95%)
DISK_USAGE=$(df / | awk 'NR==2{print $5}' | tr -d '%')
if [ "$DISK_USAGE" -gt 95 ]; then
    echo "[$(date)] CRITICAL: Disk ${DISK_USAGE}%! Membersihkan cache..." >> "$LOG"
    # Bersihkan apt cache
    apt-get clean 2>/dev/null
    # Bersihkan journal log lama
    journalctl --vacuum-time=1d 2>/dev/null
    # Bersihkan tmp
    find /tmp -mtime +1 -delete 2>/dev/null
    echo "[$(date)] DISK GUARD: Pembersihan selesai." >> "$LOG"
fi
DISKEOF
    chmod +x /opt/shikimori/disk_guard.sh
    # Jalankan disk guard tiap jam
    (crontab -l 2>/dev/null | grep -v "disk_guard.sh"; \
        echo "0 * * * * /opt/shikimori/disk_guard.sh") | crontab -
    log_ok "Disk Guard aktif — auto cleanup & monitor disk setiap jam."

    # ── 4. ANTI FORK BOMB - Limit proses per user ─────────────────
    log_info "Memasang anti fork bomb..."
    grep -q "shikimori-forkbomb" /etc/security/limits.conf 2>/dev/null || \
    cat >> /etc/security/limits.conf << 'FORKEOF'
# SHIKIMORI - Anti fork bomb
*    hard    nproc       500
*    soft    nproc       500
root hard    nproc       unlimited
root soft    nproc       unlimited
FORKEOF

    # Aktifkan limits via PAM
    grep -q "pam_limits" /etc/pam.d/common-session 2>/dev/null || \
        echo "session required pam_limits.so" >> /etc/pam.d/common-session
    log_ok "Anti fork bomb: max 500 proses per user non-root."

    # ── 5. ANTI OVERLOAD - Rate limiting nginx ────────────────────
    log_info "Memasang rate limiting nginx..."

    # Rate limit zones HARUS ada di http block nginx.conf
    # BUKAN di server block / snippet - ini penyebab panel tidak bisa diakses
    if ! grep -q "shikimori_api" /etc/nginx/nginx.conf 2>/dev/null; then
        sed -i '/http {/a\\    # SHIKIMORI Rate Limit Zones\n    limit_req_zone $binary_remote_addr zone=shikimori_api:10m rate=60r/m;\n    limit_req_zone $binary_remote_addr zone=shikimori_login:10m rate=10r/m;\n    limit_conn_zone $binary_remote_addr zone=shikimori_conn:10m;' \
            /etc/nginx/nginx.conf 2>/dev/null
    fi

    # Snippet hanya berisi limit_req di dalam location yang benar
    # Tidak ada location block duplikat yang konflik dengan panel
    mkdir -p /etc/nginx/snippets
    cat > /etc/nginx/snippets/shikimori_ratelimit.conf << 'RLEOF'
# SHIKIMORI - Rate Limiting Rules
# File ini di-include di dalam server block panel
# Zones sudah didefinisikan di /etc/nginx/nginx.conf http block

# Limit koneksi bersamaan per IP (max 30 koneksi)
limit_conn shikimori_conn 30;

# Rate limit untuk endpoint login (anti brute force)
# Diapply via location di bawah ini dengan priority tinggi
RLEOF

    # Inject rate limit ke server block dengan cara aman
    # Hanya tambahkan limit_conn dan limit_req ke location yang sudah ada
    find_nginx_conf
    if [ -n "$NGINX_CONF" ]; then
        # Tambahkan limit_conn ke dalam server block (bukan di luar)
        if ! grep -q "shikimori_conn" "$NGINX_CONF" 2>/dev/null; then
            sed -i '/listen 80\|listen 443/a\\    limit_conn shikimori_conn 30;' \
                "$NGINX_CONF" 2>/dev/null
        fi
        # Tambahkan rate limit ke location /auth jika belum ada
        if grep -q "location.*auth" "$NGINX_CONF" 2>/dev/null; then
            sed -i '/location.*auth.*{/a\\        limit_req zone=shikimori_login burst=5 nodelay;' \
                "$NGINX_CONF" 2>/dev/null
        fi
        nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null && \
            log_ok "Rate limiting aktif: Login 10r/min, koneksi max 30 per IP." || \
            log_warn "Rate limit gagal dipasang di nginx, skip."
    fi

    # ── 6. ANTI SSH KILL - Jaga SSH tetap hidup ───────────────────
    log_info "Memasang anti SSH kill..."

    # Buat SSH watchdog khusus yang lebih agresif dari watchdog umum
    cat > /opt/shikimori/ssh_guard.sh << 'SSHGEOF'
#!/bin/bash
# SHIKIMORI SSH GUARD - Pastikan SSH selalu hidup
LOG="/var/log/shikimori-watchdog.log"

# Cek apakah SSH process berjalan
if ! pgrep -x "sshd" > /dev/null 2>&1; then
    echo "[$(date)] SSH GUARD: sshd tidak berjalan! Memulai ulang..." >> "$LOG"
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
    echo "[$(date)] SSH GUARD: sshd berhasil dihidupkan kembali." >> "$LOG"
fi

# Pastikan port SSH (22) masih listening
if ! ss -tlnp | grep -q ":22 "; then
    echo "[$(date)] SSH GUARD: Port 22 tidak listening! Restart sshd..." >> "$LOG"
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
fi

# Pastikan UFW mengizinkan SSH
ufw status | grep -q "22/tcp.*ALLOW" 2>/dev/null || \
    ufw allow 22/tcp 2>/dev/null

# Pastikan iptables tidak memblokir SSH
iptables -C INPUT -p tcp --dport 22 -j DROP 2>/dev/null && \
    iptables -D INPUT -p tcp --dport 22 -j DROP 2>/dev/null
SSHGEOF
    chmod +x /opt/shikimori/ssh_guard.sh

    # Jalankan SSH guard tiap menit
    (crontab -l 2>/dev/null | grep -v "ssh_guard.sh"; \
        echo "* * * * * /opt/shikimori/ssh_guard.sh") | crontab -
    log_ok "SSH Guard aktif — SSH auto-restart & port 22 dijaga tiap menit."

    # Proteksi SSH dari di-kill oleh proses lain
    # Pasang systemd hardening untuk sshd
    SSH_OVERRIDE="/etc/systemd/system/ssh.service.d"
    [ -d "$SSH_OVERRIDE" ] || SSH_OVERRIDE="/etc/systemd/system/sshd.service.d"
    mkdir -p "$SSH_OVERRIDE"
    cat > "$SSH_OVERRIDE/shikimori-ssh.conf" << 'SSHEOF'
[Service]
Restart=always
RestartSec=5s
StartLimitIntervalSec=30s
StartLimitBurst=10
OOMScoreAdjust=-900
SSHEOF
    # OOMScoreAdjust=-900 memastikan SSH tidak di-kill oleh OOM killer
    # saat server kehabisan RAM akibat overload
    systemctl daemon-reload 2>/dev/null
    log_ok "SSH systemd: restart otomatis dalam 5 detik + dilindungi dari OOM killer."

    # ── 7. ANTI OOM KILL PANEL - Proteksi dari RAM overload ───────
    log_info "Memasang proteksi anti OOM kill..."

    # Lindungi nginx dari OOM killer (RAM habis)
    NGINX_PID=$(pgrep -x nginx | head -1)
    if [ -n "$NGINX_PID" ]; then
        echo -900 > /proc/"$NGINX_PID"/oom_score_adj 2>/dev/null || true
    fi
    # Pasang via systemd supaya permanen
    mkdir -p /etc/systemd/system/nginx.service.d
    cat >> /etc/systemd/system/nginx.service.d/shikimori-restart.conf << 'OOMEOF'
OOMScoreAdjust=-900
OOMEOF

    # Lindungi wings dari OOM killer
    WINGS_PID=$(pgrep -x wings | head -1)
    if [ -n "$WINGS_PID" ]; then
        echo -500 > /proc/"$WINGS_PID"/oom_score_adj 2>/dev/null || true
    fi

    # Konfigurasi kernel untuk OOM behavior
    # Preferensikan kill proses lain bukan sistem penting
    echo 1 > /proc/sys/vm/overcommit_memory 2>/dev/null || true
    grep -q "vm.overcommit_memory" /etc/sysctl.d/99-shikimori.conf 2>/dev/null || \
        echo "vm.overcommit_memory = 1" >> /etc/sysctl.d/99-shikimori.conf
    sysctl -p /etc/sysctl.d/99-shikimori.conf >/dev/null 2>&1

    systemctl daemon-reload 2>/dev/null
    log_ok "Anti OOM: nginx (score -900) & wings (score -500) dilindungi dari kill RAM habis."

    # ── 8. ANTI CPU OVERLOAD - Limit CPU abuse ────────────────────
    log_info "Memasang proteksi anti CPU overload..."

    # Pasang via cgroups/systemd - limit CPU usage Docker containers
    # supaya satu container tidak bisa membuat seluruh VPS hang
    if [ -f /etc/systemd/system/wings.service ] || \
       systemctl is-enabled wings &>/dev/null 2>/dev/null; then
        mkdir -p /etc/systemd/system/wings.service.d
        # Cek jika shikimori-env.conf sudah ada, tambahkan di sana
        WINGS_ENV_FILE="/etc/systemd/system/wings.service.d/shikimori-env.conf"
        if [ -f "$WINGS_ENV_FILE" ]; then
            grep -q "CPUQuota" "$WINGS_ENV_FILE" 2>/dev/null || \
            cat >> "$WINGS_ENV_FILE" << 'CPUEOF'

# SHIKIMORI - CPU protection
# CPUQuota tidak dipasang di wings langsung karena akan limit semua container
# Sebagai gantinya kita pakai nice level
Nice=10
CPUEOF
        fi
    fi

    # Monitor CPU - jika ada proses yang pakai CPU > 90% lebih dari 5 menit, log
    cat > /opt/shikimori/cpu_guard.sh << 'CPUGEOF'
#!/bin/bash
# SHIKIMORI CPU GUARD
LOG="/var/log/shikimori-watchdog.log"
# Cari proses dengan CPU > 80%
ps aux --sort=-%cpu | awk 'NR>1 && $3>80 {print}' | while read -r line; do
    echo "[$(date)] CPU GUARD HIGH USAGE: $line" >> "$LOG"
done
CPUGEOF
    chmod +x /opt/shikimori/cpu_guard.sh
    (crontab -l 2>/dev/null | grep -v "cpu_guard.sh"; \
        echo "*/5 * * * * /opt/shikimori/cpu_guard.sh") | crontab -
    log_ok "CPU Guard aktif — monitor proses CPU tinggi tiap 5 menit."

    # ── 9. ANTI NETWORK FLOOD - Tambahan iptables ─────────────────
    log_info "Memasang anti network flood tambahan..."

    # Limit koneksi baru per IP per detik (anti SYN flood / connection flood)
    iptables -I INPUT -p tcp --syn -m limit --limit 25/s --limit-burst 50 -j ACCEPT 2>/dev/null || true
    iptables -I INPUT -p tcp --syn -j DROP 2>/dev/null || true

    # Limit ping flood
    iptables -I INPUT -p icmp --icmp-type echo-request \
        -m limit --limit 1/s --limit-burst 5 -j ACCEPT 2>/dev/null || true

    # Blokir paket invalid
    iptables -I INPUT -m state --state INVALID -j DROP 2>/dev/null || true
    iptables -I FORWARD -m state --state INVALID -j DROP 2>/dev/null || true

    # Simpan rules
    iptables-save > /etc/iptables/rules.v4 2>/dev/null
    log_ok "Anti flood: SYN flood, ping flood, dan paket invalid DIBLOKIR."

    log_ok "✅ Anti Kill Panel, Anti Disk Abuse, Anti SSH Kill, Anti Overload AKTIF."
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
        # Matikan password auth via SSH — wajib pakai SSH key
        sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD"
        grep -q "PasswordAuthentication" "$SSHD" || \
            echo "PasswordAuthentication no" >> "$SSHD"
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        log_ok "SSH: password auth dimatikan, hanya SSH key."
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
    log_ok "Fail2Ban aktif (auto ban brute force)."

    log_info "Mengkonfigurasi UFW..."
    ufw --force reset          2>/dev/null
    ufw default deny incoming  2>/dev/null
    ufw default allow outgoing 2>/dev/null
    ufw allow 22/tcp   comment 'SSH'   2>/dev/null
    ufw allow 80/tcp   comment 'HTTP'  2>/dev/null
    ufw allow 443/tcp  comment 'HTTPS' 2>/dev/null
    ufw allow 8080/tcp comment 'Wings' 2>/dev/null
    ufw allow 2022/tcp comment 'SFTP'  2>/dev/null
    ufw --force enable 2>/dev/null
    log_ok "UFW aktif — 80/443/8080 terbuka."
}

# ============================================================
# VERSION 1.0
# ============================================================
install_v1() {
    clear_screen; print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 1.0 - Nest & Panel Protection...${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────────${RESET}"
    echo -e "\n  ${GREEN}  ✅ File Manager BEBAS — upload/download/running bot aman${RESET}\n"

    find_nginx_conf; write_nginx_v1
    if [ -n "$NGINX_CONF" ]; then
        [ -f "${NGINX_CONF}.shikimori.bak" ] || \
            cp "$NGINX_CONF" "${NGINX_CONF}.shikimori.bak" 2>/dev/null
        inject_nginx_snippet "shikimori_v1" "/etc/nginx/snippets/shikimori_v1.conf"
        reload_nginx
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
    echo -e "\n  ${RED}  🔒 DIBLOKIR:${RESET}"
    echo -e "  ${RED}     ✖  Nest, Eggs, Nodes, Locations, API Keys, Delete Server${RESET}"
    echo -e "  ${RED}     ✖  Bot luar tanpa sesi ke file endpoint${RESET}"
    echo -e "\n  ${GREEN}  ✅ BEBAS: File Manager, Console, Start/Stop/Restart${RESET}\n"
    print_success
}

# ============================================================
# VERSION 2.0
# ============================================================
install_v2() {
    clear_screen; print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 2.0 - PLTA & PLTC Protection...${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────────${RESET}\n"

    find_nginx_conf; write_nginx_v2
    if [ -n "$NGINX_CONF" ]; then
        [ -f "${NGINX_CONF}.shikimori.bak" ] || \
            cp "$NGINX_CONF" "${NGINX_CONF}.shikimori.bak" 2>/dev/null
        inject_nginx_snippet "shikimori_v2" "/etc/nginx/snippets/shikimori_v2.conf"
        reload_nginx
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
    echo -e "\n  ${RED}  🔒 DIBLOKIR: PLTA (Allocation) & PLTC (Build/Resource cap)${RESET}"
    echo -e "  ${GREEN}  ✅ BEBAS: File Manager, Console, Start/Stop/Restart${RESET}\n"
    print_success
}

# ============================================================
# VERSION 3.0
# ============================================================
install_v3() {
    clear_screen; print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 3.0 - Super Hardest Protection...${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────────${RESET}"
    echo -e "\n  ${GREEN}  ✅ File Manager BEBAS untuk user panel${RESET}"
    echo -e "  ${RED}${BOLD}  [!] Menginstall V1 + V2 + VPS Hardening!${RESET}\n"
    sleep 1

    _setup_v1v2;          echo ""
    _setup_vps_hardening; echo ""
    _setup_anti_kill

    progress_bar "Menginstall Super Hardest Protection..."
    echo ""
    log_ok "Proteksi V3 AKTIF!"
    echo -e "\n  ${RED}  🔒 DIBLOKIR: Nest/Nodes/API, PLTA/PLTC, Delete Server, Brute Force, Port asing${RESET}"
    echo -e "  ${RED}     ✖  Anti Kill Panel, Anti Disk Abuse, Anti SSH Kill, Anti Overload${RESET}"
    echo -e "  ${GREEN}  ✅ BEBAS: File Manager, Console, Port 22/80/443/8080/2022${RESET}\n"
    print_success
}

# ============================================================
# VERSION 4.0 - SHIKIMORI MODE
# Proteksi penuh: Provider + Region + Password + Panel + VPS
# ============================================================
install_v4() {
    clear_screen; print_banner
    echo -e "${MAGENTA}${BOLD}  🛡️  Mengaktifkan VERSI 4.0 - SHIKIMORI MODE...${RESET}"
    echo -e "${YELLOW}  ──────────────────────────────────────────────────────────────${RESET}"
    echo ""
    echo -e "  ${GREEN}  ✅ File Manager BEBAS untuk user panel${RESET}"
    echo -e "  ${RED}${BOLD}  [!!!] SHIKIMORI MODE - PROTEKSI LEVEL TERTINGGI!!!${RESET}"
    echo ""
    echo -e "  ${CYAN}  Yang akan dilindungi:${RESET}"
    echo -e "  ${CYAN}  ✦ Provider  → dipalsukan & sumber data diblokir${RESET}"
    echo -e "  ${CYAN}  ✦ Region    → dipalsukan & timezone dineutralkan${RESET}"
    echo -e "  ${CYAN}  ✦ Password  → sumber cloud-init dikunci chattr +i${RESET}"
    echo -e "  ${CYAN}  ✦ Public IP → diblokir dari script bot (ifconfig.me dsb)${RESET}"
    echo ""
    sleep 2

    mkdir -p /opt/shikimori

    _setup_v1v2;                       echo ""
    _setup_vps_hardening;              echo ""
    _setup_anti_kill;                  echo ""
    protect_provider_region_password;  echo ""
    setup_console_faker;               echo ""

    # Sembunyikan nginx server signature
    if ! grep -q "server_tokens off" /etc/nginx/nginx.conf 2>/dev/null; then
        sed -i '/http {/a\\    server_tokens off;' /etc/nginx/nginx.conf 2>/dev/null
        nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null
    fi
    log_ok "Nginx server signature disembunyikan."

    iptables-save > /etc/iptables/rules.v4 2>/dev/null

    progress_bar "Menginstall SHIKIMORI MODE..."
    echo ""
    echo -e "${MAGENTA}${BOLD}  ╔════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}${BOLD}  ║      🛡️  SHIKIMORI MODE BERHASIL DIAKTIFKAN! 🛡️        ║${RESET}"
    echo -e "${MAGENTA}${BOLD}  ╚════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${GREEN}  🔒 YANG DILINDUNGI:${RESET}"
    echo -e "  ${GREEN}     ✔  Provider  → unknown (metadata diblokir + file dikosongkan)${RESET}"
    echo -e "  ${GREEN}     ✔  Region    → unknown (timezone UTC + locale netral)${RESET}"
    echo -e "  ${GREEN}     ✔  Password  → user-data dikunci chattr +i + history dibersihkan${RESET}"
    echo -e "  ${GREEN}     ✔  Public IP → diblokir dari ifconfig.me & semua IP-lookup${RESET}"
    echo ""
    echo -e "  ${RED}  🔒 DIBLOKIR LAINNYA:${RESET}"
    echo -e "  ${RED}     ✖  Nest, Eggs, Nodes, Locations, API Keys, Delete Server${RESET}"
    echo -e "  ${RED}     ✖  PLTA & PLTC${RESET}"
    echo -e "  ${RED}     ✖  Brute force SSH (auto ban 24 jam)${RESET}"
    echo -e "  ${RED}     ✖  169.254.169.254 → iptables DROP${RESET}"
    echo -e "  ${RED}     ✖  Bash history root dinonaktifkan${RESET}"
    echo -e "  ${RED}     ✖  Console log sanitasi tiap menit${RESET}"
    echo -e "  ${RED}     ✖  Anti Kill Panel — watchdog auto-restart nginx/wings${RESET}"
    echo -e "  ${RED}     ✖  Anti Disk Abuse — disk guard + auto cleanup${RESET}"
    echo -e "  ${RED}     ✖  Anti SSH Kill — SSH guard tiap menit + OOM protected${RESET}"
    echo -e "  ${RED}     ✖  Anti Overload — rate limit nginx + anti flood iptables${RESET}"
    echo -e "  ${RED}     ✖  Anti Fork Bomb — max 500 proses per user${RESET}"
    echo -e "  ${RED}     ✖  Anti OOM Kill — nginx & wings dilindungi dari RAM habis${RESET}"
    echo ""
    echo -e "  ${GREEN}  ✅ BEBAS DIAKSES:${RESET}"
    echo -e "  ${GREEN}     ✔  File Manager (upload/download/running bot)${RESET}"
    echo -e "  ${GREEN}     ✔  Console, Start/Stop/Restart server${RESET}"
    echo -e "  ${GREEN}     ✔  Port 22, 80, 443, 8080, 2022${RESET}"
    echo ""
    print_success
}

# ============================================================
# UNINSTALL ALL
# ============================================================
uninstall_all() {
    clear_screen; print_banner
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

    log_info "Menghapus nginx snippets..."
    for s in /etc/nginx/snippets/shikimori_v1.conf \
              /etc/nginx/snippets/shikimori_v2.conf; do
        [ -f "$s" ] && rm -f "$s" && log_ok "Dihapus: $s"
    done

    log_info "Mengembalikan nginx config..."
    RESTORED=0
    for bak in "${NGINX_CONF}.shikimori.bak" "${NGINX_CONF}.shikimori.v2.bak"; do
        if [ -f "$bak" ]; then
            cp "$bak" "$NGINX_CONF" && rm -f "$bak"
            log_ok "Nginx config dikembalikan."; RESTORED=1; break
        fi
    done
    if [ "$RESTORED" -eq 0 ] && [ -n "$NGINX_CONF" ] && [ -f "$NGINX_CONF" ]; then
        sed -i '/shikimori/d' "$NGINX_CONF" 2>/dev/null
        log_ok "Baris shikimori dihapus dari nginx config."
    fi
    sed -i '/server_tokens off/d' /etc/nginx/nginx.conf 2>/dev/null
    sed -i '/SHIKIMORI Rate Limit Zones/d' /etc/nginx/nginx.conf 2>/dev/null
    sed -i '/shikimori_api\|shikimori_login\|shikimori_conn/d' /etc/nginx/nginx.conf 2>/dev/null
    sed -i '/limit_conn shikimori_conn/d' /etc/nginx/nginx.conf 2>/dev/null
    sed -i '/limit_req zone=shikimori/d' /etc/nginx/nginx.conf 2>/dev/null
    nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null && log_ok "Nginx direload."

    log_info "Menghapus PHP Middleware..."
    for mw in \
        "$PTERO_DIR/app/Http/Middleware/ShikimoriV1Protect.php" \
        "$PTERO_DIR/app/Http/Middleware/ShikimoriV2Protect.php"; do
        [ -f "$mw" ] && rm -f "$mw" && log_ok "Dihapus: $(basename "$mw")"
    done

    KERNEL="$PTERO_DIR/app/Http/Kernel.php"
    if [ -f "$KERNEL" ]; then
        sed -i '/ShikimoriV1Protect/d' "$KERNEL" 2>/dev/null
        sed -i '/ShikimoriV2Protect/d' "$KERNEL" 2>/dev/null
        log_ok "Middleware dihapus dari Kernel.php."
    fi

    if [ -d "$PTERO_DIR" ]; then
        cd "$PTERO_DIR" || true
        php artisan config:clear 2>/dev/null; php artisan route:clear 2>/dev/null
        php artisan cache:clear  2>/dev/null; php artisan config:cache 2>/dev/null
        php artisan route:cache  2>/dev/null
        log_ok "Laravel cache diperbarui."
    fi

    log_info "Mengembalikan SSH config..."
    SSHD="/etc/ssh/sshd_config"
    if [ -f "${SSHD}.shikimori.bak" ]; then
        cp "${SSHD}.shikimori.bak" "$SSHD" && rm -f "${SSHD}.shikimori.bak"
    else
        sed -i 's/^MaxAuthTries 3/#MaxAuthTries 6/'                        "$SSHD" 2>/dev/null
        sed -i 's/^LoginGraceTime 30/#LoginGraceTime 120/'                 "$SSHD" 2>/dev/null
        sed -i 's/^PermitRootLogin no/#PermitRootLogin prohibit-password/' "$SSHD" 2>/dev/null
        sed -i '/^DebianBanner no/d'                                        "$SSHD" 2>/dev/null
        sed -i 's/^PasswordAuthentication no/#PasswordAuthentication yes/' "$SSHD" 2>/dev/null
    fi
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
    log_ok "SSH config dikembalikan."

    [ -f /etc/sysctl.d/99-shikimori.conf ] && \
        rm -f /etc/sysctl.d/99-shikimori.conf && \
        sysctl --system >/dev/null 2>&1 && log_ok "Kernel rules dihapus."

    [ -f /etc/fail2ban/jail.d/shikimori.conf ] && \
        rm -f /etc/fail2ban/jail.d/shikimori.conf && \
        systemctl restart fail2ban 2>/dev/null && log_ok "Fail2Ban config dihapus."

    ufw --force reset 2>/dev/null && ufw --force disable 2>/dev/null
    log_ok "UFW direset."

    log_info "Membersihkan /etc/hosts..."
    for domain in \
        "ifconfig.me" "ipinfo.io" "ipapi.co" "api.ipify.org" \
        "api64.ipify.org" "api4.my-ip.io" "checkip.amazonaws.com" \
        "icanhazip.com" "ip-api.com" "ipgeolocation.io" \
        "extreme-ip-lookup.com" "ipwhois.app" "ipwho.is" \
        "myip.wtf" "wtfismyip.com" "ident.me" "ipecho.net" \
        "metadata.google.internal" "metadata.google.com" \
        "metadata.digitalocean.com" "geoip.maxmind.com" \
        "geolite.maxmind.com" "geoip2.maxmind.com" "169.254.169.254"; do
        sed -i "/${domain}/d" /etc/hosts 2>/dev/null
    done
    log_ok "/etc/hosts dibersihkan."

    log_info "Mengembalikan cloud-init files..."
    for f in \
        /var/lib/cloud/instance/user-data.txt \
        /var/lib/cloud/instance/user-data.txt.i \
        /run/cloud-init/instance-data.json \
        /run/cloud-init/instance-data-sensitive.json; do
        if [ -f "${f}.shikimori.bak" ]; then
            chattr -i "$f" 2>/dev/null || true
            chmod 600 "$f" 2>/dev/null
            cp "${f}.shikimori.bak" "$f" && rm -f "${f}.shikimori.bak"
            log_ok "Dikembalikan: $(basename "$f")"
        fi
    done

    log_info "Menghapus iptables block..."
    iptables  -D OUTPUT    -d 169.254.169.254/32 -j DROP 2>/dev/null || true
    iptables  -D FORWARD   -d 169.254.169.254/32 -j DROP 2>/dev/null || true
    iptables  -D DOCKER-USER -d 169.254.169.254/32 -j DROP 2>/dev/null || true
    ip6tables -D OUTPUT    -d 169.254.169.254/32 -j DROP 2>/dev/null || true
    iptables-save > /etc/iptables/rules.v4 2>/dev/null
    log_ok "Iptables block dihapus."

    [ -f /etc/systemd/system/wings.service.d/shikimori-env.conf ] && \
        rm -f /etc/systemd/system/wings.service.d/shikimori-env.conf && \
        systemctl daemon-reload 2>/dev/null && log_ok "Wings env override dihapus."

    log_info "Menghapus systemd restart & anti-kill overrides..."
    for svc in nginx wings ssh sshd; do
        DIR="/etc/systemd/system/${svc}.service.d"
        [ -f "$DIR/shikimori-restart.conf" ] && rm -f "$DIR/shikimori-restart.conf"
        [ -f "$DIR/shikimori-ssh.conf" ]     && rm -f "$DIR/shikimori-ssh.conf"
    done
    systemctl daemon-reload 2>/dev/null
    log_ok "Systemd restart overrides dihapus."

    log_info "Menghapus limits.conf entries..."
    sed -i '/shikimori-disk/,+4d'     /etc/security/limits.conf 2>/dev/null
    sed -i '/shikimori-forkbomb/,+4d' /etc/security/limits.conf 2>/dev/null
    log_ok "limits.conf dibersihkan."

    log_info "Menghapus nginx rate limit snippet..."
    rm -f /etc/nginx/snippets/shikimori_ratelimit.conf 2>/dev/null
    log_ok "Rate limit snippet dihapus."

    log_info "Menghapus anti-flood iptables rules..."
    iptables -D INPUT -p tcp --syn -m limit --limit 25/s --limit-burst 50 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --syn -j DROP 2>/dev/null || true
    iptables -D INPUT -m state --state INVALID -j DROP 2>/dev/null || true
    iptables-save > /etc/iptables/rules.v4 2>/dev/null
    log_ok "Anti-flood iptables rules dihapus."

    log_info "Mengembalikan os-release..."
    [ -f /etc/os-release.shikimori.bak ] && \
        cp /etc/os-release.shikimori.bak /etc/os-release && \
        rm -f /etc/os-release.shikimori.bak && log_ok "os-release dikembalikan."

    log_info "Mengembalikan timezone..."
    [ -f /etc/timezone.shikimori.bak ] && \
        ORIG_TZ=$(cat /etc/timezone.shikimori.bak) && \
        timedatectl set-timezone "$ORIG_TZ" 2>/dev/null && \
        rm -f /etc/timezone.shikimori.bak && log_ok "Timezone dikembalikan: $ORIG_TZ"

    log_info "Mengembalikan locale..."
    [ -f /etc/default/locale.shikimori.bak ] && \
        cp /etc/default/locale.shikimori.bak /etc/default/locale && \
        rm -f /etc/default/locale.shikimori.bak && log_ok "Locale dikembalikan."

    log_info "Mengembalikan bash history setting..."
    sed -i '/SHIKIMORI - Disable bash history/,+3d' /root/.bashrc 2>/dev/null
    log_ok "Bash history setting dikembalikan."

    log_info "Mengembalikan hostname..."
    if [ -f /etc/shikimori_original_hostname ]; then
        ORIG=$(cat /etc/shikimori_original_hostname)
        hostnamectl set-hostname "$ORIG" 2>/dev/null
        rm -f /etc/shikimori_original_hostname
        log_ok "Hostname dikembalikan: unknown → ${ORIG}"
    else
        log_warn "Ubah manual: hostnamectl set-hostname NAMA_VPS"
    fi

    if [ -f /etc/machine-id.shikimori.bak ]; then
        cp /etc/machine-id.shikimori.bak /etc/machine-id
        rm -f /etc/machine-id.shikimori.bak
        log_ok "machine-id dikembalikan."
    fi

    crontab -l 2>/dev/null | grep -v "console_faker.sh" | grep -v "watchdog.sh" | \
        grep -v "disk_guard.sh" | grep -v "ssh_guard.sh" | grep -v "cpu_guard.sh" | \
        crontab - 2>/dev/null
    [ -d /opt/shikimori ] && rm -rf /opt/shikimori
    log_ok "Cron & /opt/shikimori dihapus."

    # Kembalikan provider identity files
    for id_file in /etc/digitalocean /etc/vultr /etc/do-agent; do
        if [ -f "${id_file}.shikimori.bak" ]; then
            chattr -i "$id_file" 2>/dev/null || true
            cp "${id_file}.shikimori.bak" "$id_file"
            rm -f "${id_file}.shikimori.bak"
            log_ok "Dikembalikan: $(basename "$id_file")"
        fi
    done

    progress_bar "Menyelesaikan Uninstall..."
    echo ""
    echo -e "${GREEN}${BOLD}  ╔════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}${BOLD}  ║      ✅  SEMUA PROTEKSI BERHASIL DIHAPUS! ✅           ║${RESET}"
    echo -e "${GREEN}${BOLD}  ╚════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${CYAN}  VPS & Panel kembali normal. Data & file AMAN.${RESET}"
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
    clear_screen; print_banner; print_menu
    echo -ne "  ${WHITE}${BOLD}Masukkan Pilihan Anda [1-6] :${RESET} "
    read -r choice
    case $choice in
        1) install_v1;    echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali...${RESET}"; read -r ;;
        2) install_v2;    echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali...${RESET}"; read -r ;;
        3) install_v3;    echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali...${RESET}"; read -r ;;
        4) install_v4;    echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali...${RESET}"; read -r ;;
        5) clear_screen
           echo -e "\n${MAGENTA}${BOLD}  🛡️  Terima kasih — SHIKIMORI PROJECT${RESET}"
           echo -e "  ${CYAN}  Developer : t.me/vallcz | YouTube : KAISAR VALL${RESET}\n"
           exit 0 ;;
        6) uninstall_all; echo -ne "\n  ${YELLOW}Tekan ENTER untuk kembali...${RESET}"; read -r ;;
        *) log_err "Pilihan tidak valid! Masukkan angka 1-6."; sleep 1 ;;
    esac
done
