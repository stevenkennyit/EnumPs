#Script used to identify SMB shares by querying Active Directory then checking each computer for Shared Folders using "net view"

#Allow scripts to run by changing execution policy
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force

#Uncomment the line below to install the ADModule for powershell . Note: Requires local admin permissions to install
#Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online 
#Reference: https://www.varonis.com/blog/powershell-active-directory-module

#Output will be stored in the c:\temp\ folder named 
New-Item -ItemType Directory -Force -Path C:\Temp -ErrorAction SilentlyContinue
$output = "c:\temp\OpenFileShares_080223.csv"

#Enter target domain here. Note: For best results, run this script as a domain user from the target domain 
$domain = "fakedomainfornowhere[.]com"

#Uncomment line below to suppress errors 
#$ErrorActionPreference = "SilentlyContinue"
Get-ADComputer -filter * -Server $domain | %{

    Clear-Variable check, target, shared -ErrorAction SilentlyContinue
    $target = $_.DNSHostName
    if($target){
        $shared = (net view \\$target /all) | % { if($_.IndexOf(' Disk ') -gt 0){ $_.Split('  ')[0] } }
        ""
        $target
        foreach($s in $shared){
            $filepath = "\\"+$target+"\"+$s
            $check = gci $filepath
            $_ | select @{Name="Server";Expression={$target}}, @{Name="Path";Expression={$filepath}}, @{Name="Files";Expression={$check.count}}
            $_ | select @{Name="Server";Expression={$target}}, @{Name="Path";Expression={$filepath}}, @{Name="Files";Expression={$check.count}} | Export-Csv $output -NoTypeInformation -Append
        }
    }
}

