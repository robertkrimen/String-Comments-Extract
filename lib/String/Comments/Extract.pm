package String::Comments::Extract;

use warnings;
use strict;

=head1 NAME

String::Comments::Extract - Extract comments from C/C++/JavaScript/Java source

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

require Exporter;
require DynaLoader;

our @ISA = qw/Exporter DynaLoader/;
our @EXPORT_OK = qw//;

bootstrap String::Comments::Extract $VERSION;

use String::Comments::Extract::SlashStar;
use String::Comments::Extract::C;
use String::Comments::Extract::CPP;
use String::Comments::Extract::JavaScript;
use String::Comments::Extract::Java;

=head1 SYNOPSIS

    use String::Comments::Extract;

    my $source = <<_END_
    /* A Hello World program
    
        Copyright Ty Coon
        // ...and Buckaroo Banzai
      "Yoyodyne"*/

    void main() {
        printf("Hello, World.\n");
        printf("/* This is not a real comment */");
        printf("// Neither is this */");
        // But this is
    }

    // Last comment
    _END_

    my $comments = String::Comments::Extract::C->extract($source)
    # ... returns the following result:

        /* A Hello World program
        
            Copyright Ty Coon
            // ...and Buckaroo Banzai
          "Yoyodyne"*/

          
            
            
            
            // But this is
        

        // Last comment

    my @comments = String::Comments::Extract::C->collect($source)
    # ... returns the following list:
        (
' A Hello World program
    
        Copyright Ty Coon
        // ...and Buckaroo Banzai
      "Yoyodyne"',
            ' But this is',
            ' Last comment',
        )

=head1 DESCRIPTION

String::Comments::Extract is a tool for extracting comments from C/C++/JavaScript/Java source. The extractor
is implemented using an actual tokenizer (written in C via XS [adapted from L<JavaScript::Minifier::XS>]). By using
a tokenizer, it can correctly deal with notoriously problematic cases, such as comment-like structures embedded in strings:

    std::cout << "This is not a // real C++ comment " << std::endl
    printf("/* This is not a real C comment */\n");
    # The extractor will ignore both of the above

String::Comments::Extract considers C/C++/JavaScript/Java comment structures the same, so, for now, it doesn't really
matter which method you use (this means it will not complain about C++ style comments in C source).

The language agnostic interface to C/C++/JavaScript/Java comment extractor is accessible via String::Comments::Extract::SlashStar

    # Can handle slash-star (/* */) and slash-slash (//) comments
    String::Comments::Extract::SlashStar->extract
    String::Comments::Extract::SlashStar->collect

=head1 METHODS

=head2 String::Comments::Extract::JavaScript->extract( <source> )

=head2 String::Comments::Extract::CPP->extract( <source> )

=head2 String::Comments::Extract::C->extract( <source> )

=head2 String::Comments::Extract::SlashStar->extract( <source> )

Returns a string representing the comments in <source>

Comment delimeters ( C</* */ //> ) are left in as-is

Whitespace of <source> is otherwise preserved, so you'll probably have to do some post-processing to get rid of some cruft.

=head2 String::Comments::Extract::JavaScript->collect( <source> )

=head2 String::Comments::Extract::CPP->collect( <source> )

=head2 String::Comments::Extract::C->collect( <source> )

=head2 String::Comments::Extract::SlashStar->collect( <source> )

Returns a list containing an item for each block- or line-comment in <source>

Comment delimeters ( C</* */ //> ) around the comment are removed

Whitespace outside of comments may not be preserved exactly

=head1 SEE ALSO

L<File::Comments>

=cut

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 SOURCE

You can contribute or fork this project via GitHub:

L<http://github.com/robertkrimen/string-comments-extract/tree/master>

    git clone git://github.com/robertkrimen/string-comments-extract.git PACKAGE

=head1 BUGS

Please report any bugs or feature requests to C<bug-string-comments-extract at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=String-Comments-Extract>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc String::Comments::Extract


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=String-Comments-Extract>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/String-Comments-Extract>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/String-Comments-Extract>

=item * Search CPAN

L<http://search.cpan.org/dist/String-Comments-Extract>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of String::Comments::Extract
