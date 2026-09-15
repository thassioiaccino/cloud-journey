# Project 001 — Command Runbook

This file records the main commands actually used and tested during Project 001, organized by technical flow instead of as a raw terminal dump.

> Security note: literal passwords used during the lab are intentionally omitted. The placeholder `<INITIAL_PASSWORD>` is used where needed.

---

## 1. Host discovery and identity

### Inspect the environment

```bash
hostnamectl
hostname
cat /etc/os-release
uname -a
lsb_release -a
```

### Change and validate the hostname

```bash
sudo hostnamectl set-hostname cloudjourney-web01
hostnamectl
hostname
cat /etc/hosts
sudo nano /etc/hosts
cat /etc/hosts
```

---

## 2. Package management

### Update the operating system

```bash
sudo apt update
sudo apt upgrade
sudo reboot
```

### Install and validate basic tools

```bash
sudo apt install curl
sudo apt install git unzip
curl --version
git --version
unzip --version
unzip -v
```

---

## 3. Nginx web service

### Install and inspect Nginx

```bash
sudo apt install nginx
nginx -v
systemctl status nginx
ps aux | grep '[n]ginx'
pgrep -a nginx
```

### Inspect and edit the default page

```bash
cd /var/www/html
ls -la
cat index.nginx-debian.html
sudo nano /var/www/html/index.nginx-debian.html
```

### Validate the configuration

```bash
sudo nginx -t
```

---

## 4. Network and listening ports

### Inspect interfaces, routes and DNS

```bash
ip a
ip r
resolvectl
```

### Inspect listening sockets

```bash
ss -ltnp
ss -ltn | grep -E ':22|:80'
```

The lab validated TCP/22 for SSH and TCP/80 for HTTP/Nginx.

---

## 5. SSH administration

### Inspect SSH configuration

```bash
cd /etc/ssh
cat ssh_config
cat sshd_config
sshd -T | grep -E 'permitrootlogin|passwordauthentication|^port'
```

Observed effective configuration during the project:

```text
port 22
permitrootlogin prohibit-password
passwordauthentication yes
```

---

## 6. Users and groups

### Inspect current identity and memberships

```bash
groups
id thassioiaccino
groups thassioiaccino
```

### Create functional groups

```bash
sudo groupadd cloudjourney-dev
sudo groupadd cloudjourney-ops
cat /etc/group
```

### User creation pattern used in the lab

```bash
sudo useradd -m -s /bin/bash -G cloudjourney-dev -p "$(openssl passwd -6 '<INITIAL_PASSWORD>')" eduardo
sudo chage -d 0 eduardo
```

The same pattern was used for the other lab users, assigning each account to the appropriate DEV or OPS group.

### Password-expiration practice

```bash
sudo chage -d 0 beto
sudo chage -l beto
```

### Group membership changes

```bash
sudo usermod -G cloudjourney-ops beto
sudo usermod -aG cloudjourney-ops <user>
```

`-G` replaces supplementary group membership, while `-aG` appends a new supplementary group without removing the existing ones.

---

## 7. Application and log directory structure

### Create the project directories

```bash
sudo mkdir -p /opt/cloudjourney/app
sudo mkdir -p /var/log/cloudjourney
```

### Set ownership and groups

```bash
sudo chown -R root:cloudjourney-dev /opt/cloudjourney/app
sudo chown -R root:cloudjourney-ops /var/log/cloudjourney
```

### Apply permissions

```bash
sudo chmod 775 /opt/cloudjourney/app
sudo chmod 750 /var/log/cloudjourney
```

### Validate ownership and modes

```bash
ls -ld /opt/cloudjourney/app
ls -ld /var/log/cloudjourney
```

---

## 8. Practical permission tests

### DEV test

```bash
cd /opt/cloudjourney/app
mkdir teste
cd /var/log/cloudjourney
```

Expected result in the log directory for a DEV-only user:

```text
Permission denied
```

### OPS test

```bash
cd /opt/cloudjourney/app
mkdir teste2
cd /var/log/cloudjourney
```

The OPS account was blocked from writing to the DEV application directory and allowed to access the OPS log directory.

### Administrative elevation test

```bash
mkdir teste2
sudo mkdir teste2
```

This demonstrated the difference between normal user permissions and explicit privilege elevation.

---

## 9. Date, timezone and NTP

```bash
timedatectl
sudo timedatectl set-timezone America/Sao_Paulo
timedatectl
```

Services were then restarted/validated during the exercise:

```bash
sudo systemctl restart nginx
sudo systemctl restart rsyslog
systemctl status rsyslog
```

---

## 10. System and application logs

```bash
cat /var/log/nginx/access.log
cat /var/log/nginx/error.log
tail /var/log/auth.log
tail /var/log/syslog
tail -f /var/log/auth.log
```

`tail -f` was used to observe SSH authentication events in real time.

---

## 11. Controlled Nginx incident and troubleshooting

### Inspect the active site

