NAME
====

tie - Implement Perl 5's tie() built-in

SYNOPSIS
========

    use tie; # exports tie multi sub

    tie my $a, Tie::Foo;
    tie my @a, Tie::Bar;
    tie my %h, Tie::Baz;

DESCRIPTION
===========

This module tries to mimic the behaviour of the `tie` of Perl 5 as closely as possible. Please note that there are usually better ways attaching special functionality to arrays, hashes and scalars in Perl 6 than using `tie`. Please see the documentation on [Custom Types](https://docs.perl6.org/language/subscripts#Custom_types) for more information to handling the needs that Perl 5's `tie` fulfills in a more efficient way in Perl 6.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

