#!/bin/bash

##################################################
# Linux Compromise Assessment Collector
##################################################

DATE=$(date +"%Y%m%d_%H%M%S")
HOST=$(hostname)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTDIR="${SCRIPT_DIR}/CA_${HOST}_${DATE}"

mkdir -p "$OUTDIR"

exec > >(tee -a "$OUTDIR/collector.log") 2>&1

echo "[+] Starting collection"
echo "[+] Host : $HOST"
echo "[+] Time : $DATE"

##################################################
# SYSTEM
##################################################

mkdir -p "$OUTDIR/system"

hostnamectl > "$OUTDIR/system/hostnamectl.txt" 2>/dev/null
uname -a > "$OUTDIR/system/uname.txt"
uptime > "$OUTDIR/system/uptime.txt"
timedatectl > "$OUTDIR/system/time.txt" 2>/dev/null
cat /etc/os-release > "$OUTDIR/system/os-release.txt" 2>/dev/null

mount > "$OUTDIR/system/mount.txt"
df -h > "$OUTDIR/system/df.txt"
free -m > "$OUTDIR/system/memory.txt"

##################################################
# USERS
##################################################

mkdir -p "$OUTDIR/users"

cat /etc/passwd > "$OUTDIR/users/passwd.txt"
cat /etc/group > "$OUTDIR/users/group.txt"

last > "$OUTDIR/users/last.txt"
lastlog > "$OUTDIR/users/lastlog.txt"

who > "$OUTDIR/users/who.txt"
w > "$OUTDIR/users/w.txt"

awk -F: '$3 == 0 {print}' /etc/passwd \
> "$OUTDIR/users/root_equivalent_accounts.txt"

##################################################
# SUDO
##################################################

mkdir -p "$OUTDIR/sudo"

cp /etc/sudoers "$OUTDIR/sudo/" 2>/dev/null
cp -r /etc/sudoers.d "$OUTDIR/sudo/" 2>/dev/null

##################################################
# SSH
##################################################

mkdir -p "$OUTDIR/ssh"

cp /etc/ssh/sshd_config "$OUTDIR/ssh/" 2>/dev/null

find / -name authorized_keys \
> "$OUTDIR/ssh/authorized_keys.txt" 2>/dev/null

find / -name known_hosts \
> "$OUTDIR/ssh/known_hosts.txt" 2>/dev/null

##################################################
# PROCESS
##################################################

mkdir -p "$OUTDIR/process"

ps auxwwf > "$OUTDIR/process/process_tree.txt"

top -b -n 1 > "$OUTDIR/process/top.txt"

lsof -nP > "$OUTDIR/process/lsof.txt" 2>/dev/null

##################################################
# NETWORK
##################################################

mkdir -p "$OUTDIR/network"

ip addr > "$OUTDIR/network/ip_addr.txt"
ip route > "$OUTDIR/network/routes.txt"

ss -pantul > "$OUTDIR/network/ss_pantul.txt"
ss -lntup > "$OUTDIR/network/listening_ports.txt"

arp -an > "$OUTDIR/network/arp.txt" 2>/dev/null

##################################################
# ENVIRONMENT
##################################################

mkdir -p "$OUTDIR/environment"

env > "$OUTDIR/environment/env.txt"

##################################################
# BASH HISTORY
##################################################

mkdir -p "$OUTDIR/history"

find /root -name ".bash_history" \
> "$OUTDIR/history/root_history_locations.txt" 2>/dev/null

find /home -name ".bash_history" \
> "$OUTDIR/history/user_history_locations.txt" 2>/dev/null

##################################################
# SYSTEMD
##################################################

mkdir -p "$OUTDIR/systemd"

systemctl list-units --all \
> "$OUTDIR/systemd/list_units.txt"

systemctl list-unit-files \
> "$OUTDIR/systemd/list_unit_files.txt"

find /etc/systemd \
> "$OUTDIR/systemd/systemd_files.txt" 2>/dev/null

##################################################
# TIMERS
##################################################

systemctl list-timers --all \
> "$OUTDIR/systemd/timers.txt"

##################################################
# CRON
##################################################

mkdir -p "$OUTDIR/cron"

cp -r /etc/cron* "$OUTDIR/cron/" 2>/dev/null

for USER in $(cut -d: -f1 /etc/passwd)
do
    crontab -u $USER -l \
    > "$OUTDIR/cron/${USER}.cron" 2>/dev/null
done

##################################################
# APACHE
##################################################

if command -v apache2 >/dev/null || command -v httpd >/dev/null
then

mkdir -p "$OUTDIR/apache"

cp -r /etc/apache2 "$OUTDIR/apache/" 2>/dev/null
cp -r /etc/httpd "$OUTDIR/apache/" 2>/dev/null

cp -r /var/log/apache2 "$OUTDIR/apache/" 2>/dev/null
cp -r /var/log/httpd "$OUTDIR/apache/" 2>/dev/null

fi

##################################################
# NGINX
##################################################

if command -v nginx >/dev/null
then

mkdir -p "$OUTDIR/nginx"

cp -r /etc/nginx "$OUTDIR/nginx/" 2>/dev/null
cp -r /var/log/nginx "$OUTDIR/nginx/" 2>/dev/null

fi

##################################################
# WEB ROOTS
##################################################

mkdir -p "$OUTDIR/web"

find /var/www -type f \
> "$OUTDIR/web/var_www_files.txt" 2>/dev/null

find /var/www -type f -mtime -30 \
> "$OUTDIR/web/recent_web_files.txt" 2>/dev/null

find /var/www \
-type f \
\( -name "*.php" -o -name "*.jsp" -o -name "*.aspx" -o -name "*.jspx" \) \
> "$OUTDIR/web/dynamic_files.txt" 2>/dev/null

