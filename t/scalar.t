use v6.c;
use Test;
use tie;

plan 1;

my int $tiescalared;
my int $fetched;
my int $stored;
my int $untied;

module Foo {
    our sub TIESCALAR($class) is raw { my $tied }
    our sub FETCH(\tied) is raw { tied }
    our sub STORE(\tied,\value) is raw { tied = value }
    our sub UNTIE(\tied) is raw { tied } 
}   

tie my $a, Foo;
ok $a ~~ Any, 'did we get a 42';

say $a; 
$a = 42;
say $a;

# vim: ft=perl6 expandtab sw=4
