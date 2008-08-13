package String::Comments::Extract;

use warnings;
use strict;

=head1 NAME

String::Comments::Extract - Extract comments from C, C++, and JavaScript

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

require Exporter;
require DynaLoader;

our @ISA = qw/Exporter DynaLoader/;
our @EXPORT_OK = qw//;

bootstrap String::Comments::Extract $VERSION;

=head1 SYNOPSIS

    use String::Comments::Extract::CPP;

    my $source = <<_END_;
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

    my $comments = String::Comments::Extract::C->extract_comments($source);
    # ... returns the following result:

        /* A Hello World program
        
            Copyright Ty Coon
            // ...and Buckaroo Banzai
          "Yoyodyne"*/

          
            
            
            
            // But this is
        

        // Last comment

    my @comments = String::Comments::Extract::C->collect_comments($source);
    # ... returns the following list:
        (
            <<_END_,
 A Hello World program
    
        Copyright Ty Coon
        // ...and Buckaroo Banzai
      "Yoyodyne"
_END_
            ' But this is',
            ' Last comment',
        )

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

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
