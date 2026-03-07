#!/bin/bash
# 🛡️ SHIKIMORI PROJECT - VPS & PTERODACTYL PROTECTION
# Developer: t.me/vallcz | YouTube: KAISAR VALL

# Warna
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; NC='\033[0m'

# Cek root
[[ $EUID -ne 0 ]] && { echo -e "${RED}❌ JALANKAN SEBAGAI ROOT!${NC}"; exit 1; }

# Banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║      🛡️ SHIKIMORI PROJECT - VPS PROTECTION 🛡️            ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Menu utama
show_menu() {
    show_banner
    echo -e "${YELLOW}Pilih tingkat keamanan:${NC}"
    echo ""
    echo -e "${GREEN}[1]${NC} Versi 1.0 - Block NEST Panel"
    echo -e "${GREEN}[2]${NC} Versi 2.0 - Block PLTA/PLTC"
    echo -e "${GREEN}[3]${NC} Versi 3.0 - Super Hardest Protection"
    echo -e "${GREEN}[4]${NC} Versi 4.0 - SHIKIMORI ULTIMATE"
    echo -e "${GREEN}[5]${NC} Exit"
    echo ""
    read -p "Masukkan pilihan [1-5]: " pilih
    case $pilih in
        1) versi_1 ;;
        2) versi_2 ;;
        3) versi_3 ;;
        4) versi_4 ;;
        5) echo -e "${YELLOW}Thanks - t.me/vallcz${NC}"; exit 0 ;;
        *) echo -e "${RED}Pilihan salah!${NC}"; sleep 2; show_menu ;;
    esac
}

# Pesan sukses
success_msg() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║              🎉 PENGINSTALAN BERHASIL! 🎉                 ║"
    echo "╠═══════════════════════════════════════════════════════════╣"
    echo "║  👤 DEVELOPER  : t.me/vallcz                              ║"
    echo "║  📺 YOUTUBE    : KAISAR VALL                              ║"
    echo "║  🛡️ PROJECT    : SHIKIMORI PROJECT                        ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    read -p "Tekan Enter untuk kembali ke menu..."
    show_menu
}

# Versi 1 - Block Nest
versi_1() {
    show_banner
    echo -e "${YELLOW}🔧 Install Versi 1.0 - Block NEST Panel...${NC}"
    [[ -d "/var/www/pterodactyl" ]] && {
        mkdir -p /var/www/pterodactyl/app/Http/Middleware
        cat > /var/www/pterodactyl/app/Http/Middleware/NestProtection.php << 'EOF'
<?php namespace App\Http\Middleware; use Closure; class NestProtection {
public function handle($r, Closure $n) { if(strpos($r->path(),'nest')!==false) return response("🛡️ SHIKIMORI",403); return $n($r); } }
EOF
        chown -R www-data:www-data /var/www/pterodactyl
        systemctl restart nginx 2>/dev/null
        echo -e "${GREEN}✅ NEST Panel terblokir!${NC}"
    } || echo -e "${YELLOW}⚠️ Pterodactyl tidak ditemukan${NC}"
    success_msg
}

# Versi 2 - Block PLTA/PLTC
versi_2() {
    show_banner
    echo -e "${YELLOW}🔧 Install Versi 2.0 - Block PLTA/PLTC...${NC}"
    [[ -d "/var/www/pterodactyl" ]] && {
        mkdir -p /var/www/pterodactyl/app/Http/Middleware
        cat > /var/www/pterodactyl/app/Http/Middleware/PLTProtection.php << 'EOF'
<?php namespace App\Http\Middleware; use Closure; class PLTProtection {
public function handle($r, Closure $n) { foreach(['plta','pltc'] as $p){ if(strpos($r->path(),$p)!==false) return response("🛡️ SHIKIMORI",403);} return $n($r); } }
EOF
        chown -R www-data:www-data /var/www/pterodactyl
        systemctl restart nginx 2>/dev/null
        echo -e "${GREEN}✅ PLTA/PLTC terblokir!${NC}"
    } || echo -e "${YELLOW}⚠️ Pterodactyl tidak ditemukan${NC}"
    success_msg
}

# Versi 3 - Super Protection
versi_3() {
    show_banner
    echo -e "${YELLOW}🔧 Install Versi 3.0 - Super Hardest Protection...${NC}"
    apt update && apt install -y fail2ban ufw iptables-persistent
    
    # Firewall
    ufw --force disable; ufw --force reset
    ufw default deny incoming; ufw default allow outgoing
    ufw allow 22/tcp; ufw allow 80/tcp; ufw allow 443/tcp; ufw allow 2022/tcp
    echo "y" | ufw enable
    
    # SSH Hardening
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/^PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    systemctl restart sshd
    
    # Masking Provider
    hostnamectl set-hostname "shikimori-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n1)"
    echo "00000000-0000-0000-0000-000000000000" > /etc/machine-id
    
    echo -e "${GREEN}✅ Super Protection aktif!${NC}"
    success_msg
}

# Versi 4 - Ultimate
versi_4() {
    show_banner
    echo -e "${YELLOW}🔧 Install Versi 4.0 - SHIKIMORI ULTIMATE...${NC}"
    versi_1; versi_2; versi_3
    
    # DNS Blokir
    cat >> /etc/hosts << 'EOF'
0.0.0.0 ipinfo.io ip-api.com ifconfig.co ifconfig.me icanhazip.com
EOF
    
    # Iptables ketat
    iptables -P INPUT DROP
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    iptables -A INPUT -p tcp --dport 2022 -j ACCEPT
    netfilter-persistent save 2>/dev/null
    
    echo -e "${GREEN}✅ SHIKIMORI ULTIMATE aktif!${NC}"
    success_msg
}

# Mulai
show_menu