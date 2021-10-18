# Setup Zabbix monitoring system

Zabbix with Nginx, Postgres and automation for Agent2: Ansible playbook for Linux nodes, and PowerShell script for Windows node.

## Requirements

**Software**: Linux VM or physical server, [Docker](https://docs.docker.com/engine/install/centos/) with [docker-compose](https://docs.docker.com/compose/install/).

**Configuration**: Static IP, hostname, DNS record, disabled/configured SELinux and Firewall to work with Docker and Zabbix.

## Deploy with Docker-Compose

This repo contains:

- Docker compose, env file with example credentials, bash script to restore DB from backup.

- Ansible playbook to install Zabbix agent 2 on Linux machines.

- PowerShell script for automatic install and config on Windows machine.

## Manual installation

### Zabbix agent 2 on Centos

```bash
rpm --import https://repo.zabbix.com/RPM-GPG-KEY-ZABBIX-A14FE591

# For Centos 7
yum install -y http://repo.zabbix.com/zabbix/5.4/rhel/7/x86_64/zabbix-release-5.4-1.el7.noarch.rpm
yum install -y zabbix-agent2

# For Centos 8
dnf install -y http://repo.zabbix.com/zabbix/5.4/rhel/8/x86_64/zabbix-release-5.4-1.el8.noarch.rpm
dnf install -y zabbix-agent2

cp -n /etc/zabbix/zabbix_agent2.conf{,.bak}
sed -i "s/^Server=.*/Server=zabbix.mydomain.loc/g" /etc/zabbix/zabbix_agent2.conf && grep Server= /etc/zabbix/zabbix_agent2.conf
sed -i "s/^ServerActive=.*/ServerActive=zabbix.mydomain.loc/g" /etc/zabbix/zabbix_agent2.conf && grep ServerActive= /etc/zabbix/zabbix_agent2.conf
# grep -y domain /etc/sysconfig/network-scripts/ifcfg-eth0 # if true, will return fqdn with: hostname -A | awk '{print $1}'
# sed -i "s/^Hostname=.*/Hostname=$(hostname -A | awk '{print $1}')/g" /etc/zabbix/zabbix_agent2.conf && grep Hostname= /etc/zabbix/zabbix_agent2.conf
sed -i "s/^Hostname=.*/Hostname=$(hostname).mydomain.loc/g" /etc/zabbix/zabbix_agent2.conf && grep Hostname= /etc/zabbix/zabbix_agent2.conf
grep -e "^\w.*" /etc/zabbix/zabbix_agent2.conf
```
### Zabbix agent 2 Windows

[Windows agent installation from MSI](https://www.zabbix.com/documentation/current/manual/installation/install_from_packages/win_msi)

### macOS

[Download](https://www.zabbix.com/download_agents) and install Zabbix agent as a regular pkg

```
sudo nano /usr/local/etc/zabbix/zabbix_agentd.conf
sudo launchctl unload /Library/LaunchDaemons/com.zabbix.zabbix_agentd.plist
sudo launchctl load /Library/LaunchDaemons/com.zabbix.zabbix_agentd.plist
```

## Zabbix basic configuration

### Auto hosts discovery

https://www.zabbix.com/documentation/current/manual/discovery/network_discovery/rule

Configuration → Discovery → Add/Edit rule

| Name | Value |
| --- | --- |
| IP range | 192.168.1.1-254 |
| Update interval | 30m or 1h |
| Checks | Zabbix agent "system.hostname"<br>Zabbix agent "system.uname" |
| Device uniqueness criteria | IP address |
| Host name | Zabbix agent "system.hostname" |
| Visible name | Zabbix agent "system.hostname" |
| Enabled | Check |

Configuration → Actions → Discovery actions

Auto discovery. Linux servers:

| Actions | Operations |
| --- | --- |
| Received value contains *Linux*<br>Discovery status equals *Up*<br>Service type equals *Zabbix agent* | Add host<br>Add to host groups: *Linux servers*<br>Link to templates: *Linux by Zabbix agent*<br>Set host inventory mode: *Automatic* |

Forget host after 1 week down:

| Name | Action |
| --- | --- |
| Uptime/Downtime is greater than or equals *604800*<br>Discovery status equals *Down*<br>Service type equals *Zabbix agent* | Remove host |

🛈 Default time for hosts to pass from "Monitoring → Discovery" to "Monitoring → Hosts" ~ 1h

### Do not track specific Windows services

Configuration → Templates → Windows services by Zabbix agent → Macros

Find section `{$SERVICE.NAME.NOT_MATCHES}` and add services that you don't want to track `BITS|edgeupdate|TrustedInstaller|WbioSrvc`

This settings can be overridden by host settings:

Configuration → *Hosts* → SomeHost → Triggers

## Links
- [Download Zabbix Agent](https://www.zabbix.com/download_agents)
- [Docker Hub - zabbix-agent2](https://hub.docker.com/r/zabbix/zabbix-agent2)
- [Manual Itemtypes of Zabbix agent](https://www.zabbix.com/documentation/current/manual/config/items/itemtypes/zabbix_agent)
- [Manual: Install windows msi (Zabbix Agent2)](https://www.zabbix.com/documentation/current/manual/installation/install_from_packages/win_msi)
- [Manual: Authentication (HTTP, LDAP, SAML)](https://www.zabbix.com/documentation/current/manual/web_interface/frontend_sections/administration/authentication)
- [LazyDocker](https://github.com/jesseduffield/lazydocker)
- Inspired by https://github.com/heyValdemar/zabbix-traefik-letsencrypt-docker-compose
