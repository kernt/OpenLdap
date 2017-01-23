#quelle :http://www.tek-tips.com/viewthread.cfm?qid=1702372


#I need to find first free number from that range, which is the same for /etc/passwd and /etc/group (to create a user with the same number of his uid and gid where guid are from mentined range).

awk -F: '{uid[$3]=1}END{for(x=2000; x<=10000; x++) {if(uid[x] != ""){}else{print x; exit;}}}' /etc/passwd
awk -F: '{uid[$3]=1}END{for(x=2000; x<=10000; x++) {if(uid[x] != ""){}else{print x; exit;}}}' /etc/group

awk -F: -vl=${first} -vm=${max} '{uid[$2]=1}END{for(x=l;x<=m;x++)if(!uid[x]){print x;exit}}' file1 file2 file3 file4
