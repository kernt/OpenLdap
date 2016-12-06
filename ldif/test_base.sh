#!/bin/bash
ldapsearch -x -b 'dc=example,dc=org' '(objectclass=*)'

