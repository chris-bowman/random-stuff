if((Get-AzContext).Account -eq $null) {
    Write-Host "Logging into Az"
    Login-AzAccount
}

$subs=Get-AzSubscription #| Out-GridView -PassThru -Title "Subscription selection"
$vms = @()
$vmsizes = @{}
foreach ($sub in $subs) {
    $sub | Select-AzSubscription
    $vms_status = Get-AzVM -Status
    foreach ($loc in ($vms_status | Sort-Object -Property Location -Unique)) {
        if(-not $vmsizes[$loc.Location]) {
            $vmsizes.Add($loc.Location,(Get-AzVMSize -Location $loc.Location))
        }
    }
    $vms += $vms_status | select-object @{name='subscriptionid';expression={$sub.Id}},@{name='subscriptionname';expression={$sub.Name}}, `
                                        Name,Location,PowerState,@{name='OSType';expression={$_.StorageProfile.OsDisk.OsType}}, `
                                        @{name='Size';expression={$_.HardwareProfile.VmSize}}, LicenseType, `
                                        @{name='CoreCount';expression={$sz=$_.HardwareProfile.VmSize;($vmsizes[$_.Location].Where({$_.Name -eq $sz})).NumberOfCores}}, `
                                        @{name='AHBCoreCount';expression={if($_.StorageProfile.OsDisk.OsType -eq 'Linux') {0} else {$sz=$_.HardwareProfile.VmSize;(@(8,($vmsizes[$_.Location].Where({$_.Name -eq $sz})).NumberOfCores) | Measure -Maximum).Maximum}}}
}
$vms | ConvertTo-Csv -NoTypeInformation | Out-File C:\temp\vm_ahb.csv
