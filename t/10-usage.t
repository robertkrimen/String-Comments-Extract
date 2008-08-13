#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

use String::Comments::Extract;

my $source = <<_END_;
    /* A Hello World program
    
        Copyright Ty Coon
        // ...and Buckaroo Banzai
      "Yoyodyne"*/

    void main() {
        printf("Hello, World.\\n");
        printf("/* This is not a real comment */");
        printf("// Neither is this */");
        // But this is
    }

    // Last comment
_END_
my $comments = String::Comments::Extract::C->extract($source);
is($comments, <<_END_);
    /* A Hello World program
    
        Copyright Ty Coon
        // ...and Buckaroo Banzai
      "Yoyodyne"*/

      
        
        
        
        // But this is
    

    // Last comment
_END_

my @comments = String::Comments::Extract::C->collect($source);
$comments[0] .= "\n";
cmp_deeply(\@comments, [
    <<_END_,
 A Hello World program
    
        Copyright Ty Coon
        // ...and Buckaroo Banzai
      "Yoyodyne"
_END_

    ' But this is',
    ' Last comment',
]);