```bash
ls -l /etc/nginx/sites-enabled/
ls -l /etc/nginx/sites-available/
```

### Edit the active configuration

```bash
sudo nano /etc/nginx/sites-available/default
sudo nginx -t
```

A syntax error was introduced intentionally. The service restart then failed.

### Investigate the failure

```bash
sudo systemctl restart nginx
systemctl status nginx.service
journalctl -xeu nginx.service
```

### Correct the configuration and validate again

```bash
sudo nano /etc/nginx/sites-available/default
sudo nginx -t
```

A second problem was then found: a backup file had been left inside `sites-enabled`, so Nginx loaded it as active configuration and reported a duplicate default server.

### Remove the conflicting backup and recover the service

```bash
sudo rm /etc/nginx/sites-enabled/default.bkp
sudo nginx -t
sudo systemctl start nginx
systemctl status nginx
```

Main lesson: validate configuration before restart/reload and do not keep backup configuration files inside `sites-enabled`.

---

## 12. Processes and signals

### Create test processes

```bash
sleep 300
sleep 600
```

### Locate them

```bash
pgrep -a sleep
```

### Termination test

```bash
kill <PID>
sudo kill <PID>
pgrep -a sleep
```

The lab demonstrated that `kill PID` sends SIGTERM by default and that privileges matter when signaling a process owned by another user.

SIGKILL (`kill -9`) was discussed as a last resort rather than the default approach.

---

## 13. Environment variables

### Inspect the environment

```bash
env
echo $PATH
echo $HOME
```

### Create and export a project variable

```bash
PROJETO=cloudjourney
echo $PROJETO
export PROJETO
env
```

### Persist the variable

```bash
nano /home/thassioiaccino/.bashrc
```

Entry added:

```bash
export PROJETO=cloudjourney
```

Reload and validate:

```bash
source /home/thassioiaccino/.bashrc
echo $PROJETO
```

The variable was also confirmed in a new SSH session.

---

## 14. Script directory and permissions

### Create the script directory

```bash
sudo mkdir -p /opt/cloudjourney/scripts
sudo chown root:cloudjourney-dev /opt/cloudjourney/scripts
sudo chmod 775 /opt/cloudjourney/scripts
ls -ld /opt/cloudjourney/scripts
```

A user outside `cloudjourney-dev` was unable to create the script, while the DEV user `eduardo` could edit it successfully.

---

## 15. Bash health check

### Create and inspect the script

```bash
nano /opt/cloudjourney/scripts/healthcheck.sh
cat /opt/cloudjourney/scripts/healthcheck.sh
```

### Make it executable

```bash
chmod +x /opt/cloudjourney/scripts/healthcheck.sh
ls -l /opt/cloudjourney/scripts/healthcheck.sh
```

### Execute and validate the exit code

```bash
/opt/cloudjourney/scripts/healthcheck.sh
echo $?
```

Final healthy output included:

```text
Nginx: OK
Porta 22: OK
Porta 80: OK
```

with:

```text
0
```

The final script is available at [`scripts/healthcheck.sh`](scripts/healthcheck.sh).

---

## 16. Cron automation

### Edit the DEV user's crontab

```bash
crontab -e
```

Entry used in the lab:

```cron
*/5 * * * * /opt/cloudjourney/scripts/healthcheck.sh >> /opt/cloudjourney/scripts/healthcheck.log 2>&1
```

### Validate the schedule

```bash
crontab -l
```

### Validate automatic execution

```bash
cat /opt/cloudjourney/scripts/healthcheck.log
```

The health check executed automatically and recorded Nginx and ports 22/80 as healthy.

---

## 17. Final server validation

The final validation flow was:

```bash
hostnamectl
systemctl is-active ssh
systemctl is-active nginx
systemctl is-active cron
sudo nginx -t
ss -ltn | grep -E ':22|:80'
/opt/cloudjourney/scripts/healthcheck.sh
echo $?
```

Final result:

```text
SSH: active
Nginx: active
cron: active
Nginx configuration: test successful
Port 22: LISTEN
Port 80: LISTEN
Health check exit code: 0
```

---

## 18. Learning attempts worth keeping

The project also included exploratory commands and mistakes that were useful to the learning process, such as:

```bash
cat /etc/host
nano /etc/host
rmdir -f cloudjourney/
ss nginx
ss -o nginx
```

These did not become part of the final operational flow, but keeping them in the project history is useful because the lab was intentionally built around investigation rather than only a polished happy path.

---

## Summary flow

```text
Discover host
    ↓
Update system
    ↓
Install Nginx
    ↓
Validate network + SSH
    ↓
Create users/groups
    ↓
Design ownership + permissions
    ↓
Inspect logs
    ↓
Break Nginx intentionally
    ↓
Troubleshoot and recover
    ↓
Practice processes/signals
    ↓
Persist environment variables
    ↓
Build Bash health check
    ↓
Automate with cron
    ↓
Run final validation
```
