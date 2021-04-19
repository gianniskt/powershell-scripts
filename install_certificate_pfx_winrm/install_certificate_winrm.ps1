#Credentials For PS-Sessions
$username = "contoso.com\user"
$password = ConvertTo-SecureString -String "user_password" -AsPlainText -Force
$credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $username, $password


#Folder Paths of server hostnames and certificate
$servers = Get-Content "c:\path\to\serversfile.txt"
$source = "C:\path\to\certificate.pfx"
$dest = "C:\destination\folder\path"


#PS-Session to servers, copy certificate to new folder and installation
$sessions = Get-Content $servers | New-PSSession -Credential $credential
$certpasswd = ConvertTo-SecureString -String "user_password" -AsPlainText -Force


    foreach ($session in $sessions) {

        Invoke-Command -Session $sessions -ScriptBlock { New-Item C:\destination\folder\path -type directory -force }

        Copy-Item -Path "$source" -Destination "$dest" -Recurse -ToSession $session

        Invoke-Command -Session $sessions -ScriptBlock { Import-PfxCertificate -FilePath "$dest" -CertStoreLocation Cert:\LocalMachine\My -Password $using:certpasswd -Verbose }

        Invoke-Command -Session $sessions -ScriptBlock { winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="*.contoso.com";CertificateThumbprint="insert_cert_thumbprint_here"}' }

        Invoke-Command -Session $sessions -ScriptBlock { Get-Service -Name WinRM | Restart-Service }
		
		Invoke-Command -Session $sessions -ScriptBlock { New-NetFirewallRule -DisplayName "Ansible Allow HTTPS 5986" -RemoteAddress ip_of_Ansible -Direction Inbound -Protocol TCP -LocalPort 5986 -Profile Domain -Action Allow }
        
                                    }

    Remove-PSSession -Session $sessions
    Get-PSSession


#If winrm is disabled you can enable it on hosts with this command
#.\psexec @c:\path\to\serversfile.txt -Username contoso.com\user -s winrm.cmd quickconfig -transport:https -q

#Delete winRM Listener
#winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
#winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="*.contoso.com";CertificateThumbprint="insert_cert_thumbprint_here"}'
#winrm get winrm/config
#net stop winrm
#net start winrm