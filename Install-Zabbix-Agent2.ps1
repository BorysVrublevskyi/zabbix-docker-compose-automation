# Run as admin
$ZA2_URI="https://cdn.zabbix.com/zabbix/binaries/stable/5.4/5.4.5/zabbix_agent2-5.4.5-windows-amd64-openssl.msi"
Set-Location -Path $env:TEMP
Invoke-WebRequest -Uri $ZA2_URI -OutFile ZA2.msi

# msiexec /l*v zabbix-agent2-install.log /i ZA2.msi /qn `
#     HOSTNAME="$([System.Net.Dns]::GetHostByName((hostname)).HostName)" `
#     SERVER="zabbix.mydomain.loc" `
#     SERVERACTIVE="zabbix.mydomain.loc"

$MSIArguments = @(
    "/i"
    "ZA2.msi"
    "/qn"
    "/norestart"
    "HOSTNAME=$([System.Net.Dns]::GetHostByName((hostname)).HostName)"
    "SERVER=zabbix.mydomain.loc"
    "SERVERACTIVE=zabbix.mydomain.loc"
    "/l*v"
    "zabbix-agent2-install.log"
)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
Start-Sleep -s 7
Restart-Service -Name "Zabbix Agent 2"
Remove-Item $env:TEMP\ZA2.msi


# Examples
# [System.Net.Dns]::GetHostByName((hostname)).HostName.ToLower() # FQDN in lower case
# Start-Process msiexec.exe -ArgumentList "/uninstall {4B143441-5796-4EA9-827A-79EAE800CBF9}" -wait
# Start-Process msiexec.exe -ArgumentList @("/uninstall {4B143441-5796-4EA9-827A-79EAE800CBF9}", "/norestart")
