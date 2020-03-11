
set -x

sudo pacman -S --needed autoconf
sudo pacman -S --needed base-devel
sudo pacman -S --needed bison
sudo pacman -S --needed xl2tpd
sudo pacman -S --needed unbound
sudo pacman -S --needed xmlto
sudo pacman -S --needed libnma
sudo pacman -S --needed intltool
sudo pacman -S --needed strongswan
# aur
function build_install_aur () {
	local target="$1"
	local downloadDir="/tmp/${target}"
	git clone https://aur.archlinux.org/${target}.git ${downloadDir}
	cd ${downloadDir}
	makepkg
	sudo pacman -U ${target}*.xz
}
build_install_aur networkmanager-l2tp
