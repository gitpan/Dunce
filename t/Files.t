# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'


######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)
use strict;

use vars qw($Total_tests);

my $loaded;
my $test_num = 1;

# Utility testing functions.
sub ok ($;$) {
    my($test, $name) = @_;
    print "not " unless $test;
    print "ok $test_num";
    print " - $name" if defined $name;
    print "\n";
    $test_num++;
}

sub skip (;$) {
    my($reason) = @_;
    print "ok $test_num";
    print " # skip $reason";
    print "\n";
    $test_num++;
}

sub eqarray  {
    my($a1, $a2) = @_;
    return 0 unless @$a1 == @$a2;
    my $ok = 1;
    for (0..$#{$a1}) { 
        unless($a1->[$_] eq $a2->[$_]) {
        $ok = 0;
        last;
        }
    }
    return $ok;
}

BEGIN { $| = 1; $^W = 1; }
END {print "not ok $test_num\n" unless $loaded;}
print "1..$Total_tests\n";
use Dunce::Files;
$loaded = 1;
ok(1, 'compile');
######################### End of black magic.

# Change this to your # of ok() calls + 1
BEGIN { $Total_tests = 8 }

sub do_nothing { 1 }

eval { 
    local $SIG{__WARN__} = sub { die @_ };
    open(FILE, 'bogus'); 
};
ok( $@ =~ /^You didn't check/ );  #'#

eval { 
    local $SIG{__WARN__} = sub { die @_ };
    open(FILE, 't/Files.t') || die $!;
    1;
};
ok( !$@ );

my $Buh;
eval { 
    local $SIG{__WARN__} = sub { die @_ };
    chmod(0755, 'moo') || do_nothing();
    1;
};
ok( $@ =~ /^Don't make files/,                                  'chmod' );

#'#
my %hash = (foo => 'bar');
eval { 
    local $SIG{__WARN__} = sub { die @_ };
    dbmopen(%hash, "testingdb", 0644) || do_nothing;
    1;
};
ok( $@ =~ /^Hash given to dbmopen\(\) already contains data/,   'dbmopen' );

if( $] >= 5.007 ) {
    my @test = qw(something morestuff);
#    ok( chop(@test) eq 'f',              'normal chop LIST' );
    skip("something's wrong with CORE::chop(LIST)'s return value");
    my $test = 'morestuff';
    ok( (chop($test) eq 'f' and $test eq 'morestuf'), 'normal chop EXPR' );

    eval {
        local $SIG{__WARN__} = sub { die @_ };
        local $_ = "foo\n";
        chop($_);
        1;
    };
    ok( ($@ =~ /Looks like you're using chop\(\) to strip newlines/i), 
        'chop' );
}
#'#
else {
    for (1..3) { skip('chop() non-overridable before 5.7.0'); }
}

