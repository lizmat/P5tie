use v6.c;
use Test;
use P5tie;

plan 7;

my int $tiearrayed;
my int $fetched;
my int $stored;
my int $fetchsized;
my int $storesized;
my int $extended;
my int $existed;
my int $deleted;
my int $cleared;
my int $pushed;
my int $popped;
my int $shifted;
my int $unshifted;
my int $spliced;
my int $untied;
my int $tested;

sub test-access(
  int :$tiearray;
  int :$store;
  int :$fetchsize;
  int :$storesize;
  int :$extend;
  int :$exists;
  int :$delete;
  int :$clear;
  int :$push;
  int :$popp;
  int :$shift;
  int :$unshift;
  int :$splic;
  int :$untie;
) {
    subtest {
        plan 4;
        is $tiearrayed, $tiearray, 
          "did we {"NOT " unless $$tiearray}see a TIEARRAY?";
        ok $fetched > 1, 
          'did we see at least one FETCH?';
        is $stored, $store,
          "did we {"NOT " unless $stored}see a STORE?";
        is $untied, $untie,
          "did we {"NOT " unless $untied}see an UNTIE?";
        $tiearrayed = $fetched = $stored    = $fetchsized = $storesized =
          $extended = $existed = $deleted   = $cleared    = $pushed     =
          $popped   = $shifted = $unshifted = $spliced    = $untied     = 0;
    }, "test accesses #{++$tested} of tied array";
}

class Foo {
    has Int @.tied;

    our method TIEARRAY() is raw {
        ++$tiearrayed;
        self.new
    }
    our method FETCH($index) is raw {
        ++$fetched;
        @!tied.AT-POS($index)
    }
    our method STORE($index,\value) is raw {
        ++$stored;
        @!tied.ASSIGN-POS($index,value)
    }
    our method FETCHSIZE() {
        ++$fetchsized;
        @!tied.elems
    }
    our method STORESIZE(\value) {
        ++$storesized;
        die
    }
    our method EXTEND(\value) {
        ++$extended;
        die
    }    
    our method EXISTS($index) {
        ++$existed;
        @!tied.EXISTS-POS($index)
    }
    our method DELETE($index) {
        ++$deleted;
        @!tied.DELETE-POS($index)
    }
    our method CLEAR() {
        ++$cleared;
        @!tied = ()
    }
    our method PUSH(\value) is raw {
        ++$pushed;
        @!tied.push(value)
    }
    our method POP() is raw {
        ++$popped;
        @!tied.pop
    }
    our method SHIFT() is raw {
        ++$shifted;
        @!tied.shift
    }
    our method UNSHIFT(\value) is raw {
        ++$unshifted;
        @!tied.unshift(value)
    }
    our method SPLICE(*@args) {
        ++$spliced;
        @!tied.splice(|@args)
    }
    our method UNTIE() is raw {
        ++$untied;
        @!tied
    } 
    our method DESTROY() { }
}

my $object = tie my @a, Foo;
dd $object, @a;
isa-ok $object, Foo, 'is the object a Foo?';
is @a[0], Int, 'did we get Int';
test-access(:1tiearray);

@a[0] = 666;
is @a[0], 666, 'did we get 666';
test-access(:1store);

++@a[0];
is @a[0], 667, 'did we get 667';
test-access(:1store);

# vim: ft=perl6 expandtab sw=4
