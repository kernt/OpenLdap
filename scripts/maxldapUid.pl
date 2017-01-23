use Net::LDAP::posixAccount;

sub high_id {
        my $ldap = shift;

        my $uids = $ldap->search(
                        base    => "ou=People,dc=rlb3,dc=com",
                        scope   => "sub",
                        filter  => "uidNumber=*", 
                        attrs   => [ 'uidNumber' ],
                        );
        my @uids;
        if ($uids->count > 0) {
                foreach my $uid ($uids->all_entries) {
                        push @uids, $uid->get_value('uidNumber');
                }
        }       
        
        @uids = sort { $b <=> $a } @uids;

        my $high = $uids[0];

        return ++$high;
} 
