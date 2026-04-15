Write-Host "
 █████╗ ███╗   ██╗███████╗██╗██████╗ ██╗     ███████╗                                  
██╔══██╗████╗  ██║██╔════╝██║██╔══██╗██║     ██╔════╝                                  
███████║██╔██╗ ██║███████╗██║██████╔╝██║     █████╗                                    
██╔══██║██║╚██╗██║╚════██║██║██╔══██╗██║     ██╔══╝                                    
██║  ██║██║ ╚████║███████║██║██████╔╝███████╗███████╗                                  
╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝╚═════╝ ╚══════╝╚══════╝                                  
                                                                                       
██████╗ ██████╗ ███████╗██████╗  █████╗ ██████╗  █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
██████╔╝██████╔╝█████╗  ██████╔╝███████║██████╔╝███████║   ██║   ██║██║   ██║██╔██╗ ██║
██╔═══╝ ██╔══██╗██╔══╝  ██╔═══╝ ██╔══██║██╔══██╗██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
██║     ██║  ██║███████╗██║     ██║  ██║██║  ██║██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
                                                                                       
██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗                                        
██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗                                       
███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝                                       
██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗                                       
██║  ██║███████╗███████╗██║     ███████╗██║  ██║                                       
╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝                                       
                                                                                                                                                      
"
$creds = Get-Credential
# defining file paths
$ServerListPath = Join-Path $PSScriptRoot 'remote_hosts.txt'
# defining parameters
$Servers = Get-Content $ServerListPath
$AnsibleUserPassword = Read-Host "Enter password for the ansible user" -AsSecureString

foreach ($Server in $Servers) {
    Write-Host "[STEP 1] Connecting to $Server ..." -ForegroundColor Cyan

    try {
        Invoke-Command -ComputerName $Server -Credential $creds -Authentication Negotiate -ScriptBlock {
            $CheckForUser = (Get-LocalUser).Name -contains 'ansible_user'
            if($CheckForUser -eq $false) {
                try {
                    New-LocalUser -Name 'ansible_user' -Password $Using:AnsibleUserPassword -Description 'Windows user for access via Ansible' -PasswordNeverExpires
                    Add-LocalGroupMember -Group 'Administrators' -Member 'ansible_user' -ErrorAction Stop
                    Write-Host "Added ansible_user to Administrators." -ForegroundColor Green
                    Add-LocalGroupMember -Group 'OpenSSH Users' -Member 'ansible_user' -ErrorAction Stop
                    Write-Host "Added ansible_user OpenSSH Users." -ForegroundColor Green
                    Add-LocalGroupMember -Group 'Remote Management Users' -Member 'ansible_user' -ErrorAction Stop
                    Write-Host "Added ansible_user to Remote Management Users." -ForegroundColor Green
                    # Remove-LocalGroupMember -Group 'Users' -Member 'ansible_user' -ErrorAction Stop
                    # Write-Host "Removed ansible_user from Users." -ForegroundColor Green
                } catch {
                    Write-Host "Error while adding ansible_user to a group: $_" -ForegroundColor Red
                }
            }
            try {
                 New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'LocalAccountTokenFilterPolicy' -PropertyType DWord -Value 1 -Force
            } catch {
                Write-Host "Error while removing administrator token filter policy" -ForegroundColor Red
            }   
           
               

        }  -ErrorAction Stop
    }
    catch {
        Write-Host "Error while connecting to $Server : $_" -ForegroundColor Red
    }

    Write-Host "---------------------------------------"

} # end of foreach 1

if($Error) {
    Write-Host "======= The script has finished! ======="
    Write-Host "======= Warning! Errors have occured! =======" -BackgroundColor Red
    Read-Host "Press enter to exit"
} else {
    Write-Host "======= The script has finished successfully! =======" -ForegroundColor Green
    Read-Host "Press enter to exit"
}
