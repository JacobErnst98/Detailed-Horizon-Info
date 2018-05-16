<#
.SYNOPSIS
 Provides detailed Vdi informain about Horizon VMs
 This is the faster version of the script that does not show all data that the non speedy branch offers.
 But this script takes 20 minutes to run rather than 2 hours.
.DESCRIPTION
  Gets Computer, DNSname, User, Pool ,HVConnectionState, SamAccountName, Clamed, Entitled, Reason_Entitled, DesktoplastLogin, UserlastLogin NOTE: this verson does not provide {ProvisionedSpaceGB, UsedSpaceGB, PowerState, VMHost}
.INPUTS
  None
.OUTPUTS
  None
.NOTES

  INFO
    Version:        1.1b
    Author:         Jacob Ernst
    Modification Date:  5/16/2018
    Purpose/Change: Make speedy branch
    Modules:        Vmware* (PowerCLI), HV-Helper Get-Help User_Vm_Lookup.ps1 -online for this module link if it is not provided
    Required Files: CSV of horizon entitlments (See readme.md)

  TODO
   Generate Entitlments CSV inside script

.LINK
https://github.com/vmware/PowerCLI-Example-Scripts/tree/master/Modules/VMware.Hv.Helper

#>

############
# Both connections will prompt for user creds, please make sure you are an admin or read only admin in the roles section of Horizon and Vcenter
############

echo "Connecting to Vcenter enviorment"

Connect-VIServer "VcenterLinkedToHorizon.example.com"

echo "Connecting to Horizon enviorment"

Connect-HVServer "Viewserver.example.com"


$vms = Get-HVMachineSummary 


#Dump garbage data from the object
$vmsSimpl =@()
foreach ($vm in $vms){
    $ourObject = $vm | select-object -property `
    @{Label="Computer";Expression={$_.Base.Name}},
    @{Label="User";Expression={$_.namesdata.userName}},
    @{Label="BasicState";Expression={$_.Base.BasicState}},
    @{Label="dns";Expression={$_.Base.DnsName}},
    @{Label="Pool";Expression={$_.namesdata.desktopName}}
    $vmsSimpl += $ourObject

}


#DomainFQDN
$domain='example.com'

##############
# Search by ou here
##############
$OUtmp="DC=example,DC=com"

$OU = New-Object -TypeName psobject 
$OU | Add-Member -MemberType NoteProperty -Name distinguishedname -Value $OUtmp
######## YOU NEED TO GENERATE THIS FILE ###########
$entitlement = Import-Csv entitlement-pool.csv # See readme.md for instuctions on generating this file
$outputobj =@()
$people = @()
$i = 0
Write-Progress -Activity "Working..." `   -PercentComplete 0 -CurrentOperation   "0% complete" `   -Status "Please wait."
Foreach($PC in $vmsSimpl){
$tlo = New-Object -TypeName psobject 
        $tlo | Add-Member -MemberType NoteProperty -Name Computer -Value $pc.Computer
        $tlo | Add-Member -MemberType NoteProperty -Name DNSname -Value $pc.dns
        $tlo | Add-Member -MemberType NoteProperty -Name User -Value $PC.User
        $tlo | Add-Member -MemberType NoteProperty -Name Pool -Value $pc.pool
        $tlo | Add-Member -MemberType NoteProperty -Name HVConnectionState -Value $PC.BasicState
        $tlo | Add-Member -MemberType NoteProperty -Name SamAccountName -Value $(if($PC.User -eq $null ){ 
        
        "N/a" ; $InAd = "N/a"
        
        } if ($Pc.user -ne $null){
        
        $usernamearray = $pc.User.Split("{\}")
        $username = $usernamearray[1]
        $error.clear()
try { $samname = Get-ADUser $username | select SamAccountName ; $samname.SamAccountName; $InAd = "Yes"}
catch {echo ("User not in AD :" +  $username); $InAd = "No"}

         
        
        })
        $tlo | Add-Member -MemberType NoteProperty -Name InADBool -Value $InAd
        $tlo | Add-Member -MemberType NoteProperty -Name Clamed -Value $(if($PC.User -eq $null ){"No"} if ($Pc.user -ne $null){"Yes"})
        $tlo | Add-Member -MemberType NoteProperty -Name Entitled -Value  [string]$( if($InAd -eq "Yes" ){ 
        
        
        
        $sids = Get-ADPrincipalGroupMembership $tlo.SamAccountName
        
        foreach ($item in $sids) {

          foreach($line in $entitlement) {

             if($line.sid -eq $item.SID -or $line.sid -eq $person.SID ){

              if($Line.pool_id -eq $pc.Pool){
             echo "Yes"
            



                }
                
             }
             
         }
        }    
        
        
        
        } if ($InAd -ne "Yes"){"N/a"}) 
        
        $tlo.Entitled = $tlo.Entitled.TrimStart(" ", "[","s","t","r","i","n","g","]")
        $tlo | Add-Member -MemberType NoteProperty -Name Reason_Entitled -Value [string]$(if($InAd -eq "Yes" ){      
          foreach ($item in $sids) {

          foreach($line in $entitlement) {
      #    echo ($line.displayName)
             if($line.sid -eq $item.SID ){
             
              if($Line.pool_id -eq $pc.Pool){
             
              echo ($line.displayName)
              


                }
             }
         }
        } } if ($InAd -ne "Yes"){"N/a"})
        $tlo.Reason_Entitled = $tlo.Reason_Entitled.TrimStart(" ", "[","s","t","r","i","n","g","]")


         $tlo | Add-Member -MemberType NoteProperty -Name DesktoplastLogin -Value $(
        $lastLogin = Get-ADComputer -identity $pc.Computer -Properties * 
        $lastLogin.LastLogonDate)


        $tlo | Add-Member -MemberType NoteProperty -Name UserlastLogin -Value $(
        
        if($InAd -eq "Yes"){
        
        $lastLogin = Get-ADUser -identity $username -Properties * 
        $lastLogin.LastLogonDate

        }

        if($InAd -ne "Yes"){
        "N/a"
        
        }

        )
$outputobj += $tlo
$i++


$total= $vmsSimpl.Count
$a=($i/$total)*100
 $a=[math]::floor($a)

 Write-Progress -Activity "Working..." `   -PercentComplete $a -CurrentOperation   "$a% complete: VM#$i of $total // Time Remaining $((($total - $i)*5)/60) minutes  " `   -Status "Please wait."
}

$outputobj | Export-Csv "DetailedVdi.csv"
