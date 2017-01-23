#!/bin/bash
#
# Quelle: http://www.openldap.org/lists/openldap-software/200110/msg00539.html
#
HELP= echo "maxldauid LDAPDN ldapsecret" 

################################################################
# Variables for get Max Uid funktion
################################################################

ldapDN="$1"
ldapsecret="-w $1"
LDAPMANAGER="admin"

function getMaxUid ()
{
n=0
for i in $(ldapsearch -x -LLL $ldapsecret -D "cn=$LDAPMANAGER, $ldapDN" "(uidNumber=*)" uidNumber -S uidNumber | grep uidNumber | tail -n1 );
 do \
    ldaparry[$n]=$i
    let n+=1
 done
    if [ "${ldaparry[0]}" == "uidNumber:" ]; then
	   echo $((${ldaparry[1]}+1))
	   return 0
    else
	   return -1
    fi
}

#################################################################
# Variables for adduser funktion
#################################################################

LDAPUSERDN=""
LDAPGROUPDN=""
LDAPNEWUSER=""
LDAPSN=""
LDAPW="slappasswd -s test"
LDAPSHADOWMAX=""
LDAPGID=""
LDAPUID=""
LDAPCN=""
LDAPUSERHOME=""

function readpw ()
{
	echo " Choose a password for your user " 
	read -e PW 
	echo $PW 
}


function adduser ()
{
    echo "dn: cn=,ou=People,$ldapDN"
    echo "uid: $LDAPUID"
    echo "cn: tempacc"
    echo "sn: surname"
    echo "objectClass: person"
    echo "objectClass: organizationalPerson"
    echo "objectClass: inetOrgPerson"
    echo "objectClass: account"openldap-software@OpenLDAP.org
    echo "objectClass: posixAccount"
    echo "objectClass: top"
    echo "objectClass: shadowAccount"
    echo "userPassword:: LDAPPW"
    echo "shadowLastChange: 11159"
    echo "shadowMax: 99999"
    echo "shadowWarning: 7"
    echo "gidNumber: 100"
    echo "homeDirectory: /home/users/tempacc"
    uidNumber=`getMaxUid`
    (($uidNumber > 0))
     if [ $? ]; then
	    echo "uidNumber: $uidNumber"
	    return 0
      else
	     return -1
     fi
}

adduser | ldapadd -x $ldapsecret -D "cn=Manager, $ldapDN
exit 0
