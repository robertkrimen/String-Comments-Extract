package String::Comments::Extract::CPPCJS;

use strict;
use warnings;

use String::Comments::Extract;

sub extract_comments {
    my $self = shift;
    my $input = shift;
    return String::Comments::Extract::_cppcjs_extract_comments($input);
}

sub collect_comments {
    my $self = shift;
    my $input = shift;
    my @comments;
    my $comments = String::Comments::Extract::_cppcjs_extract_comments($input);
    while ($comments =~ m{/\*(.*?)\*/|//(.*?)$}msg) {
        next unless defined $1 || defined $2;
        push @comments, defined $1 ? $1 : $2;
    }
    return @comments;
}

1;
