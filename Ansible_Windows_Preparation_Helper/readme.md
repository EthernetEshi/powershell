This script has the purpose of remotely creating a local Windows account that is used for remote management with Ansible and adds it to all necessary user groups.
It also disables the local account administrator token filter policy.

Usage: 
1. Insert the target machine's host names into the remote_hosts.txt file
2. Run the script
3. Enter your PowerShell remoting credentials
4. Name your Ansible user
5. Enter its new password

> [!NOTE]
>If the specified user already exists, the script will only add the token filter registry key.  
>Password expiry will be disabled.
