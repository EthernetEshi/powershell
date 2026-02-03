This script will add domain users to local Windows user groups on remote or local computers.

Prerequisities:
	The user account entered when asked for credentials must have elevated priviliges on the host(s)
	
  The remote hosts allow PowerShell Remoting and WinRM is configured.
		-> Start PowerShell as Administrator
		-> Run "Enable-PSRemoting -Force" and "winrm quickconfig"
	
  If you want to execute the script locally, PowerShell script execution must be allowed.
		-> Start PowerShell as Administrator
		-> Run "Set-ExecutionPolicy Unrestricted"
		
######### The following instructions apply to REMOTE execution #########

  1. Insert the remote computers' names into the "remote_hosts.txt" file located in the root folder. Only one name per line is allowed!
	
  2. Insert the user names into the "users_to_add.txt" file located in "\data". Only one user name per line is allowed!
	
  3. Execute "Add_User_LocalGroup_Remote.ps1" located in the root folder. Follow the instructions of the script.
	
######### The following instructions apply to LOCAL execution #########
	
  1. Insert the user names into the "users_to_add.txt" file located in "\data". Only one user name per line is allowed!
	
  2. Execute "Add_User_LocalGroups.ps1" located in "\data". Follow the instructions of the script.
