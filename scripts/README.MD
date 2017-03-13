Script Descriptions
===

#### add-student.pl
Add a user 
  
#### cn=config.sh
Allow remote conection to cn=config 
  
#### import_sudoers_ldap.sh

#### ldap_whois.pl
  
#### macldapUid.sh
  
#### maxldapUid.pl
  
#### nextfreeuid.awk

#### slapd-debug-foreground.sh
Execute slapd as deamon in foreground with debug vibosity.

#### schema-to-ldif.sh
converts *.schema to *.ldif 
You have to edit this line to your needs . 
```
...
echo "include /etc/ldap/schema/core.schema" >> convert.dat
echo "include /etc/ldap/schema/cosine.schema" >> convert.dat
echo "include /etc/ldap/schema/nis.schema" >> convert.dat
echo "include /etc/ldap/schema/inetorgperson.schema" >> convert.dat
...
```

