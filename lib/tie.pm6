use v6.c;
unit module P5tie:ver<0.0.1>;  # must be different from "tie"

sub tie(\subject, $what, *@extra is raw) is export {

    # for providing tied / untied logic
    role tied  {
        has $.tied;
        method untie() {
            if ::($!tied.^name ~ '::&UNTIE') -> &untie {
                untie(self)
            }
        }
    }

    # normalize to string and type object
    my $name  = $what ~~ Str ?? $what !! $what.^name;
    my $class = ::($name);

    # handle tieing a scalar
    if ::($name ~ '::&TIESCALAR') -> &tiescalar {
        my \this  := tiescalar($class, |@extra);
        my &fetch := ::($name ~ '::&FETCH');
        my &store := ::($name ~ '::&STORE');

        subject = Proxy.new(
          FETCH => -> $ {
              with fetch(this) { $_   } # already have an instance
              else             { .new } # need instance for "does"
          },
          STORE => -> $, \val { store(this,val); fetch(this) }
        ) does tied(this);

        this
    }

    # sprry
    else {
        X::NYI.throw( feature => "other types of tie" )
    }
}

sub tied(\this)  is export { this.tied }
sub untie(\this) is export { this.untie }

=begin pod

=head1 NAME

tie - Implement Perl 5's tie() built-in

=head1 SYNOPSIS

  use tie; # exports tie(), tied() and untie()

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

Source can be located at: https://github.com/lizmat/tie . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
