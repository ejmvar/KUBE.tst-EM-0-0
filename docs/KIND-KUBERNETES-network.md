kind assigns pods the 10.244.0.0/16 range and services 10.96.0.0/16 by default for IPv4. Write those two numbers down. When a corporate VPN or home network already uses either range, routing breaks in ways that look like random timeouts. Both ranges can be overridden in the cluster config under networking.podSubnet and networking.serviceSubnet.

