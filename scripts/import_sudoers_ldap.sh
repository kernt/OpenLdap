#!/bin/bash
#
#
#
#
SUDOERS_BASE=ou=SUDOers,dc=example,dc=com

export SUDOERS_BASE

./sudoers2ldif /etc/sudoers > /tmp/sudoers.ldif

ldapadd -f /tmp/sudoers.ldif -h ldapserver -D cn=Manager,dc=example,dc=com -W -x

ldapsearch -b "$SUDOERS_BASE" -D cn=Manager,dc=example,dc=com -W -x

# not posible in online OpenLdap configuration !!
# use this and convert your slapd.conf 


