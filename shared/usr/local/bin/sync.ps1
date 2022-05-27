param (
        [string]$vm = $(throw "-vm is required"),
        [string]$snap = $(throw "-snap is required")
)

#suppress all error messages
$ErrorActionPreference = "SilentlyContinue"

#opt out powercli CIEP
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false | Out-Null


Write-Output "----------------------------------------------------"
Write-Output "  Starting Snapshot Reversion - ${snap}"
Write-Output "  ${vm}"
Write-Output "----------------------------------------------------"

#source config file
. "/usr/local/etc/sync/sync.cfg.ps1"
/usr/bin/logger -n 10.14.10.5 ${vm}-server`:  import settings
Write-Output "importing settings"

#load vmware modules
Get-Module -ListAvailable VM* | Import-Module | Out-Null
/usr/bin/logger -n 10.14.10.5 ${vm}-server`:  import modules
Write-Output "importing modules"

#connect to viserver
Disconnect-VIServer -Server * -Force -Confirm:$false | Out-Null
/usr/bin/logger -n 10.14.10.5 ${vm}-server`:  disconnect existing viservers
Write-Output "disconnecting viservers"

Connect-VIServer $vcenter -UserName $user -Password $pass | Out-Null
/usr/bin/logger -n 10.14.10.5 ${vm}-server`:  connect to viserver - ${vcenter}
Write-Output "connecting to viserver - ${vcenter}"

#display vm snapshots
#Get-Snapshot -VM ${vm}

#revert vm to snapshot
Set-VM -VM ${vm} -SnapShot $snap -Confirm:$false > $null
/usr/bin/logger -n 10.14.10.5 ${vm}-server`:  reverting snapshot to - ${snap}
Write-Output "reverting to snapshot"

#wait
#Start-Sleep -Seconds 2

#start vm
Start-VM -VM ${vm} > $null
/usr/bin/logger -n 10.14.10.5 ${vm}-server`:  starting vm - ${vm}
Write-Output "starting vm"

#cleanup
Disconnect-VIServer -Server * -Force -Confirm:$false
/usr/bin/logger -n 10.14.10.5 ${vm}-server`:  disconnect existing viservers
Write-Output "disconnecting viservers"
