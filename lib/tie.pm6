use v6.c;
unit module tie:ver<0.0.1>;

sub tie(\subject, $class, *@extra is raw) is export {

    role tied  {
        has $.tied;
        method untie() {
            if ::($!tied.^name ~ '::&UNTIE') -> &untie {
                untie(self)
            }
        }
    }

    if ::($class ~ '::&TIESCALAR') -> &tiescalar {
        my \this  := tiescalar($class,|@extra);
        my &fetch := ::($class ~ '::&FETCH');
        my &store := ::($class ~ '::&STORE');

        subject = Proxy.new(
          FETCH => -> $         { fetch(this) },
          STORE => -> $, \value { store(this,value); fetch(this) }
        ) does tied(this);

        this
    }
}

sub untie(\this) is export { this.untie }

=begin pod

=head1 NAME

tie - Implement Perl 5's tie() built-in

=head1 SYNOPSIS

  use tie; # exports tie multi sub

  tie my $a, Tie::Foo;
  tie my @a, Tie::Bar;
  tie my %h, Tie::Baz;

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
