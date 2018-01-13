use v6.c;
use Test;
use tie;

module Foo {
    our sub TIESCALAR($class) is raw { my $tied }
    our sub FETCH(\tied) is raw { tied }
    our sub STORE(\tied,\value) is raw { tied = value }
    our sub UNTIE(\tied) is raw { tied } 
}   

tie( my $a );
say $a; 

done-testing;
