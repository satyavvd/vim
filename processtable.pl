#!/usr/local/bin/perl                                                                                                                                                                                     

#===============================================================================
#
#         FILE:  processtable.pl
#
#        USAGE:  ./processtable.pl
#
#  DESCRIPTION:
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Satyanarayana - satyavvd@yahoo-inc.com
#      COMPANY:  Yahoo!
#      VERSION:  1.0
#      CREATED:  Fri Jan 21 15:25:37 2011
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use Data::Dumper;

my @fields = ();
while(my $line = <STDIN>){
    chomp($line);
    next if($line =~ /^\s*[+|-]+\s*$/);
    push @fields ,[  map { $_=~ /[a-zA-Z]/ ? $_=~/NULL/i ? "\"\"":"\"$_\"" : "$_" } split(/\s*\|\s*/,$line)  ] ;
}

#print Dumper(@fields);
my @widths = ();
$widths[$_]=0 foreach ( 0..100 );
foreach my $farray ( @fields ) {
    for(my $index = 1; $index <= $#{@$farray}; $index++) {
        my $len = length("$farray->[$index]");
        if($widths[$index-1] < $len ) {
            $widths[$index-1] = $len  ;
        }
    }
}
my $comma = ",";
foreach my $farray ( @fields ) {
    print "( ";
    for(my $index = 1; $index <= $#{@$farray}; $index++) {
        $comma = ",";
        $comma = "" if($index == $#{@$farray}); 
        if(isnumeric($farray->[$index])){
            printf("%$widths[$index-1]s$comma ","$farray->[$index]");
        }else{
            printf("%-$widths[$index-1]s$comma ","$farray->[$index]");
        }
    }
    print " ), \n";
}

my $index = 0;
foreach(@widths) {
    print("$widths[$index++], ") if($widths[$index]);
}

sub isnumeric {
    return $_[0] =~ /^\s*[0-9.]+\s*$/;
}
