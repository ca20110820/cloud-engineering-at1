# Enable ICMP (Ping) rules for both incoming and outgoing traffic for Windows VMs
New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow -Direction Inbound
New-NetFirewallRule -DisplayName "Allow ICMPv4-Out" -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow -Direction Outbound
Write-Output "ICMP (Ping) rules have been successfully configured for both incoming and outgoing traffic."
