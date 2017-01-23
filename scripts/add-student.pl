#!/usr/bin/perl
#
# Script adds a cloud of random student accounts to the ldap directory
#
#
use Getopt::Long;
use Net::LDAP;
use Net::LDAP::LDIF;
use Net::LDAP::Constant;
use DateTime;
use Digest::SHA1;
use MIME::Base64;

use warnings;
use strict;

my $uri;
my $rootdn;
my $rootpw;
my $basedn;

my @users;
my $prefix;                  # which prefix shall the account names have ?
my $group  = "studenten";    # which groups shall the accounts belong to ?
my $number = 0;              # the number of accounts to create
my $desc="";                    
my $allowed="heartofgold";      
                                
my $enddate;                 # deactivation date of account
my $batch = 0;               # do not ask questions
                                
sub usage {
        print "\n";
        print "Usage: add_student_cloud.pl <options> \n";
        print "\t --prefix=s  \t\t the prefix for the account names \n";
        print "\t --group=s   \t\t the main group of the accounts \n";
        print "\t --number=i  \t\t the number of accounts to create\n";
        print "\t --desc=s    \t\t an optional description \n";
        print "\t --allowed=s \t\t komma seperated list of allowed hostnames\n";
        print "\t --enddate=s \t\t the date when the account should be deactivated dd.mm.yyyy\n";
        print "\t --batch     \t\t run in batch mode, no asking for questions\n";
        print "\t --uri=s     \t\t the uri of the ldap server\n";
        print "\t --rootdn=s  \t\t the rootdn for authentication\n";
        print "\t --rootpw=s  \t\t the password for the rootdn\n";
}
                
#parse commandline
my $result = GetOptions(
        "prefix=s"  => \$prefix,
        "group=s"   => \$group,
        "number=i"  => \$number,
        "enddate=s" => \$enddate,
        "batch"     => \$batch,
        "uri=s"     => \$uri,
        "rootdn=s"  => \$rootdn,
        "rootpw=s"  => \$rootpw,
        "basedn=s"  => \$basedn,
        "desc=s"    => \$desc,
        "allowed=s" => \$allowed,
);

#check parameters

#the prefix has to be 2 chars long
if ( length($prefix) < 2 ) {
        print("Error: Prefix length must be 2 \n");
        usage();
}

#number has to be > 0
if ( $number == 0 ) {
        print "Error: Please give the number of accounts you want to create. \n";
        usage();
}

#check enddate
if ( !defined($enddate) || $enddate !~ /\d{1,2}.\d{1,2}.\d{4}/ ) {
        print "Error: a correct deactivation date of the account must be given.\n";
        usage();
}

my $ldap = Net::LDAP->new( $uri, version => 3 ) or die "$@";
my $msg = $ldap->bind( $rootdn, password => $rootpw ) or die "$@";

if ( $msg->is_error() ) {
        die( "LDAP_ERROR: " . $msg->error() );
}

#get gid of $group
my $query = $ldap->search(
        base   => $basedn,
        filter => "(&(cn=$group)(objectClass=posixGroup))",
        scope  => "sub",
        attrs  => ['*']
);

$query->code && die $query->error;

if ( $query->entries == 0 ) {
        die("Group $group not found\n");
}

my $gid = $query->entry(0)->get_value("gidNumber");
print $gid . "\n";

for ( my $i = 0 ; $i < $number ; $i++ ) {
        my $found = 0;
        my %user;
        while ( $found == 0 ) {

                #get a random number and check if account already exist
                my $random_number = int( rand(9999) );
                while ( $random_number < 1000 ) {
                        $random_number = int( rand(9999) );
                }
                $user{account} = $prefix . $random_number;

                #check if useraccount already exists
                my $query = $ldap->search(
                        base   => $basedn,
                        filter => "(&(uid=$user{account})(objectClass=posixAccount))",
                        scope  => "sub"
                );

                $query->code && die $query->error;

if ( $query->entries == 0 ) {
                        $found = 1;
                }

                #now generate random password for user
                $user{password} = readpipe(
                        "dd if=/dev/urandom count=128 bs=1 2>&1 | md5sum | cut -b-8");
                chop $user{password};

                #create user dn
                $user{dn}="uid=".$user{account}.",ou=Users,".$basedn;

                #create allowed host list
                my @allowed_hosts=split /\,/,$allowed;

                #calc epoch for enddate
                $enddate=~ /(\d{1,2}).(\d{1,2}).(\d{4})/;
                my $dt = DateTime->new( year   => $3, month  => $2, day    => $1, hour   => 23, minute => 59, second => 59);
                my $expire=int($dt->epoch / 60 / 60 / 24);

                #get the next uid Number
                my $uids = $ldap->search(
                        base => "ou=Users," . $basedn,
                        scope => "sub",
                        filter => "uidNumber=*",
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
                $high++;

                my $uid=$high;

                #create password
                my $ctx = Digest::SHA1->new;
                $ctx->add($user{password});
                $user{userPassword} = '{SHA}' . encode_base64($ctx->digest,'');


                my $result=$ldap->add(
                                $user{dn},
                                attr => [
                                        'cn'                           =>  "Student Account",
                                        'givenName'             =>  "none",
                                        'sn'                           =>  "none",
                                        'gidNumber'             =>  $gid,
                                        'homeDirectory'        =>  "/home/" . $user{account},
                                        'host'                         =>   \@allowed_hosts,
                                        'loginShell'                =>  '/bin/sh',
                                        'objectclass'              =>  ['top','inetOrgPerson','posixAccount','shadowAccount','hostObject'],
                                        'shadowExpire'         =>  $expire,
                                        'uidNumber'              =>  $uid,
                                        'userPassword'         =>  $user{userPassword},
                                        ],
                );
                $result->code && die "failed to add entry: ", $result->error;
                push( @users, \%user );
        }
}

$ldap->unbind;

#create a nice output
print "\n";
for ( my $i = 0 ; $i < 84 ; $i++ ) {
        print "-";
}
print "\n\n";

my $c = 0;
for my $u (@users) {
        $c++;
        print $u->{account} . " : " . $u->{password};
        if ( $c == 3 ) {
                $c = 0;
                print "  |\n\n";
                for ( my $i = 0 ; $i < 84 ; $i++ ) {
                        print "-";
                }
                print "\n\n";
        }
        else {
                print "       |       ";
        }

}
print "\n \n";
for ( my $i = 0 ; $i < 84 ; $i++ ) {
        print "-";
}
print "\n";

