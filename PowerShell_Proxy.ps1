[system.net.webrequest]::DefaultWebProxy = new-object system.net.webproxy('http://localhost:8080')
# If you need to import proxy settings from Internet Explorer, you can replace the previous line with the: "netsh winhttp import proxy source=ie"
[system.net.webrequest]::DefaultWebProxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
# You can request user credentials:
# System.Net.WebRequest]::DefaultWebProxy.Credentials = Get-Credential
# Also, you can get the user password from a saved XML file (see the article “Using saved credentials in PowerShell scripts”):
# System.Net.WebRequest]::DefaultWebProxy= Import-Clixml -Path C:\PS\user_creds.xml
[system.net.webrequest]::DefaultWebProxy.BypassProxyOnLocal = $true


add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
#Ref: http://woshub.com/using-powershell-behind-a-proxy/

$token = Get-AADIntAccessTokenForAADGraph -Credentials $creds -Verbose 

$results = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers 


