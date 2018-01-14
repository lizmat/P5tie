use v6.c;
unit module P5tie:ver<0.0.1>;  # must be different from "tie"

sub tie(\subject, $what, *@extra is raw) is export {

    # for providing tied / untied logic
    role tied  {
        has $.tied is rw;
        method untie() {
            if ::($!tied.^name ~ '::&UNTIE') -> &untie {
                untie(self)
            }
        }
    }

    # normalize to string and type object
    my $name   = $what ~~ Str ?? $what !! $what.^name;
    my $class  = ::($name);
    my $stash := $class.WHO;

    sub check($method, :$test) is raw {
        if $stash{'&' ~ $method} // $class.can($method)[0] -> &code {
            &code
        }
        elsif $test {
            Nil
        }
        else {
            die "Could not find '$method' in '$name'";
        }
    }

    # handle tieing a scalar
    if check('TIESCALAR', :test) -> &tiescalar {
        my \this    := tiescalar($class, |@extra);
        my &fetch   := check('FETCH');
        my &store   := check('STORE');
        my &untie   := check('UNTIE');
        my &destroy := check('DESTROY');

        # This is a bit fragile, but the only way to bind the replace the
        # original container given by the Proxy that we need to actually
        # get the tied behaviour.
        CALLER::CALLER::.BIND-KEY(subject.VAR.name,Proxy.new(
          FETCH => -> $       { fetch(this)                  },
          STORE => -> $, \val { store(this,val); fetch(this) }
        ));

        this
    }

    # handle tieing an array
    elsif check('TIEARRAY', :test) -> &tiearray {
        my \this := tiearray($class, |@extra);

        my class TiedArray does Iterable {
            has $.tied;
            has &!FETCH;
            has &!STORE;
            has &!FETCHSIZE;
            has &!STORESIZE;
            has &!EXTEND;
            has &!EXISTS;
            has &!DELETE;
            has &!CLEAR;
            has &!PUSH;
            has &!POP;
            has &!SHIFT;
            has &!UNSHIFT;
            has &!SPLICE;
            has &!UNTIE;
            has &!DESTROY;

            method new(\tied,\name) { self.CREATE!SET-SELF(tied,name) }
            method !SET-SELF($!tied,$name) {
                &!FETCH     := check('FETCH');
                &!STORE     := check('STORE');
                &!FETCHSIZE := check('FETCHSIZE');
                &!STORESIZE := check('STORESIZE');
                &!EXTEND    := check('EXTEND');
                &!EXISTS    := check('EXISTS');
                &!DELETE    := check('DELETE');
                &!CLEAR     := check('CLEAR');
                &!PUSH      := check('PUSH');
                &!POP       := check('POP');
                &!SHIFT     := check('SHIFT');
                &!UNSHIFT   := check('UNSHIFT');
                &!SPLICE    := check('SPLICE');
                &!UNTIE     := check('UNTIE');
                &!DESTROY   := check('DESTROY');
                self
            }

            method AT-POS($index) is raw {
                Proxy.new(
                  FETCH => -> $       { &!FETCH($!tied,$index)     },
                  STORE => -> $, \val { &!STORE($!tied,$index,val) }
                )
            }
            method ASSIGN-POS($index,\value) is raw {
                &!STORE($!tied,$index,value)
            }
            method BIND-POS($) {
                die "Cannot bind to tied Array, as Perl 5 doesn't know binding"
            }
            method EXISTS-POS($index) { &!EXISTS($!tied,$index) }
            method DELETE-POS($index) { &!DELETE($!tied,$index) }

            method elems()               { &!FETCHSIZE($!tied)     }
            method push(\value)          { &!PUSH($!tied,value)    }
            method pop()                 { &!POP($!tied)           }
            method shift()               { &!SHIFT($!tied)         }
            method unshift(\value)       { &!UNSHIFT($!tied,value) }
            method splice(*@args is raw) { &!SPLICE($!tied,|@args) }

            method STORE(*@args) {
                &!CLEAR($!tied);
                for @args.kv -> $index, \value {
                    &!STORE($!tied,$index,value)
                }
            }

            method iterator() {
                class :: does Iterator {
                    has $!tied;
                    has &!FETCH;
                    has &!STORE;
                    has int $!elems;
                    has int $!index;

                    method new(\t,\fe,\st,\el) { self.CREATE!SET-SELF(t,fe,st,el) }
                    method !SET-SELF($!tied,&!FETCH,&!STORE,$!elems) {
                        $!index = -1;
                        self
                    }

                    method pull-one() is raw {
                        ++$!index < $!elems
                          ?? Proxy.new(
                               FETCH => -> $       { &!FETCH($!tied,$!index)     },
                               STORE => -> $, \val { &!STORE($!tied,$!index,val) }
                             )
                          !! IterationEnd
                    }
                }.new($!tied,&!FETCH,&!STORE,&!FETCHSIZE(self))
            }

            method untie() { ::($!tied.^name ~ '::&UNTIE')($!tied) }
        }

        # This is a bit fragile, but the only way to bind the replace the
        # original container given by the object that we need to actually
        # get the tied behaviour.
        CALLER::CALLER::.BIND-KEY(subject.VAR.name,TiedArray.new(this,$name));

        this
    }

    # handle tieing a hash
    elsif check('TIEHASH', :test) -> &tiehash {
        my \this := tiehash($class, |@extra);

        my class TiedHash does Associative {
            has $.tied;
            has &!FETCH;
            has &!STORE;
            has &!DELETE;
            has &!CLEAR;
            has &!EXISTS;
            has &!FIRSTKEY;
            has &!NEXTKEY;
            has &!SCALAR;
            has &!UNTIE;
            has &!DESTROY;

            method new(\tied,\name) { self.CREATE!SET-SELF(tied,name) }
            method !SET-SELF($!tied,$name) {
                &!FETCH     := check('FETCH');
                &!STORE     := check('STORE');
                &!DELETE    := check('DELETE');
                &!CLEAR     := check('CLEAR');
                &!EXISTS    := check('EXISTS');
                &!FIRSTKEY  := check('FIRSTKEY');
                &!NEXTKEY   := check('NEXTKEY');
                &!SCALAR    := check('SCALAR');
                &!UNTIE     := check('UNTIE');
                &!DESTROY   := check('DESTROY');
                self
            }

            method AT-KEY($key) is raw {
                Proxy.new(
                  FETCH => -> $       { &!FETCH($!tied,$key)     },
                  STORE => -> $, \val { &!STORE($!tied,$key,val) }
                )
            }
            method ASSIGN-KEY($key,\value) is raw { &!STORE($!tied,$key,value) }
            method BIND-KEY($) {
                die "Cannot bind to tied Hash, as Perl 5 doesn't know binding"
            }
            method DELETE-KEY($key) { &!DELETE($!tied,$key) }
            method EXISTS-KEY($key) { &!EXISTS($!tied,$key) }

            method elems()          { die }

            method STORE(*@args) {
                &!CLEAR($!tied);
                for @args -> $key, \value {
                    &!STORE($!tied,$key,value)
                }
            }

            method iterator(
              &mapper = -> \key { Pair.new(key,$!tied.AT-KEY(key)) }
            ) {
                class :: does Iterator {
                    has $!tied;
                    has &!FIRSTKEY;
                    has &!NEXTKEY;
                    has &!mapper;
                    has Mu $!lastkey;

                    method new(\t,\fk,\nk,\ma) { self.CREATE!SET-SELF(t,fk,nk,ma) }
                    method !SET-SELF($!tied,&!FIRSTKEY,&!NEXTKEY,&!mapper) { self }

                    method pull-one() is raw {
                        if $!lastkey =:= Mu {       # first time
                            with $!lastkey := &!FIRSTKEY($!tied) {
                                &!mapper($_)
                            }
                            else {                  # empty hash
                                IterationEnd
                            }
                        }
                        elsif $!lastkey.defined {   # consecutive time
                            with $!lastkey := &!NEXTKEY($!tied,$!lastkey) {
                                &!mapper($_)
                            }
                            else {                  # exhausted now
                                IterationEnd
                            }
                        }
                        else {                      # exhausted before
                            IterationEnd
                        }
                    }
                }.new($!tied,&!FIRSTKEY,&!NEXTKEY,&mapper)
            }

            method pairs()  { Seq.new(self.iterator) }
            method keys()   { Seq.new(self.iterator( { $_ } )) }
            method values() { Seq.new(self.iterator( { self.AT-KEY($_) } )) }
            method antipairs() {
                Seq.new(self.iterator( { Pair.new(self.AT-KEY($_),$_) } ))
            }

            method untie() { ::($!tied.^name ~ '::&UNTIE')($!tied) }
        }

        # This is a bit fragile, but the only way to bind the replace the
        # original container given by the object that we need to actually
        # get the tied behaviour.
        CALLER::CALLER::.BIND-KEY(subject.VAR.name,TiedHash.new(this,$name));

        this
    }

    # sorry
    else {
        X::NYI.new( feature => "other types of tie" ).throw
    }
}

sub tied(\this)  is export { this.tied }
sub untie(\this) is export { this.untie }

=begin pod

=head1 NAME

P5tie - Implement Perl 5's tie() built-in

=head1 SYNOPSIS

  use P5tie; # exports tie(), tied() and untie()

  tie my $s, Tie::AsScalar;
  tie my $a, Tie::AsArray;
  tie my $h, Tie::AsHash;

  $object = tied $s;
  untie $s;

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<tie> of Perl 5 as closely as
possible.  Please note that there are usually better ways attaching special
functionality to arrays, hashes and scalars in Perl 6 than using C<tie>.  Please
see the documentation on
L<Custom Types|https://docs.perl6.org/language/subscripts#Custom_types> for more
information to handling the needs that Perl 5's C<tie> fulfills in a more
efficient way in Perl 6.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5tie . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
