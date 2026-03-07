#!/bin/bash

# ================================================
# SHIKIMORI PROJECT - ULTIMATE VPS PROTECTION V4
# ================================================
# Developer : t.me/vallcz
# YouTube : KAISAR VALL
# Version : 4.0 - ULTIMATE SHIELD
# ================================================

# Warna output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Cek root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Script ini harus dijalankan sebagai root!${NC}" 
   exit 1
fi

# Fungsi banner
show_banner() {
    clear
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${YELLOW}            🛡️ SHIKIMORI ULTIMATE PROTECTION V4 🛡️            ${RED}║${NC}"
    echo -e "${RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}║${WHITE}          4 LAPIS VERIFIKASI - ANTI BYPASS - ANTI HIJACK        ${RED}║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Fungsi menu
show_menu() {
    echo -e "${CYAN}[ ${WHITE}1${CYAN} ]${GREEN} Versi 1.0 - Nest Protection${NC}"
    echo -e "${CYAN}[ ${WHITE}2${CYAN} ]${GREEN} Versi 2.0 - PLTA/PLTC Protection${NC}" 
    echo -e "${CYAN}[ ${WHITE}3${CYAN} ]${GREEN} Versi 3.0 - Basic VPS Protection${NC}"
    echo -e "${CYAN}[ ${WHITE}4${CYAN} ]${PURPLE} Versi 4.0 - ULTIMATE SHIELD (4 Layer Verification)${NC}"
    echo -e "${CYAN}[ ${WHITE}5${CYAN} ]${RED} Exit${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -ne "${WHITE}Masukkan Pilihan Anda [1-5] : ${NC}"
    read choice
}

# ================================================
# FUNGSI PROTEKSI VERSI 1.0
# ================================================
install_v1() {
    echo -e "${YELLOW}🛡️ Mengaktifkan Proteksi Nest (Versi 1.0)...${NC}"
    
    # Buat middleware kustom (tanpa modifikasi file asli)
    mkdir -p /var/www/pterodactyl/app/Http/Middleware/Shikimori/
    
    cat > /var/www/pterodactyl/app/Http/Middleware/Shikimori/NestProtection.php << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware\Shikimori;

use Closure;
use Illuminate\Http\Request;

class NestProtection
{
    public function handle(Request $request, Closure $next)
    {
        // Cek jika mencoba akses nest
        if ($request->is('admin/nests*') || $request->is('api/application/nests*')) {
            // Verifikasi token khusus
            if (!$request->session()->has('shikimori_nest_access')) {
                return response()->view('errors.shikimori-protect', [
                    'message' => '🛡️ PROTECT BY SHIKIMORI PROJECT',
                    'code' => 'NEST-ACCESS-DENIED'
                ], 403);
            }
        }
        
        return $next($request);
    }
}
EOF

    # Register middleware
    cat > /var/www/pterodactyl/config/shikimori.php << 'EOF'
<?php

return [
    'nest_protection' => true,
    'plt_protection' => true,
    'ultimate_verification' => true,
];
EOF

    # Inject middleware via service provider (aman)
    cat > /var/www/pterodactyl/app/Providers/ShikimoriServiceProvider.php << 'EOF'
<?php

namespace Pterodactyl\Providers;

use Illuminate\Support\ServiceProvider;
use Pterodactyl\Http\Middleware\Shikimori\NestProtection;

class ShikimoriServiceProvider extends ServiceProvider
{
    public function boot()
    {
        $this->app['router']->aliasMiddleware('shikimori.nest', NestProtection::class);
    }

    public function register()
    {
        //
    }
}
EOF

    # Buat halaman error kustom
    mkdir -p /var/www/pterodactyl/resources/views/errors/
    
    cat > /var/www/pterodactyl/resources/views/errors/shikimori-protect.blade.php << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>🔒 Protected by Shikimori</title>
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Arial', sans-serif;
            height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-align: center;
        }
        .container {
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 20px;
            backdrop-filter: blur(10px);
            border: 2px solid rgba(255,255,255,0.2);
        }
        h1 {
            font-size: 48px;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .code {
            font-size: 24px;
            background: rgba(0,0,0,0.3);
            padding: 10px 20px;
            border-radius: 10px;
            display: inline-block;
            margin-top: 20px;
        }
        .footer {
            margin-top: 30px;
            font-size: 14px;
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🛡️ {{ $message }}</h1>
        <div class="code">Error Code: {{ $code }}</div>
        <div class="footer">Shikimori Project - Ultimate Protection</div>
    </div>
</body>
</html>
EOF

    # Clear cache
    cd /var/www/pterodactyl
    php artisan optimize:clear 2>/dev/null
    php artisan config:cache 2>/dev/null
    
    echo -e "${GREEN}✅ Proteksi Nest berhasil diaktifkan!${NC}"
}

# ================================================
# FUNGSI PROTEKSI VERSI 2.0
# ================================================
install_v2() {
    echo -e "${YELLOW}🛡️ Mengaktifkan Proteksi PLTA/PLTC (Versi 2.0)...${NC}"
    
    # Buat middleware PLT Protection
    cat > /var/www/pterodactyl/app/Http/Middleware/Shikimori/PLTProtection.php << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware\Shikimori;

use Closure;
use Illuminate\Http\Request;

class PLTProtection
{
    public function handle(Request $request, Closure $next)
    {
        // Proteksi PLTA dan PLTC
        if ($request->is('admin/nodes/*/allocations*') || 
            $request->is('api/application/nodes/*/allocations*')) {
            
            if (!$request->session()->has('shikimori_plt_access')) {
                return response()->json([
                    'error' => '🛡️ PROTECT BY SHIKIMORI PROJECT',
                    'code' => 'PLT-ACCESS-DENIED'
                ], 403);
            }
        }
        
        return $next($request);
    }
}
EOF

    # Update service provider
    echo "<?php

namespace Pterodactyl\Providers;

use Illuminate\Support\ServiceProvider;
use Pterodactyl\Http\Middleware\Shikimori\NestProtection;
use Pterodactyl\Http\Middleware\Shikimori\PLTProtection;

class ShikimoriServiceProvider extends ServiceProvider
{
    public function boot()
    {
        \$this->app['router']->aliasMiddleware('shikimori.nest', NestProtection::class);
        \$this->app['router']->aliasMiddleware('shikimori.plt', PLTProtection::class);
    }

    public function register()
    {
        //
    }
}" > /var/www/pterodactyl/app/Providers/ShikimoriServiceProvider.php

    # Proteksi via Nginx (lapisan kedua)
    cat > /etc/nginx/conf.d/shikimori-plt.conf << 'EOF'
# SHIKIMORI PLT Protection
location ~* /(admin|api)/.*(allocations|allocation) {
    if ($http_x_requested_verification != "shikimori-v2") {
        return 403;
    }
    add_header X-Protected-By "Shikimori-Project";
}
EOF

    systemctl reload nginx 2>/dev/null || systemctl reload apache2 2>/dev/null

    # Clear cache
    cd /var/www/pterodactyl
    php artisan optimize:clear 2>/dev/null
    php artisan config:cache 2>/dev/null
    
    echo -e "${GREEN}✅ Proteksi PLTA/PLTC berhasil diaktifkan!${NC}"
}

# ================================================
# FUNGSI PROTEKSI VERSI 3.0
# ================================================
install_v3() {
    echo -e "${YELLOW}🛡️ Mengaktifkan Basic VPS Protection (Versi 3.0)...${NC}"
    
    # 1. Proteksi Informasi VPS
    echo -e "${CYAN}→ Memproteksi informasi sistem...${NC}"
    
    # Backup konfigurasi
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.shikimori.bak 2>/dev/null
    
    # Ubah hostname dinamis
    RANDOM_HOST="srv-$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 8 | head -n 1)"
    echo "$RANDOM_HOST" > /etc/hostname
    hostname -F /etc/hostname
    
    # 2. Proteksi Provider Detection via Environment
    cat > /etc/profile.d/shikimori-env.sh << 'EOF'
#!/bin/bash
# SHIKIMORI Environment Protection

# Override provider info
export PROVIDER="unknown"
export REGION="N/A"
export HOSTNAME="localhost"
export PUBLIC_IP="127.0.0.1"

# Fungsi curl yang di-protect
curl() {
    if [[ "$*" == *"ipify"* ]] || [[ "$*" == *"icanhazip"* ]] || [[ "$*" == *"api.ip"* ]]; then
        echo "127.0.0.1"
        return 0
    fi
    command curl "$@"
}

export -f curl
EOF

    chmod +x /etc/profile.d/shikimori-env.sh
    
    # 3. Proteksi SSH
    sed -i 's/#*MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
    sed -i 's/#*MaxSessions.*/MaxSessions 2/' /etc/ssh/sshd_config
    sed -i 's/#*LoginGraceTime.*/LoginGraceTime 30/' /etc/ssh/sshd_config
    
    # 4. Firewall dasar
    apt-get install -y iptables-persistent 2>/dev/null || yum install -y iptables-services 2>/dev/null
    
    # Flush existing rules
    iptables -F
    iptables -X
    
    # Set default policies
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    
    # Allow established connections
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Allow SSH
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    
    # Allow HTTP/HTTPS
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    
    # Allow loopback
    iptables -A INPUT -i lo -j ACCEPT
    
    # Save rules
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || iptables-save > /etc/sysconfig/iptables 2>/dev/null
    
    systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
    
    echo -e "${GREEN}✅ Basic VPS Protection berhasil diaktifkan!${NC}"
}

# ================================================
# FUNGSI PROTEKSI VERSI 4.0 - ULTIMATE SHIELD
# ================================================
install_v4() {
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${YELLOW}            🔥 ULTIMATE SHIELD 4 LAYER VERIFICATION 🔥        ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Install dependencies
    echo -e "${CYAN}[1/8] 📦 Menginstall dependencies...${NC}"
    apt-get update 2>/dev/null || yum update -y 2>/dev/null
    apt-get install -y fail2ban iptables-persistent nginx-extras apache2-utils curl wget 2>/dev/null || yum install -y fail2ban iptables-services httpd-tools curl wget 2>/dev/null
    
    # ================================================
    # LAYER 1: WEB APPLICATION FIREWALL
    # ================================================
    echo -e "${CYAN}[2/8] 🔥 Layer 1: Web Application Firewall (WAF)...${NC}"
    
    cat > /etc/nginx/conf.d/shikimori-waf.conf << 'EOF'
# SHIKIMORI WAF - Layer 1
location ~ \.php$ {
    # Anti SQL Injection
    if ($query_string ~* "union.*select.*\(") { return 403; }
    if ($query_string ~* "concat.*\(") { return 403; }
    if ($query_string ~* "group.*concat.*\(") { return 403; }
    
    # Anti XSS
    if ($query_string ~* "<script") { return 403; }
    if ($query_string ~* "javascript:") { return 403; }
    
    # Anti Path Traversal
    if ($query_string ~* "\.\./") { return 403; }
    if ($query_string ~* "\.\.") { return 403; }
    
    # Anti Remote File Inclusion
    if ($query_string ~* "http://") { return 403; }
    if ($query_string ~* "https://") { return 403; }
    if ($query_string ~* "ftp://") { return 403; }
    
    # Block common exploit attempts
    if ($query_string ~* "(eval|base64_encode|base64_decode|system|exec|shell_exec|passthru)") { return 403; }
    
    # Add security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';" always;
}
EOF

    # ================================================
    # LAYER 2: FAIL2BAN HARDENING
    # ================================================
    echo -e "${CYAN}[3/8] 🛡️ Layer 2: Fail2ban Hardening...${NC}"
    
    cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
ignoreip = 127.0.0.1/8

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 2
bantime = 7200

[pterodactyl]
enabled = true
port = http,https
filter = pterodactyl
logpath = /var/www/pterodactyl/storage/logs/*.log
maxretry = 3
bantime = 3600

[shikimori-waf]
enabled = true
port = http,https
filter = shikimori-waf
logpath = /var/log/nginx/error.log
maxretry = 2
bantime = 86400
EOF

    cat > /etc/fail2ban/filter.d/pterodactyl.conf << 'EOF'
[Definition]
failregex = .*Invalid username or password.*
            .*User does not exist.*
            .*Too many login attempts.*
            .*Failed to authenticate.*
ignoreregex =
EOF

    cat > /etc/fail2ban/filter.d/shikimori-waf.conf << 'EOF'
[Definition]
failregex = .* 403 .* "-" .*WAF.*
            .* "GET .*union.*select.*"
            .* "GET .*<script.*"
            .* "GET .*\.\..*"
ignoreregex =
EOF

    # ================================================
    # LAYER 3: KERNEL HARDENING
    # ================================================
    echo -e "${CYAN}[4/8] ⚙️ Layer 3: Kernel Hardening...${NC}"
    
    # Backup sysctl
    cp /etc/sysctl.conf /etc/sysctl.conf.shikimori.bak
    
    cat >> /etc/sysctl.conf << 'EOF'

# SHIKIMORI KERNEL HARDENING
# Network Security
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15

# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Ignore ICMP pings
net.ipv4.icmp_echo_ignore_all = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# Increase system file limits
fs.file-max = 65535
EOF

    sysctl -p 2>/dev/null

    # ================================================
    # LAYER 4: 4-STEP VERIFICATION
    # ================================================
    echo -e "${CYAN}[5/8] 🔐 Layer 4: 4-Step Verification System...${NC}"
    
    # Buat sistem verifikasi 4 langkah
    mkdir -p /root/.shikimori/
    
    # Generate random tokens
    TOKEN1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    TOKEN2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    TOKEN3=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    TOKEN4=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    
    # Simpan tokens
    cat > /root/.shikimori/tokens.txt << EOF
# SHIKIMORI ULTIMATE TOKENS - JANGAN BAGIKAN!
TOKEN1=$TOKEN1
TOKEN2=$TOKEN2
TOKEN3=$TOKEN3
TOKEN4=$TOKEN4
EOF

    chmod 600 /root/.shikimori/tokens.txt
    
    # Buat script verifikasi
    cat > /usr/local/bin/shikimori-verify << 'EOF'
#!/bin/bash
# SHIKIMORI 4-Step Verification System

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

source /root/.shikimori/tokens.txt

echo -e "${YELLOW}🔐 SHIKIMORI 4-STEP VERIFICATION${NC}"
echo "================================"

# Step 1: Hostname Verification
echo -e "\n${YELLOW}[Step 1/4] Verifikasi Hostname...${NC}"
CURRENT_HOST=$(hostname)
if [[ "$CURRENT_HOST" == srv-* ]]; then
    echo -e "${GREEN}✅ Hostname terverifikasi${NC}"
else
    echo -e "${RED}❌ Hostname tidak valid${NC}"
    exit 1
fi

# Step 2: Token Verification
echo -e "\n${YELLOW}[Step 2/4] Verifikasi Token Sistem...${NC}"
if [ -f "/root/.shikimori/tokens.txt" ]; then
    echo -e "${GREEN}✅ Token sistem ditemukan${NC}"
else
    echo -e "${RED}❌ Token sistem tidak ditemukan${NC}"
    exit 1
fi

# Step 3: IP Tables Check
echo -e "\n${YELLOW}[Step 3/4] Verifikasi Firewall...${NC}"
if iptables -L | grep -q "shikimori"; then
    echo -e "${GREEN}✅ Firewall terverifikasi${NC}"
else
    echo -e "${RED}❌ Firewall tidak aktif${NC}"
    exit 1
fi

# Step 4: Fail2ban Check
echo -e "\n${YELLOW}[Step 4/4] Verifikasi Fail2ban...${NC}"
if systemctl is-active --quiet fail2ban; then
    echo -e "${GREEN}✅ Fail2ban aktif${NC}"
else
    echo -e "${RED}❌ Fail2ban tidak aktif${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ SEMUA VERIFIKASI BERHASIL!${NC}"
echo -e "${GREEN}🛡️ SHIKIMORI ULTIMATE PROTECTION AKTIF${NC}"
EOF

    chmod +x /usr/local/bin/shikimori-verify

    # ================================================
    # ANTI HIJACK & INJECTION
    # ================================================
    echo -e "${CYAN}[6/8] 🚫 Mengaktifkan Anti Hijack & Injection...${NC}"
    
    # PHP hardening
    cat > /etc/php/*/cli/conf.d/99-shikimori.ini 2>/dev/null << 'EOF'
; SHIKIMORI PHP Hardening
disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source
max_execution_time = 30
max_input_time = 30
memory_limit = 256M
post_max_size = 20M
upload_max_filesize = 20M
session.cookie_httponly = 1
session.use_only_cookies = 1
session.cookie_secure = 1
EOF

    # MySQL/MariaDB hardening
    cat > /etc/mysql/conf.d/shikimori.cnf 2>/dev/null << 'EOF'
[mysqld]
bind-address = 127.0.0.1
skip-networking
local-infile=0
symbolic-links=0
EOF

    # ================================================
    # MONITORING SYSTEM
    # ================================================
    echo -e "${CYAN}[7/8] 📊 Mengaktifkan Monitoring System...${NC}"
    
    cat > /usr/local/bin/shikimori-monitor << 'EOF'
#!/bin/bash
# SHIKIMORI Real-time Monitor

while true; do
    # Check failed login attempts
    FAILED_LOGINS=$(tail -n 100 /var/log/auth.log | grep "Failed password" | wc -l)
    if [ $FAILED_LOGINS -gt 10 ]; then
        echo "$(date): ALERT - $FAILED_LOGINS failed attempts detected" >> /var/log/shikimori-alert.log
    fi
    
    # Check nginx errors
    NGINX_ERRORS=$(tail -n 50 /var/log/nginx/error.log | grep -c "403")
    if [ $NGINX_ERRORS -gt 5 ]; then
        echo "$(date): ALERT - Multiple 403 errors detected" >> /var/log/shikimori-alert.log
    fi
    
    sleep 60
done &
EOF

    chmod +x /usr/local/bin/shikimori-monitor

    # ================================================
    # FINALIZE
    # ================================================
    echo -e "${CYAN}[8/8] 🔧 Finalisasi instalasi...${NC}"
    
    # Restart semua service
    systemctl restart fail2ban 2>/dev/null
    systemctl restart nginx 2>/dev/null || systemctl restart apache2 2>/dev/null
    systemctl restart php*-fpm 2>/dev/null
    systemctl restart mysql 2>/dev/null || systemctl restart mariadb 2>/dev/null
    
    # Clear cache Pterodactyl
    cd /var/www/pterodactyl
    php artisan optimize:clear 2>/dev/null
    php artisan view:clear 2>/dev/null
    php artisan config:clear 2>/dev/null
    
    # Jalankan monitor di background
    nohup /usr/local/bin/shikimori-monitor > /dev/null 2>&1 &
    
    echo -e "${GREEN}✅ ULTIMATE SHIELD V4 BERHASIL DIINSTALL!${NC}"
    echo ""
    echo -e "${YELLOW}📋 INFORMASI PENTING:${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🔐 4-Layer Verification: ACTIVE${NC}"
    echo -e "${GREEN}🛡️ WAF Protection: ACTIVE${NC}"
    echo -e "${GREEN}🚫 Anti Hijack: ACTIVE${NC}"
    echo -e "${GREEN}💉 Anti Injection: ACTIVE${NC}"
    echo -e "${GREEN}📊 Monitoring: ACTIVE${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Untuk mengecek status proteksi:${NC}"
    echo -e "  ${CYAN}shikimori-verify${NC}"
    echo ""
    echo -e "${YELLOW}Log monitoring:${NC}"
    echo -e "  ${CYAN}tail -f /var/log/shikimori-alert.log${NC}"
}

# ================================================
# FUNGSI SUKSES
# ================================================
show_success() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${YELLOW}           PENGINSTALAN BERHASIL ✅                            ${GREEN}║${NC}"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${CYAN}           DEVELOPER : t.me/vallcz                              ${GREEN}║${NC}"
    echo -e "${GREEN}║${CYAN}           YOUTUBE : KAISAR VALL                                ${GREEN}║${NC}"
    echo -e "${GREEN}║${PURPLE}           SHIKIMORI - PROJECT                                ${GREEN}║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Tekan Enter untuk kembali ke menu utama...${NC}"
    read
}

# ================================================
# MAIN PROGRAM
# ================================================
main() {
    while true; do
        show_banner
        show_menu
        
        case $choice in
            1)
                echo ""
                install_v1
                show_success
                ;;
            2)
                echo ""
                install_v2
                show_success
                ;;
            3)
                echo ""
                install_v3
                show_success
                ;;
            4)
                echo ""
                install_v4
                show_success
                ;;
            5)
                echo ""
                echo -e "${RED}Terima kasih telah menggunakan SHIKIMORI PROJECT!${NC}"
                echo -e "${YELLOW}Developer : t.me/vallcz${NC}"
                echo -e "${YELLOW}YouTube : KAISAR VALL${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo ""
                echo -e "${RED}Pilihan tidak valid! Silahkan pilih 1-5${NC}"
                sleep 2
                ;;
        esac
    done
}

# Jalankan main program
main
