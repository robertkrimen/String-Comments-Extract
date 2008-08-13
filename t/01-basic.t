#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

use String::Comments::Extract::CPPCJS;

my $input = <<_END_;
/* Here is a comment */

// Here is another comment

/* and another! */

#define I_AM_SPECIAL_LA_LA_LA

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

int main() {
    int *pointer;
    int cannot_actually_do_this_in_c(ha ha)
    char *string = "With \\"some escapes" //But get this one!
}

if (1) { // Comment after an "if"
    0;
}
else {
    malloc();
}

// A wacky "comment
// And another" one
_END_

diag(String::Comments::Extract::CPPCJS->extract_comments($input));
diag("Now for something different!");
diag(join "\n", String::Comments::Extract::CPPCJS->collect_comments($input));

ok(1);
