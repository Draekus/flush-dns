$test = Get-NetAdapter
$adapters = $test.InterfaceAlias
foreach ($adapter in $adapters) {
    Write-Host $adapter
}
$interface = Read-Host -Prompt "Please enter the interface alias of your Ethernet or WiFi device"

# foreach ($item in $test) {
#     Write-Host $item.name
# }
# $test = $test.ServerAddresses[0]
Write-Host $interface