#Script used to identify SMB shares by querying Active Directory then checking each computer for Shared Folders using "net view"

#Enter target domain here
$domain = "FakeAdDomain.com"

$ErrorActionPreference = "SilentlyContinue"
$computers = Get-ADComputer -filter * -Server $domain 

foreach($c in $computers){
    Clear-Variable check -ErrorAction SilentlyContinue
    $target = $c.DNSHostName
    if($c.dnshostname){
        $shared = (net view \\$target /all) | % { if($_.IndexOf(' Disk ') -gt 0){ $_.Split('  ')[0] } }
        ""
        $target
        foreach($s in $shared){
            $filepath = "\\"+$target+"\"+$s
            $check = gci $filepath
            $c | select @{Name="Server";Expression={$target}}, @{Name="Path";Expression={$filepath}}, @{Name="Files";Expression={$check.count}}
            #$c | select @{Name="Server";Expression={$target}}, @{Name="Path";Expression={$filepath}}, @{Name="Files";Expression={$check.count}} | Export-Csv c:\temp\OpenFileShares.csv -NoTypeInformation -Append
        }
    }
}

