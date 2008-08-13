#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

use String::Comments::Extract::CCJ;

my $input = <<_END_;
/* Here is a comment */

// Here is another comment

/* and another! */

// Here is a comment /* containing a comment */

"// This is not a comment "

if (1) {
    0;
}
else {
    malloc();
}
/* A multiline
    comment

    // With another comment inside

    "And a stringlike thing"
At the front
*/

div.bd {
    font-size: 88%;
}

if (1) {
    0;
}
else {
    malloc();
}
_END_

diag(String::Comments::Extract::CCJ->extract_comments($input));

ok(1);
