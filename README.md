# Detailed-Horizon-Info
Gets detailed information about ever VM in horizon

This script is tested on Horizon 6, This should would on Horizon 7 but it is not tested.


# Files Youll need
Pool-Entitlements.CSV
- Powercli FROM the view server NOTE: this command is not in Powercli anymore on the windows client avalible from VmWares site you MUST use PowerCLI on the Connection server
    - Get-PoolEntitlement | export-csv
