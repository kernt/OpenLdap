#!/usr/bin/perl
use strict;
use warnings;
use Net::LDAP;

my $uid = $ARGV[0];

if ( !defined($uid) ) {
    die("Error: no uid given \n");
}

my $ldap = Net::LDAP->new( "localhost:9389" ) or die "$@";
my $mesg = $ldap->bind;
$mesg = $ldap->search(    # perform a search
    base   => "ou=Users, dc=example, dc=com",
    scope  => "sub",
    filter => "(uid=$uid)"
);

$mesg->code && die $mesg->error;
$ldap->unbind();

if ($mesg->count ==0) {
    print "no user found\n";
} elsif ($mesg->count > 1) {
    print "more than one user found\n";
} else {
    print $mesg->entry(0)->get_value("sn") . "," . $mesg->entry(0)->get_value("givenName") . "\n";
}

