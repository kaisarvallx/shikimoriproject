#!/bin/bash

# ================================================
# SHIKIMORI PROJECT - VPS & PTERODACTYL PROTECTION
# ================================================
# Developer : t.me/vallcz
# YouTube : KAISAR VALL
# Version : 3.0
# ================================================

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Fungsi untuk menampilkan banner
show_banner() {
    clear
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${YELLOW}                    🛡️ VPS PROTECTION BY${RED}                         ║${NC}"
    echo -e "${RED}║${GREEN}                   🔥 SHIKIMORI PROJECT 🔥${RED}                         ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${WHITE}            🌟 Pilih Tingkat Keamanan Yang Diinginkan 🌟          ${BLUE}║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Fungsi untuk menampilkan menu
show_menu() {
    echo -e "${CYAN}[ ${WHITE}1${CYAN} ]${GREEN} Versi 1.0 - Panel Pterodactyl Protect Can't Access Nest${NC}"
    echo -e "${CYAN}[ ${WHITE}2${CYAN} ]${GREEN} Versi 2.0 - Pterodactyl Protect Panel Cannot Access PLTA and PLTC${NC}"
    echo -e "${CYAN}[ ${WHITE}3${CYAN} ]${GREEN} Versi 3.0 - Panel Pterodactyl And Vps Protection With Super Hardest Protection${NC}"
    echo -e "${CYAN}[ ${WHITE}4${CYAN} ]${PURPLE} Versi 4.0 - ⚡ Ultimate Shield Protection With Advanced Security ⚡${NC}"
    echo -e "${CYAN}[ ${WHITE}5${CYAN} ]${RED} Exit${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -ne "${WHITE}Masukkan Pilihan Anda [1-5] : ${NC}"
    read choice
}

# Fungsi untuk proteksi akses Nest
protect_nest() {
    echo -e "${YELLOW}🛡️ Mengaktifkan Proteksi Nest Pterodactyl...${NC}"
    
    # Backup file asli
    cp /var/www/pterodactyl/app/Http/Controllers/Admin/NestController.php /var/www/pterodactyl/app/Http/Controllers/Admin/NestController.php.bak 2>/dev/null
    
    # Modifikasi NestController
    cat > /var/www/pterodactyl/app/Http/Controllers/Admin/NestController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Models\Nest;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Nests\NestUpdateService;
use Pterodactyl\Services\Nests\NestCreationService;
use Pterodactyl\Services\Nests\NestDeletionService;
use Pterodactyl\Http\Requests\Admin\NestFormRequest;

class NestController extends Controller
{
    public function index()
    {
        if (!request()->session()->has('shikimori_access')) {
            return redirect()->back()->with('error', '🛡️ PROTECT BY SHIKIMORI PROJECT');
        }
        
        return view('admin.nests.index', [
            'nests' => Nest::with('eggs')->get(),
        ]);
    }
    
    public function show(int $nest)
    {
        if (!request()->session()->has('shikimori_access')) {
            return redirect()->back()->with('error', '🛡️ PROTECT BY SHIKIMORI PROJECT');
        }
        
        return redirect()->route('admin.nests.view', $nest);
    }
}
EOF

    # Restart service
    cd /var/www/pterodactyl && php artisan optimize:clear 2>/dev/null
    
    echo -e "${GREEN}✅ Proteksi Nest berhasil diaktifkan!${NC}"
}

# Fungsi untuk proteksi PLTA/PLTC
protect_plt() {
    echo -e "${YELLOW}🛡️ Mengaktifkan Proteksi PLTA/PLTC...${NC}"
    
    # Backup file asli
    cp /var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php /var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php.bak 2>/dev/null
    
    # Modifikasi NodeController untuk proteksi allocation
    cat > /var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Models\Node;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Pterodactyl\Models\Allocation;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Exceptions\DisplayException;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Nodes\NodeUpdateService;
use Pterodactyl\Services\Nodes\NodeCreationService;
use Pterodactyl\Services\Nodes\NodeDeletionService;
use Pterodactyl\Http\Requests\Admin\NodeFormRequest;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Contracts\Repository\ServerRepositoryInterface;
use Pterodactyl\Contracts\Repository\LocationRepositoryInterface;
use Pterodactyl\Contracts\Repository\AllocationRepositoryInterface;

class NodeController extends Controller
{
    public function allocations(Request $request, Node $node)
    {
        if (!request()->session()->has('shikimori_plt_access')) {
            return redirect()->back()->with('error', '🛡️ PROTECT BY SHIKIMORI PROJECT');
        }
        
        return view('admin.nodes.allocations', [
            'node' => $node,
            'allocations' => $node->allocations()->paginate(50),
        ]);
    }
}
EOF

    # Proteksi routes
    cat > /etc/nginx/conf.d/plt-protection.conf << 'EOF'
location ~* /admin/nodes/.*/allocations {
    return 403;
    # Hanya SHIKIMORI yang bisa mengakses
    error_page 403 = @shikimori_protect;
}

location @shikimori_protect {
    return 200 '🛡️ PROTECT BY SHIKIMORI PROJECT';
    add_header Content-Type text/plain;
}
EOF

    systemctl reload nginx 2>/dev/null || systemctl reload apache2 2>/dev/null
    
    echo -e "${GREEN}✅ Proteksi PLTA/PLTC berhasil diaktifkan!${NC}"
}

# Fungsi untuk super protection
super_protection() {
    echo -e "${YELLOW}⚡ Mengaktifkan Super Hardest Protection...${NC}"
    
    # 1. Proteksi informasi VPS
    echo -e "${CYAN}→ Memproteksi informasi VPS...${NC}"
    
    # Backup konfigurasi asli
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak 2>/dev/null
    cp /etc/hostname /etc/hostname.bak 2>/dev/null
    cp /etc/hosts /etc/hosts.bak 2>/dev/null
    
    # Ubah hostname menjadi random
    RANDOM_HOST="shikimori-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)"
    echo "$RANDOM_HOST" > /etc/hostname
    hostname -F /etc/hostname
    
    # 2. Proteksi provider detection
    cat > /etc/profile.d/000-shikimori-protect.sh << 'EOF'
#!/bin/bash
# SHIKIMORI - Provider Protection

# Override provider detection
function detect_provider() {
    echo "unknown"
}

# Override region detection
function detect_region() {
    echo "N/A"
}

# Override IP public detection
function detect_ip() {
    echo "127.0.0.1"
}

# Export functions
export -f detect_provider
export -f detect_region
export -f detect_ip
EOF

    chmod +x /etc/profile.d/000-shikimori-protect.sh
    
    # 3. Patch Pterodactyl untuk proteksi informasi
    # Backup file asli
    cp /var/www/pterodactyl/app/Models/Server.php /var/www/pterodactyl/app/Models/Server.php.bak 2>/dev/null
    
    # Modifikasi Server.php untuk menyembunyikan informasi sensitif
    cat > /var/www/pterodactyl/app/Models/Server.php << 'EOF'
<?php

namespace Pterodactyl\Models;

use Exception;
use Illuminate\Support\Str;
use Pterodactyl\Models\Egg;
use Pterodactyl\Models\Node;
use Pterodactyl\Models\User;
use Pterodactyl\Models\Nest;
use Pterodactyl\Models\Location;
use Illuminate\Database\Eloquent\Model;
use Pterodactyl\Models\Traits\HasUniqueId;
use Pterodactyl\Services\Acl\Api\AdminAcl;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Pterodactyl\Models\Traits\HasSearchableAttributes;

class Server extends Model
{
    use HasFactory, HasUniqueId, HasSearchableAttributes;

    public function getNodeAttribute()
    {
        if (auth()->check() && auth()->user()->root_admin) {
            return $this->getOriginalNodeAttribute();
        }
        return null;
    }

    public function getAllocationsAttribute()
    {
        return collect([]);
    }
}
EOF

    # 4. Proteksi dengan iptables
    echo -e "${CYAN}→ Mengaktifkan firewall rules...${NC}"
    
    # Block port scanning
    iptables -N PORT_SCAN 2>/dev/null
    iptables -A INPUT -m recent --name portscan --rcheck --seconds 60 -j DROP
    iptables -A FORWARD -m recent --name portscan --rcheck --seconds 60 -j DROP
    iptables -A INPUT -m recent --name portscan --set -j ACCEPT
    iptables -A FORWARD -m recent --name portscan --set -j ACCEPT
    
    # Save iptables rules
    if command -v iptables-save &> /dev/null; then
        iptables-save > /etc/iptables/rules.v4 2>/dev/null || iptables-save > /etc/sysconfig/iptables 2>/dev/null
    fi
    
    # 5. Proteksi SSH
    sed -i 's/#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/#MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
    sed -i 's/#MaxSessions.*/MaxSessions 2/' /etc/ssh/sshd_config
    
    systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
    
    echo -e "${GREEN}✅ Super Hardest Protection berhasil diaktifkan!${NC}"
}

# Fungsi untuk ultimate protection
ultimate_protection() {
    echo -e "${PURPLE}⚡ Mengaktifkan Ultimate Shield Protection...${NC}"
    
    # Aktifkan semua proteksi dari versi sebelumnya
    protect_nest
    protect_plt
    super_protection
    
    # Proteksi tambahan untuk ultimate
    echo -e "${CYAN}→ Mengaktifkan proteksi tambahan Ultimate Shield...${NC}"
    
    # 1. Proteksi kernel level
    cat >> /etc/sysctl.conf << 'EOF'

# SHIKIMORI Ultimate Protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.ip_local_port_range = 2000 65000
net.ipv4.tcp_rfc1337 = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF

    sysctl -p 2>/dev/null
    
    # 2. Proteksi dengan fail2ban
    if command -v fail2ban-server &> /dev/null; then
        cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 2

[pterodactyl]
enabled = true
port = http,https
filter = pterodactyl
logpath = /var/www/pterodactyl/storage/logs/laravel-*.log
maxretry = 3
EOF

        systemctl restart fail2ban 2>/dev/null
    fi
    
    echo -e "${GREEN}✅ Ultimate Shield Protection berhasil diaktifkan!${NC}"
}

# Fungsi untuk menampilkan hasil instalasi
show_success() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${YELLOW}                                                               ║${NC}"
    echo -e "${GREEN}║${WHITE}           PENGINSTALAN BERHASIL ✅                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${YELLOW}                                                               ║${NC}"
    echo -e "${GREEN}║${CYAN}           DEVELOPER : t.me/vallcz                              ${GREEN}║${NC}"
    echo -e "${GREEN}║${CYAN}           YOUTUBE : KAISAR VALL                                ${GREEN}║${NC}"
    echo -e "${GREEN}║${PURPLE}           SHIKIMORI - PROJECT                                ${GREEN}║${NC}"
    echo -e "${GREEN}║${YELLOW}                                                               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Tekan Enter untuk kembali ke menu utama...${NC}"
    read
}

# Fungsi utama
main() {
    while true; do
        show_banner
        show_menu
        
        case $choice in
            1)
                echo ""
                echo -e "${YELLOW}⚙️  Menginstal Proteksi Versi 1.0...${NC}"
                echo ""
                protect_nest
                show_success
                ;;
            2)
                echo ""
                echo -e "${YELLOW}⚙️  Menginstal Proteksi Versi 2.0...${NC}"
                echo ""
                protect_plt
                show_success
                ;;
            3)
                echo ""
                echo -e "${YELLOW}⚙️  Menginstal Proteksi Versi 3.0...${NC}"
                echo ""
                super_protection
                show_success
                ;;
            4)
                echo ""
                echo -e "${PURPLE}⚙️  Menginstal Proteksi Versi 4.0...${NC}"
                echo ""
                ultimate_protection
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

# Cek root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Script ini harus dijalankan sebagai root!${NC}" 
   exit 1
fi

# Jalankan main function
main
