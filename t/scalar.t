use v6.c;
use Test;
use P5tie;

plan 7;

my int $tiescalared;
my int $fetched;
my int $stored;
my int $untied;
my int $tested;

sub test-access($sc,$st,$un) {
    subtest {
        plan 4;
        is $tiescalared, $sc, "did we {"NOT " unless $sc}see a TIESCALAR?";
        ok $fetched > 1,      'did we see at least one FETCH?';
        is $stored,      $st, "did we {"NOT " unless $st}see a STORE?";
        is $untied,      $un, "did we {"NOT " unless $un}see an UNTIE?";
        $tiescalared = $fetched = $stored = $untied = 0;
    }, "test accesses #{++$tested} of tied variable";
}

class Foo {
    has Int $.tied;

    our method TIESCALAR() is raw {
        ++$tiescalared;
        self.new
    }
    our method FETCH() is raw {
        ++$fetched;
        $!tied
    }
    our method STORE(\value) is raw {
        ++$stored;
        $!tied = value
    }
    our method UNTIE() is raw {
        ++$untied;
        $!tied
    } 

    our method DESTROY() { }
}

my $object = tie my $a, Foo;
isa-ok $object, Foo, 'is the object a Foo?';
is $a, Int, 'did we get Int';
test-access(1,0,0);

$a = 666;
is $a, 666, 'did we get 666';
test-access(0,1,0);

++$a;
is $a, 667, 'did we get 667';
test-access(0,1,0);

# vim: ft=perl6 expandtab sw=4
