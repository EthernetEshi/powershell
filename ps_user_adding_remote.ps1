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
            param ($Users, $whichGroup)

            foreach ($User in $Users) {
                try {
                    Add-LocalGroupMember -Group $whichGroup -Member $User -ErrorAction Stop
                    Write-Host "Added $User to $whichGroup." -ForegroundColor Green
                }
                catch {
                    Write-Host "Could not add $User to $whichGroup : $_" -ForegroundColor Red
                }
            }
        } -ArgumentList ($Users) -ErrorAction Stop
    }
    catch {
        Write-Host "Error while connecting to $Server : $_" -ForegroundColor Red
    }

    Write-Host "---------------------------------------"

}

if($Error)
{
    Write-Host "======= The script has finished! ======="
    Write-Host "======= Warning! Errors have occured! =======" -BackgroundColor Red
}
else
{
    Write-Host "======= The script has finished successfully! =======" -ForegroundColor Green
}
