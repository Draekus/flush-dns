# Create object to store IPv4 DNS data
$ipv4_dns = New-Object -TypeName psobject
$ipv4_dns | Add-Member -MemberType NoteProperty -Name primary -Value "Default"
$ipv4_dns | Add-Member -MemberType NoteProperty -Name secondary -Value "Default"

# Create object to store IPv6 DNS data
$ipv6_dns = New-Object -TypeName psobject
$ipv6_dns | Add-Member -MemberType NoteProperty -Name primary -Value "Default"
$ipv6_dns | Add-Member -MemberType NoteProperty -Name secondary -Value "Default"

# Prompt User Before Flushing DNS
function prompt_user {
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Allows the DNS cache to be flushed'
    $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Prevents the DNS cache from being flushed'
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = $host.ui.PromptForChoice('Preparing to flush local DNS cache...', 'Would you like erase all the DNS data stored in the local cache?', $options, 0)
 
    switch ($result) {
        0 {
            $message = "`nLocal DNS cache will be flushed. This removes ONLY data stored on YOUR machine. 
            `rPlease refer to your DNS provider's documentation in order to flush the server side cache."
        }
        1 {
            $message = "`nLocal DNS cache will NOT be flushed."
        }
    }
    Write-Host $message -BackgroundColor DarkRed
    Write-Host "`n"
}

function get_dns_data {

    # Get list of available network interface devices
    $adapters = Get-NetAdapter
    $adapters = $adapters.InterfaceAlias

    # Display list of available devices to user
    Write-Host "`rAvailable Interface Devices:" -BackgroundColor DarkCyan -ForegroundColor Black
    Write-Host "`r"
    foreach ($adapter in $adapters) {
        Write-Host "  " $adapter 
    }
    Write-Host "`r"

    # Prompt user to select their desired interface device
    $interface = Read-Host -Prompt "Please enter the name of the interface device you use to connect to the internet"
  
   
    # Get IPv4 server addresses and store them in the ipv4_dns object
    $ipv4 = Get-DnsClientServerAddress -InterfaceAlias $interface -AddressFamily "IPv4"
    $ipv4_dns.primary = $ipv4.ServerAddresses[0]
    $ipv4_dns.secondary = $ipv4.ServerAddresses[1]

    # Stores IPv4 server addresses or sets to "None" if it cannot be found   
    if ( -not $ipv4_dns.primary ) { 
        $ipv4_dns.primary = "None"   
    } 
    
    if (-not $ipv4_dns.secondary) { 
        $ipv4_dns.secondary = "None"   
    } 
    
    # Get IPv6 server addresses and store them in the ipv6_dns object
    $ipv6 = Get-DnsClientServerAddress -InterfaceAlias "Ethernet" -AddressFamily "IPv6"
    $ipv6_dns.primary = $ipv6.ServerAddresses[0]
    $ipv6_dns.secondary = $ipv6.ServerAddresses[1]
    
    # Stores IPv6 server addresses or sets to "None" if it cannot be found   
    if ( -not $ipv6_dns.primary ) { 
        $ipv6_dns.primary = "None"   
    } 
    
    if (-not $ipv6_dns.secondary) { 
        $ipv6_dns.secondary = "None"   
    } 

    # Write server IP data to screen
    Write-Host "------------- IPv4 DNS Configuration -------------" -BackgroundColor DarkCyan -ForegroundColor Black
    Write-Host "`r"
    Write-Host "        Primary:         "  $ipv4_dns.primary
    Write-Host "        Secondary:       "  $ipv4_dns.secondary
    Write-Host "`r"

    Write-Host "------------- IPv6 DNS Configuration -------------" -BackgroundColor DarkCyan -ForegroundColor Black
    Write-Host "`r"
    Write-Host "        Primary:         " $ipv6_dns.primary
    Write-Host "        Secondary:       " $ipv6_dns.secondary
    Write-Host "`r"

}
get_dns_data
prompt_user

Clear-DnsClientCache
if ($?) {
    Write-Host "Locally Cached DNS Data Succesfully Flushed ..."
}