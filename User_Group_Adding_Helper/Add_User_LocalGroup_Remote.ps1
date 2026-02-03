Write-Host 
"
██╗   ██╗███████╗███████╗██████╗      ██████╗ ██████╗  ██████╗ ██╗   ██╗██████╗                   
██║   ██║██╔════╝██╔════╝██╔══██╗    ██╔════╝ ██╔══██╗██╔═══██╗██║   ██║██╔══██╗                  
██║   ██║███████╗█████╗  ██████╔╝    ██║  ███╗██████╔╝██║   ██║██║   ██║██████╔╝                  
██║   ██║╚════██║██╔══╝  ██╔══██╗    ██║   ██║██╔══██╗██║   ██║██║   ██║██╔═══╝                   
╚██████╔╝███████║███████╗██║  ██║    ╚██████╔╝██║  ██║╚██████╔╝╚██████╔╝██║                       
 ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝     ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝                       
                                                                                                  
 █████╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗     ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ 
██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝     ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗
███████║██║  ██║██║  ██║██║██╔██╗ ██║██║  ███╗    ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝
██╔══██║██║  ██║██║  ██║██║██║╚██╗██║██║   ██║    ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗
██║  ██║██████╔╝██████╔╝██║██║ ╚████║╚██████╔╝    ██║  ██║███████╗███████╗██║     ███████╗██║  ██║
╚═╝  ╚═╝╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝
                                                                                                  
"

$creds = Get-Credential
# defining file paths
$ServerListPath = Join-Path $PSScriptRoot 'remote_hosts.txt'
$UserListPath   = Join-Path $PSScriptRoot 'data\users_to_add.txt'
# defining parameters
$whichGroup = Read-Host "Enter the target local user group"
$Servers = Get-Content $ServerListPath
$Users   = Get-Content $UserListPath

foreach ($Server in $Servers) {
    Write-Host "Connecting to $Server ..." -ForegroundColor Cyan

    try {
        Invoke-Command -ComputerName $Server -Credential $creds -Authentication Negotiate -ScriptBlock {
          #  param ($Users)

            foreach ($User in $Using:Users) {
                try {
                    Add-LocalGroupMember -Group $Using:whichGroup -Member $User -ErrorAction Stop
                    Write-Host "Added $User to $Using:whichGroup." -ForegroundColor Green
                }
                catch {
                    Write-Host "Could not add $User to $Using:whichGroup : $_" -ForegroundColor Red
                }
            } # end of foreach 2
        }  -ErrorAction Stop
    }
    catch {
        Write-Host "Error while connecting to $Server : $_" -ForegroundColor Red
    }

    Write-Host "---------------------------------------"

} # end of foreach 1

if($Error)
{
    Write-Host "======= The script has finished! ======="
    Write-Host "======= Warning! Errors have occured! =======" -BackgroundColor Red
    Read-Host "Press enter to exit"
}
else
{
    Write-Host "======= The script has finished successfully! =======" -ForegroundColor Green
    Read-Host "Press enter to exit"
}