##################################################
# DOCKER
##################################################

if command -v docker >/dev/null
then

mkdir -p "$OUTDIR/docker"

docker version \
> "$OUTDIR/docker/version.txt"

docker ps -a \
> "$OUTDIR/docker/containers.txt"

docker images \
> "$OUTDIR/docker/images.txt"

docker network ls \
> "$OUTDIR/docker/networks.txt"

docker volume ls \
> "$OUTDIR/docker/volumes.txt"

docker inspect $(docker ps -aq) \
> "$OUTDIR/docker/inspect.json" 2>/dev/null

fi

##################################################
# PODMAN
##################################################

if command -v podman >/dev/null
then

mkdir -p "$OUTDIR/podman"

podman ps -a \
> "$OUTDIR/podman/containers.txt"

podman images \
> "$OUTDIR/podman/images.txt"

fi

##################################################
# KUBERNETES
##################################################

if command -v kubectl >/dev/null
then

mkdir -p "$OUTDIR/kubernetes"

kubectl get pods -A \
> "$OUTDIR/kubernetes/pods.txt" 2>/dev/null

kubectl get svc -A \
> "$OUTDIR/kubernetes/services.txt" 2>/dev/null

kubectl get deploy -A \
> "$OUTDIR/kubernetes/deployments.txt" 2>/dev/null

fi

##################################################
# DATABASES
##################################################

mkdir -p "$OUTDIR/databases"

systemctl status mysql \
> "$OUTDIR/databases/mysql_status.txt" 2>/dev/null

systemctl status mariadb \
> "$OUTDIR/databases/mariadb_status.txt" 2>/dev/null

systemctl status postgresql \
> "$OUTDIR/databases/postgresql_status.txt" 2>/dev/null

systemctl status redis \
> "$OUTDIR/databases/redis_status.txt" 2>/dev/null

##################################################
# LOGS
##################################################

mkdir -p "$OUTDIR/logs"

cp /var/log/auth.log* "$OUTDIR/logs/" 2>/dev/null
cp /var/log/secure* "$OUTDIR/logs/" 2>/dev/null

cp /var/log/syslog* "$OUTDIR/logs/" 2>/dev/null
cp /var/log/messages* "$OUTDIR/logs/" 2>/dev/null

journalctl -n 10000 \
> "$OUTDIR/logs/journal_recent.txt"

##################################################
# RECENT FILES
##################################################

mkdir -p "$OUTDIR/recent"

find /etc -type f -mtime -30 \
> "$OUTDIR/recent/etc_modified.txt"

find /usr/bin -type f -mtime -30 \
> "$OUTDIR/recent/usrbin_modified.txt"

find /usr/sbin -type f -mtime -30 \
> "$OUTDIR/recent/usrsbin_modified.txt"

##################################################
# TEMP EXECUTABLES
##################################################

mkdir -p "$OUTDIR/temp"

find /tmp -type f -executable \
> "$OUTDIR/temp/tmp_exec.txt" 2>/dev/null

find /var/tmp -type f -executable \
> "$OUTDIR/temp/vartmp_exec.txt" 2>/dev/null

find /dev/shm -type f -executable \
> "$OUTDIR/temp/devshm_exec.txt" 2>/dev/null

##################################################
# PERSISTENCE
##################################################

mkdir -p "$OUTDIR/persistence"

find /etc/profile.d \
> "$OUTDIR/persistence/profile_d.txt" 2>/dev/null

find /etc/init.d \
> "$OUTDIR/persistence/initd.txt" 2>/dev/null

ls -la /etc/rc.local \
> "$OUTDIR/persistence/rc_local.txt" 2>/dev/null

ls -la /etc/ld.so.preload \
> "$OUTDIR/persistence/ldso_preload.txt" 2>/dev/null

##################################################
# PRIVILEGE ESCALATION
##################################################

mkdir -p "$OUTDIR/privilege"

find / -perm -4000 -type f \
> "$OUTDIR/privilege/suid.txt" 2>/dev/null

find / -perm -2000 -type f \
> "$OUTDIR/privilege/sgid.txt" 2>/dev/null

find / -xdev -type f -perm -0002 \
> "$OUTDIR/privilege/world_writable.txt" 2>/dev/null

##################################################
# KERNEL
##################################################

mkdir -p "$OUTDIR/kernel"

lsmod > "$OUTDIR/kernel/lsmod.txt"

##################################################
# PACKAGES
##################################################

mkdir -p "$OUTDIR/packages"

if command -v dpkg >/dev/null
then
    dpkg -l > "$OUTDIR/packages/packages.txt"
fi

if command -v rpm >/dev/null
then
    rpm -qa > "$OUTDIR/packages/packages.txt"
fi

##################################################
# HASHES
##################################################

mkdir -p "$OUTDIR/hash"

sha256sum /etc/passwd \
> "$OUTDIR/hash/passwd.sha256" 2>/dev/null

sha256sum /etc/shadow \
> "$OUTDIR/hash/shadow.sha256" 2>/dev/null

sha256sum /etc/sudoers \
> "$OUTDIR/hash/sudoers.sha256" 2>/dev/null

##################################################
# ARCHIVE
##################################################

tar czf "${OUTDIR}.tar.gz" "$(basename "$OUTDIR")"

sha256sum "${OUTDIR}.tar.gz" \
> "${OUTDIR}.tar.gz.sha256"

echo ""
echo "[+] Collection Completed"
echo "[+] Evidence Folder : $OUTDIR"
echo "[+] Archive         : ${OUTDIR}.tar.gz"
echo "[+] SHA256          : ${OUTDIR}.tar.gz.sha256"
