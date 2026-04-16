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

Write-Host "Enter your PowerShell remoting credentials: "
$user = Read-Host "User"
$pass = Read-Host "Password" -AsSecureString
$creds = [PSCredential]::new($user, $pass)
# defining file paths
$ServerListPath = Join-Path $PSScriptRoot 'remote_hosts.txt'
# defining parameters
$Servers = Get-Content $ServerListPath
$AnsibleUserName = Read-Host "Enter the user name for the Ansible user"
$AnsibleUserPassword = Read-Host "Enter password for the ansible user" -AsSecureString

foreach ($Server in $Servers) {
    Write-Host "Connecting to $Server ... `n" -ForegroundColor Cyan
    Write-Host "[STEP 1] Creating $AnsibleUserName and adding it to necessary user groups ...`n" -ForegroundColor Cyan
    try {
        Invoke-Command -ComputerName $Server -Credential $creds -Authentication Negotiate -ScriptBlock {
            $CheckForUser = (Get-LocalUser).Name -contains $Using:AnsibleUserName
            if($CheckForUser -eq $false) {
                try {
                    New-LocalUser -Name $Using:AnsibleUserName -Password $Using:AnsibleUserPassword -Description 'Windows user for access via Ansible' | Out-Null
                    Add-LocalGroupMember -Group 'Administrators' -Member $Using:AnsibleUserName -ErrorAction Stop
                    Add-LocalGroupMember -Group 'OpenSSH Users' -Member $Using:AnsibleUserName -ErrorAction Stop
                    Add-LocalGroupMember -Group 'Remote Management Users' -Member $Using:AnsibleUserName -ErrorAction Stop
                    
                } catch {
                    Write-Host "Error while adding $Using:AnsibleUserName to a group: $_" -ForegroundColor Red
                } finally {
                    if(-not ($Error)) {
                        Write-Host "Created user $Using:AnsibleUserName" -ForegroundColor Green
                        Write-Host "Added $Using:AnsibleUserName to Administrators." -ForegroundColor Green
                        Write-Host "Added $Using:AnsibleUserName to OpenSSH Users." -ForegroundColor Green
                        Write-Host "Added $Using:AnsibleUserName to Remote Management Users." -ForegroundColor Green
                    }
                }
            } else {
                Write-Host "$Using:AnsibleUserName already exists. Moving on ... `n"
            }
            Write-Host "[STEP 2] Disabling administrator token filter policy ..." -ForegroundColor Cyan
            try {
                 New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'LocalAccountTokenFilterPolicy' -PropertyType DWord -Value 1 -Force | Out-Null
                 Write-Host "Successfully added registry key!" -ForegroundColor Green
            } catch {
                Write-Host "Error while disabling administrator token filter policy" -ForegroundColor Red
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
