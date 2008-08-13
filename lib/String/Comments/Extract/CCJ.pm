package String::Comments::Extract::CCJ;

use strict;
use warnings;

use String::Comments::Extract;

sub extract_comments {
    my $self = shift;
    my $input = shift;
    return String::Comments::Extract::_ccj_extract_comments($input);
}

1;
