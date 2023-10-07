mkdir -p /etc/portage/repos.conf
nano /etc/portage/repos.conf/local.conf
->
[local]
# 'eselect repository' default location
location = /var/db/repos/local

mkdir -p /var/db/repos/local/profiles
nano /var/db/repos/local/profiles/repo_name
->
local

mkdir -p /var/db/repos/local/metadata
nano /var/db/repos/local/metadata/layout.conf
->
# Slave repository rather than stand-alone
masters = gentoo
profile-formats = portage-2

->>

cd /var/db/repos/local/profiles
mkdir systemd-llvm-plasma && echo 8 >systemd-llvm-plasma/eapi

nano /var/db/repos/local/profiles/systemd-llvm-plasma/parent
->
gentoo:default/linux/arm64/17.0/systemd/llvm/merged-usr
gentoo:targets/desktop/plasma

echo `portageq envvar ARCH` systemd-llvm-plasma dev >> /var/db/repos/local/profiles/profiles.desc