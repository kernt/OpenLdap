#!/bin/bash
#
#
#
#
##########################################################
BASEDN="dc=example,dc=com"
# Please add key with slappasswd 
CONFIGADMPW=$1
SLAPPASSORD=$(slappasswd -s ${CONFIGADMPW})
KEYCONFIDADM="${SLAPPASSORD}"


cat > db.ldif  << EOF
###########################################################
# DEFAULT DATABASE MODIFICATION
###########################################################

# Modify directory database
dn: olcDatabase={1}mdb,cn=config
changeType: modify
delete: olcSuffix

dn: olcDatabase={1}mdb,cn=config
changeType: modify
add: olcSuffix
olcSuffix: ${BASEDN}

dn: olcDatabase={1}mdb,cn=config
changeType: modify
delete: olcRootDN

dn: olcDatabase={1}mdb,cn=config
changeType: modify
add: olcRootDN
olcRootDN: cn=admin,${BASEDN}

dn: olcDatabase={1}mdb,cn=config
changeType: modify
delete: olcRootPW

dn: olcDatabase={1}mdb,cn=config
changeType: modify
add: olcRootPW
olcRootPW: $KEYCONFIDADM

dn: olcDatabase={1}mdb,cn=config
changeType: modify
delete: olcDbIndex

dn: olcDatabase={1}mdb,cn=config
changeType: modify
add: olcDbIndex
olcDbIndex: uid pres,eq

dn: olcDatabase={1}mdb,cn=config
changeType: modify
add: olcDbIndex
olcDbIndex: cn,sn,mail pres,eq,approx,sub

dn: olcDatabase={1}mdb,cn=config
changeType: modify
add: olcDbIndex
olcDbIndex: objectClass eq

###########################################################
# REMOTE CONFIGURATION DEFAULTS
###########################################################
# Some defaults need to be added in order to allow remote 
# access by DN cn=admin,cn=config to the LDAP config 
# database. Otherwise only local root will 
# administrative access.

dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootDN
olcRootDN: cn=admin,cn=config

dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: ${KEYCONFIDADM}

EOF

ldapadd -Y EXTERNAL -H ldapi:/// -f db.ldif 

rm -f db.ldif

exit 0
