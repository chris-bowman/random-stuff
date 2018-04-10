if((Get-AzureRmContext).Account -eq $null) {
    Write-Host "Logging into AzureRM"
    Login-AzureRmAccount
}

$subs=Get-AzureRmSubscription | Out-GridView -PassThru -Title "Subscription selection"

foreach ($sub in $subs) {
    $sub | Select-AzureRmSubscription | Out-Null
    Write-Host "working on $($sub.Name) $($sub.Id)"
    $servers = Get-AzureRmSqlServer | Where-Object {$_.Location -eq "australiasoutheast"}
    foreach ($server in $servers) {
        Write-Host "$($server.ServerName): $((Resolve-DnsName $server.FullyQualifiedDomainName).IPAddress)"
    }
} 
