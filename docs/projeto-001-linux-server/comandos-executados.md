# Projeto 001 — Comandos executados e validados

> Registro incremental. Credenciais utilizadas no laboratório não são armazenadas neste arquivo.

## Sistema e identidade
```bash
hostnamectl
hostname
cat /etc/os-release
uname -a
lsb_release -a
sudo hostnamectl set-hostname cloudjourney-web01
cat /etc/hosts
sudo nano /etc/hosts
```

## Pacotes
```bash
sudo apt update
sudo apt upgrade
sudo reboot
sudo apt install curl
sudo apt install git unzip
curl --version
git --version
unzip -v
```

## Nginx e serviço web
```bash
apt install nginx
nginx -v
systemctl status nginx
ls -la /var/www/html
cat /var/www/html/index.nginx-debian.html
sudo nano /var/www/html/index.nginx-debian.html
```

## Processos, portas e rede
```bash
ps aux | grep '[n]ginx'
pgrep -a nginx
ss -ltnp
resolvectl
ip a
ip r
```

## SSH
```bash
cat /etc/ssh/ssh_config
cat /etc/ssh/sshd_config
sshd -T | grep -E 'permitrootlogin|passwordauthentication|^port'
```

## Usuários e grupos
```bash
groups
id thassioiaccino
groups thassioiaccino
groupadd cloudjourney-dev
groupadd cloudjourney-ops
cat /etc/group
chage -d 0 beto
chage -l beto
usermod -G cloudjourney-ops beto
usermod -aG cloudjourney-ops <usuario>
```

## Estrutura e permissões
```bash
mkdir -p /opt/cloudjourney/app
mkdir -p /var/log/cloudjourney
chown -R root:cloudjourney-dev /opt/cloudjourney/app
chown -R root:cloudjourney-ops /var/log/cloudjourney
chmod 775 /opt/cloudjourney/app
chmod 750 /var/log/cloudjourney
ls -ld /opt/cloudjourney/app
ls -ld /var/log/cloudjourney
```

## Data, hora e logs
```bash
timedatectl
timedatectl set-timezone America/Sao_Paulo
systemctl restart nginx
systemctl restart rsyslog
systemctl status rsyslog
cat /var/log/nginx/access.log
cat /var/log/nginx/error.log
tail /var/log/auth.log
tail /var/log/syslog
tail -f /var/log/auth.log
```

## Incidente controlado — Nginx
```bash
ls /etc/nginx/sites-enabled/
ls -l /etc/nginx/sites-enabled/
cp /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default.bkp
nano /etc/nginx/sites-available/default
nginx -t
systemctl status nginx
systemctl restart nginx
systemctl status nginx.service
journalctl -xeu nginx.service
ls -l /etc/nginx/sites-enabled/
ls -l /etc/nginx/sites-available
rm /etc/nginx/sites-enabled/default.bkp
nginx -t
systemctl start nginx
systemctl status nginx
```

### Resultado
- erro de sintaxe detectado com `nginx -t`;
- restart falhou e o serviço entrou em `failed`;
- investigação feita com `systemctl status` e `journalctl`;
- um segundo problema foi identificado: backup dentro de `sites-enabled` causava duplicidade de `default_server`;
- configuração corrigida e validada com `nginx -t`;
- Nginx voltou para `active (running)`;
- página do projeto voltou a responder em HTTP.
