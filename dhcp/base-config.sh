# Here is the entry that starts the DHCP config subtree
# that cn=osgiliath,dc=example,dc=com points to.
dn: cn=dhcp,dc=example,dc=com
cn: dhcp
objectClass: top
objectClass: dhcpService
objectClass: dhcpOptions
dhcpPrimaryDN: cn=pelargir,dc=example,dc=com
dhcpStatements: ddns-update-style interim
dhcpStatements: default-lease-time 86400
dhcpStatements: max-lease-time 604800
dhcpStatements: log-facility local7
dhcpStatements: deny client-updates
dhcpStatements: include "/etc/bind/dhcp-updater.key"
#dhcpOption: time-servers time.euro.apple.com
#

# Define a group for hosts in the 192.168.1.0 network. This includes
# all of our known MAC addresses, and a range of 48 dynamically
# allocated addresses. The group entry also contains common options for
# all hosts in this group.
dn: cn=group-192.168.1.0,cn=dhcp,dc=example,dc=com
cn: group-192.168.1.0
objectClass: top
objectClass: dhcpGroup
objectClass: dhcpOptions
dhcpStatements: zone lan.example.com. { primary 127.0.0.1; key dhcp-updater; }
dhcpStatements: zone 1.168.192.in-addr.arpa. { primary 127.0.0.1; key dhcp-updater; }
dhcpOption: domain-name "lan.example.com"
dhcpOption: domain-name-servers 192.168.1.11, 212.101.0.10, 212.101.4.253
dhcpOption: subnet-mask 255.255.255.0
dhcpOption: broadcast-address 192.168.1.255
dhcpOption: routers 192.168.1.11
dhcpOption: smtp-server 192.168.1.11
dhcpOption: time-servers 192.168.1.11

# The 192.168.1.0 subnet definition is a comild of the group entry.
# The subnet definition specifies that only 48 addresses may be
# dynamically allocated.
dn: cn=192.168.1.0,cn=group-192.168.1.0,cn=dhcp,dc=example,dc=com
cn: 192.168.1.0
objectClass: top
objectClass: dhcpSubnet
dhcpNetMask: 24
dhcpRange: 192.168.1.64 192.168.1.111
dhcpStatements: authoritative

# Define a group for hosts in the 192.168.4.0 network. This includes
# all of our known MAC addresses, and a range of 48 dynamically
# allocated addresses. The group entry also contains common options for
# all hosts in this group.
dn: cn=group-192.168.4.0,cn=dhcp,dc=example,dc=com
cn: group-192.168.4.0
objectClass: top
objectClass: dhcpGroup
objectClass: dhcpOptions
dhcpStatements: zone wifi.example.com. { primary 127.0.0.1; key dhcp-updater; }
dhcpStatements: zone 2.168.192.in-addr.arpa. { primary 127.0.0.1; key dhcp-updater; }
dhcpOption: domain-name "wifi.example.com"
dhcpOption: domain-name-servers 192.168.4.6, 212.101.0.10, 212.101.4.253
dhcpOption: subnet-mask 255.255.255.0
dhcpOption: broadcast-address 192.168.4.255
dhcpOption: routers 192.168.4.6
dhcpOption: smtp-server 192.168.4.6
dhcpOption: time-servers 192.168.4.6

# The 192.168.4.0 subnet definition is a child of the group entry.
# The subnet definition specifies that only 48 addresses may be
# dynamically allocated.
dn: cn=192.168.4.0,cn=group-192.168.4.0,cn=dhcp,dc=example,dc=com
cn: 192.168.4.0
objectClass: top
objectClass: dhcpSubnet
dhcpNetMask: 24
dhcpRange: 192.168.4.64 192.168.4.111
dhcpStatements: authoritative

