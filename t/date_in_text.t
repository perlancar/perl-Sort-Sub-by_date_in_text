#!perl

use 5.010;
use strict;
use warnings;

use Test::More 0.98;
use Test::Sort::Sub;

sort_sub_ok(
    subname   => 'date_in_text',
    input     => [
        'no date',
        'date: 3 Jan 2016',
        'date: 1 Feb 2016',
        'date2: 1 Feb 2016',
        'date: 2 Dec 1999',
    ],
    output    => [
        'date: 2 Dec 1999',
        'date: 3 Jan 2016',
        'date: 1 Feb 2016',
        'date2: 1 Feb 2016',
        'no date',
    ],
);

done_testing;
