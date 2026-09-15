# Project 001 — Linux Server: Provisioning & Administration

> **Status: ✅ Completed**

## 🎯 Objective

Build and administer a Linux server from an empty virtual machine until it reaches an operational, testable and documented state suitable as a foundation for future Cloud/DevOps workloads.

This project was intentionally hands-on: the server was built, configured, broken in a controlled way, investigated, recovered and finally validated.

---

## 🏗️ Environment

- **OS:** Ubuntu Server 26.04 LTS — Resolute Raccoon
- **Virtualization:** VMware
- **Architecture:** x86_64
- **CPU:** 2 vCPUs
- **RAM:** ~4 GB
- **Disk:** 10 GB, root filesystem managed by LVM
- **Hostname:** `cloudjourney-web01`
- **Network mode:** NAT
- **Logical interface:** `bond0`
- **Physical interface:** `ens33`
- **Lab IPv4:** `192.168.254.132/24`
- **Gateway / DNS:** `192.168.254.2`

The VM uses NAT because the scenario is a local lab and the server does not need to participate directly in the physical LAN. Administration is performed through SSH/PuTTY from the host.

---

## 🔧 What was implemented

### Host identity and package management

The hostname was changed to `cloudjourney-web01`, `/etc/hosts` was adjusted, the operating system was updated with APT and basic tools such as `curl`, `git` and `unzip` were installed and validated.

### Nginx web service

Nginx was installed, enabled and used to publish a custom Project 001 page. Processes, service status and TCP/80 were inspected during validation.

### SSH administration

Remote administration was performed through SSH using a named administrative account and privilege elevation with `sudo` when needed.

Observed effective configuration:

```text
port 22
permitrootlogin prohibit-password
passwordauthentication yes
```

Direct root password login was therefore not used as the normal administration path.

### Users, groups and privilege separation

Two functional groups were created:

```text
cloudjourney-dev
cloudjourney-ops
```

The project used group-based authorization instead of assigning permissions user by user.

| Path | Owner | Group | Mode | Purpose |
|---|---|---|---:|---|
| `/opt/cloudjourney/app` | `root` | `cloudjourney-dev` | `775` | DEV can create and modify application content |
| `/var/log/cloudjourney` | `root` | `cloudjourney-ops` | `750` | OPS can access operational logs |
| `/opt/cloudjourney/scripts` | `root` | `cloudjourney-dev` | `775` | DEV can maintain operational scripts |

Practical tests confirmed that users outside the intended group could not write where they were not authorized.

### Logs and troubleshooting

The following logs were inspected:

- `/var/log/nginx/access.log`
- `/var/log/nginx/error.log`
- `/var/log/syslog`
- `/var/log/auth.log`

`tail -f` was used to observe authentication events in real time.

### Processes and signals

Test processes were created with `sleep`, located with `pgrep` and terminated using `kill`. The difference between normal termination with `SIGTERM` and forced termination with `SIGKILL` was practiced.

### Environment variables

A project variable was created, exported and then persisted in the administrative user's `.bashrc`:

```bash
export PROJETO=cloudjourney
```

Persistence was confirmed in a new SSH session.

---

## 📘 Command runbook

The complete command trail for the project is published separately as a flow-oriented runbook instead of a raw terminal dump.

It includes host discovery, package management, Nginx, networking, SSH, users/groups, permissions, logs, troubleshooting, processes, environment variables, Bash, cron and final validation.

See [`COMMANDS.md`](COMMANDS.md).

---

## 🤖 Bash health check

A simple operational health-check script was created at:

```text
/opt/cloudjourney/scripts/healthcheck.sh
```

It validates:

- hostname;
- date/time;
- memory usage;
- root filesystem usage;
- Nginx service state;
- TCP/22 listening state;
- TCP/80 listening state.

The script uses an exit status so that other tools can consume its result:

```text
0 = healthy execution
1 = monitored failure detected
```

The final execution returned:

```text
Nginx: OK
Porta 22: OK
Porta 80: OK
exit code: 0
```

The cleaned script is available at [`scripts/healthcheck.sh`](scripts/healthcheck.sh).

---

## ⏱️ Scheduled automation with cron

The health check was scheduled in the `eduardo` user's crontab during the lab:

```cron
*/5 * * * * /opt/cloudjourney/scripts/healthcheck.sh >> /opt/cloudjourney/scripts/healthcheck.log 2>&1
```

The five-minute frequency was chosen to make the laboratory validation easy to observe. The configuration was confirmed with `crontab -l`, and an automatic execution was later verified through `healthcheck.log`.

For a production system, frequency, log destination, retention and rotation would be reviewed before adoption.

---

## 💥 Controlled incident — Nginx

A controlled configuration failure was introduced to practice troubleshooting instead of only following the happy path.

The first problem was an invalid Nginx configuration. The workflow used:

```text
nginx -t
systemctl status nginx.service
journalctl -xeu nginx.service
```

A second issue was then discovered: a backup file had been placed inside `sites-enabled`, causing it to be loaded as an active configuration and generating a duplicate default server conflict.

The recovery consisted of correcting the configuration, removing the conflicting backup from the active configuration directory and validating Nginx before starting it again.

Main operational lesson: validate Nginx configuration before reload/restart and do not store backup configuration files inside `sites-enabled`.

---

## ✅ Final validation

At project closure, the following were checked again:

- hostname and operating system identity;
- SSH service active;
- Nginx service active;
- cron service active;
- TCP/22 and TCP/80 listening;
- Nginx configuration valid with privileged `nginx -t`;
- health check returning all monitored items as OK;
- script exit code equal to `0`.

This final validation closed the technical scope of Project 001.

---

## 📷 Evidence

A curated evidence set was produced during the project, covering NAT networking, permission tests, logs, the controlled Nginx incident, process signals, persistent environment variables, the health check, cron and the final server validation.

The evidence index is available at [`evidence/README.md`](evidence/README.md). The screenshots are intentionally curated rather than publishing every terminal interaction.

---

## 💡 Main learnings

This project reinforced that Linux administration is not only about knowing commands. The most valuable parts were understanding:

- why ownership, groups and permissions should be designed before granting access;
- why service state and listening ports answer different operational questions;
- why configuration validation should happen before restarting a service;
- why logs and `journalctl` are central to troubleshooting;
- why scripts should communicate success/failure through exit codes;
- why least privilege matters even in automation;
- why a controlled failure often teaches more than a clean installation.

---

## 🚀 Next steps

Project 001 provides the Linux foundation for the next stages of the Cloud Journey. Natural evolutions include:

- Docker and containerized workloads;
- stronger SSH authentication and hardening;
- firewall rules;
- dedicated monitoring and log rotation;
- Infrastructure as Code;
- CI/CD automation;
- deployment to a public cloud environment.

---

## 🔒 Security note

No literal passwords used in the laboratory are included in this repository. Screenshots and documentation were curated to avoid publishing credentials or authentication secrets.
