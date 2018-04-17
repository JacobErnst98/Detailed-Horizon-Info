# Detailed-Horizon-Info
Gets detailed information about ever VM in horizon

This script is tested on Horizon 6, This should would on Horizon 7 but it is not tested.


# Files Youll need
entitlement-pool.csv
- From the view server run View Powercli <C:\Windows\system32\windowspowershell\v1.0\powershell.exe -noe -c ". \"C:\Program Files\VMware\VMware View\Server\extras\PowerShell\add-snapin.ps1\"">
 - Run the command "Get-pool |get-poolentitlement | export-csv "entitlement-pool.csv"
 - Copy the file to script directory
