[![Build Status](https://travis-ci.org/lizmat/P5tie.svg?branch=master)](https://travis-ci.org/lizmat/P5tie)

NAME
====

P5tie - Implement Perl 5's tie() built-in

SYNOPSIS
========

    use P5tie; # exports tie(), tied() and untie()

    tie my $s, Tie::AsScalar;
    tie my $a, Tie::AsArray;
    tie my $h, Tie::AsHash;

    $object = tied $s;
    untie $s;

DESCRIPTION
===========

This module tries to mimic the behaviour of the `tie` of Perl 5 as closely as possible. Please note that there are usually better ways attaching special functionality to arrays, hashes and scalars in Perl 6 than using `tie`. Please see the documentation on [Custom Types](https://docs.perl6.org/language/subscripts#Custom_types) for more information to handling the needs that Perl 5's `tie` fulfills in a more efficient way in Perl 6.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5tie . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

