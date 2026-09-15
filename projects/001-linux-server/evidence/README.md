# Project 001 — Evidence Index

The screenshots for Project 001 were curated to show meaningful engineering checkpoints rather than every terminal interaction.

Recommended evidence set:

| File | Evidence |
|---|---|
| `03-nginx-pagina-projeto.png` | Custom Project 001 page served by Nginx |
| `09-auth-log-tail-f.png` | Authentication events monitored with `tail -f` |
| `10-incidente-nginx-config-falha.png` | Controlled Nginx configuration failure |
| `14-incidente-nginx-recuperado.png` | Nginx recovered and running again |
| `15-vmware-nat.png` | VMware NAT network configuration |
| `16-processos-sinais-permissao.png` | Process ownership / signal permission exercise |
| `20-variavel-persistente-nova-sessao.png` | Environment variable persisted across SSH sessions |
| `21-scripts-permissao-negada-usuario-fora-dev.png` | Permission separation on the scripts directory |
| `28-healthcheck-final-portas-exit-code-0.png` | Final health check with ports 22/80 and exit code 0 |
| `29-cron-configurado-e-validado.png` | Cron entry installed and validated |
| `30-cron-execucao-automatica-healthcheck-log.png` | Automatic cron execution recorded in the log |
| `31-validacao-final-servidor.png` | Final server validation: `nginx -t`, health check and exit code 0 |

A final local package containing the curated screenshots was generated at project closure. Binary screenshots are kept separate from the text documentation so the public repository can remain intentionally curated.
