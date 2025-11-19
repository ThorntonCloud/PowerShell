$LocalCertPath = "C:\Users\su_jthornton.dev\Downloads\StarDevProliantOrg_Legacy.pfx"

$RemoteCertPath = "C:\Temp\StarDevProliantOrg_Legacy.pfx"

$CertPassword = ConvertTo-SecureString -String "Proliant.1" -AsPlainText -Force

$RemoteServers = @(
    "atl0dev73util",
    "atl0dev75web",
    "atl0dev81web",
    "atl0devweb195",
    "atl0dev74util",
    "atl0dev28ptweb",
    "atl0dev29ptapp",
    "atl0dev31ptweb",
    "atl0dev32ptapp",
    "atl0dev90web",
    "a0dev85web",
    "ATLDEVWEB01.proliant.org",
    "atl0dev144web",
    "atl0dev145api"
)

foreach ($Server in $RemoteServers) {
    Write-Host "=== Processing $Server ===" -ForegroundColor Cyan

    try {
        Invoke-Command -ComputerName $Server -ScriptBlock {
            if (-not (Test-Path "C:\Temp")) {
                New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
            }
        } -ErrorAction Stop

        Copy-Item -Path $LocalCertPath -Destination "\\$Server\c$\Temp\StarDevProliantOrg_Legacy.pfx" -Force

        Invoke-Command -ComputerName $Server -ScriptBlock {
            Import-PfxCertificate `
                -FilePath $using:RemoteCertPath `
                -CertStoreLocation Cert:\LocalMachine\My `
                -Password $using:CertPassword `
                -ErrorAction Stop

            Remove-Item -Path $using:RemoteCertPath -Force
        } -ErrorAction Stop

        Write-Host "Successfully install cert on $Server" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed on $Server : $_" -ForegroundColor Red
    }
}