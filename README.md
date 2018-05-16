# Detailed-Horizon-Info
Gets detailed information about ever VM in horizon

This script is tested on Horizon 6, This should would on Horizon 7 but it is not tested.

# How long will this script take to gather data
The master branch provides
- Computer (The name of the vm)
- DNSname 
- User (User asigned to the vm)
- Pool
- HVConnectionState
- ProvisionedSpaceGB
- UsedSpaceGB
- PowerState
- VMHost (ESX/ESXi host)
- SamAccountName
- Clamed
- Entitled
- Reason_Entitled 
- DesktoplastLogin (From the strange microsoft docs on this I think it is the last time the computer checked in with AD)
- UserlastLogin

While the speedy branch only provides 
- Computer (The name of the vm)
- DNSname 
- User (User asigned to the vm)
- Pool
- HVConnectionState
- SamAccountName
- Clamed
- Entitled
- Reason_Entitled 
- DesktoplastLogin (From the strange microsoft docs on this I think it is the last time the computer checked in with AD)
- UserlastLogin


Running the master branch takes about 5 seconds per vm

```Ex: 2000 vms at 5 seconds per vm =~ 166 minutes or about 3 hours ```

The speedy branch however takes less than a second per vm

```Ex: 2000 vms at .8 seconds per vm =~ 26 minutes ```

# Files Youll need
entitlement-pool.csv
- From the view server run View Powercli <C:\Windows\system32\windowspowershell\v1.0\powershell.exe -noe -c ". \"C:\Program Files\VMware\VMware View\Server\extras\PowerShell\add-snapin.ps1\"">
 - Run the command "Get-pool |get-poolentitlement | export-csv "entitlement-pool.csv"
 - Copy the file to script directory
