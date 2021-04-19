# Install .pfx Certificate with WinRM
This script makes a copy of your .pfx certificate to the remote machines, and install it to */LocalMachine/Personal*.
It's very useful for connecting Windows Hosts to Ansible, so it has also a command that enables firewall rule for port 5986.
___
### PreRequisites
1) Text file with server hostnames
2) .pfx Certificate on source folder
3) A Domain User that is local admin on remote machines.
