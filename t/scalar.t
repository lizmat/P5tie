use v6.c;
use Test;
use P5tie;

plan 10;

my int $tiescalared;
my int $fetched;
my int $stored;
my int $untied;

module Foo {
    our sub TIESCALAR($class) is raw {
        ++$tiescalared;
        my Int $tied = 42
    }
    our sub FETCH(\tied) is raw {
        ++$fetched;
        tied
    }
    our sub STORE(\tied,\value) is raw {
        ++$stored;
        tied = value
    }
    our sub UNTIE(\tied) is raw {
        ++$untied;
        tied
    } 
}

tie my $a, Foo;
dd $a;
is $a, 42, 'did we get 42';
is $tiescalared, 1, 'did we see a TIESCALAR?';
ok $fetched > 1,    'did we see at least one FETCH?';
is $stored,      0, 'did we NOT see a STORE?';
is $untied,      0, 'did we NOT see an UNTIE?';
$tiescalared = $fetched = $stored = $untied = 0;

$a = 666;
dd $a;
is $a, 666, 'did we get 666';
is $tiescalared, 0, 'did we NOT see a TIESCALAR?';
ok $fetched > 1,    'did we see at least one FETCH?';
is $stored,      1, 'did we see a STORE?';
is $untied,      0, 'did we NOT see an UNTIE?';

# vim: ft=perl6 expandtab sw=4
