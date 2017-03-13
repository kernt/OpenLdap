#!/bin/bash
/usr/lib/openldap/slapd –f /etc/openldap/slapd.conf –F /etc/openldap/slapd.d –u ldap –g ldap –d -1
exit 0
