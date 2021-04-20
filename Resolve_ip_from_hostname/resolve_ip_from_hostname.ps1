#Insert the hostnames in "hostnames.txt"
#Prerequisites -> Set-ExecutionPolicy UnRestricted -File .\resolve_ip_from_hostname.ps1
#author: Koutroumpis Giannis

Get-Content .\hostnames.txt | ForEach {

    $details = Test-Connection -ComputerName $_ -Count 1 -ErrorAction SilentlyContinue

    if ($details) {

        $props = @{
            ComputerName = $_
            IP = $details.IPV4Address.IPAddressToString
        }

        New-Object PsObject -Property $props
    }

    Else {    
        $props = @{
            ComputerName = $_
            IP = 'Unreachable'
        }

        New-Object PsObject -Property $props
    }

} | Sort ComputerName | Export-Csv .\hosts.csv -Delimiter ';'  -NoTypeInformation
    set-content .\hosts.csv ((get-content .\hosts.csv) -replace '"')