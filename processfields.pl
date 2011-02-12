#!/usr/local/bin/perl                                                                                                                                                                                     

#===============================================================================
#
#         FILE:  processfields.pl
#
#        USAGE:  ./processfields.pl
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
#      CREATED:  Sat Jan 29 14:35:00 2011
#     REVISION:  ---
#===============================================================================
$range = $ARGV[0];
$append = $ARGV[1];
my @fields = ();
my ($line1,$line2) = ();
my $count = 0;
my $line;
while( $line = <STDIN>){
    chomp($line);
    next if($line =~ /^\s*[+|-]+\s*$/);
    $count++;
    last if ($count == 3 );;
    $line1 = $line if($count == 1);
    $line2 = $line if($count == 2);
}

$delim = findDelim($line1,$line2);

push @fields ,[  map { $_=~ /[a-zA-Z]/ ? $_=~/NULL/i ? "\"\"":"\"$_\"" : "$_" } split(/$delim/,$line1)  ] ;
push @fields ,[  map { $_=~ /[a-zA-Z]/ ? $_=~/NULL/i ? "\"\"":"\"$_\"" : "$_" } split(/$delim/,$line2)  ] ;
push @fields ,[  map { $_=~ /[a-zA-Z]/ ? $_=~/NULL/i ? "\"\"":"\"$_\"" : "$_" } split(/$delim/,$line)  ] ;

while( $line = <STDIN>){
    chomp($line);
    next if($line =~ /^\s*[+|-]+\s*$/);
    push @fields ,[  map { $_=~ /[a-zA-Z]/ ? $_=~/NULL/i ? "\"\"":"\"$_\"" : "$_" } split(/$delim/,$line)  ] ;
}

sub findDelim {
    my ( $l1, $l2 ) = @_;
    my @f1 = split(/\s*\|\s*/,$l1);
    my @f2 = split(/\s*\|\s*/,$l2);
    if( $#f1 > 0 && ( $#f1 == $#f2) ){
        return "\\s*\\|\\s*";
    }
    my @f1 = split(/\s*,\s*/,$l1);
    my @f2 = split(/\s*,\s*/,$l2);
    if( $#f1 > 0 && ( $#f1 == $#f2) ){
        return "\\s*,\\s*";
    }
    my @f1 = split(/\t/,$l1);
    my @f2 = split(/\t/,$l2);
    if( $#f1 > 0 && ( $#f1 == $#f2) ){
        return "\\t";
    }

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
my @requiredFields = processRange($range);
#print "\n@requiredFields\n";
foreach my $farray ( @fields ) {
    print "$append ";
    for(my $index = 1; $index <= $#{@$farray}; $index++) {
        my $flag = 0;
        $comma = ",";
        $comma = "" if($index == $#{@$farray}); 
        if($requiredFields[0] eq "all" || $requiredFields[0] == 0 ){
            if(isnumeric($farray->[$index])){
                printf("%$widths[$index-1]s$comma ","$farray->[$index]");
            }else{
                if("$farray->[$index]" eq "\"\""){
                    my $tmpwidth = $widths[$index-1];
#print "\nWidth:$tmpwidth\n";
                    printf("%-${tmpwidth}s$comma ","$farray->[$index]");
                }else{
                        printf("%-$widths[$index-1]s$comma ","$farray->[$index]");
                }
            }
        }else{
            my $i = 0;
            foreach my $fld ( @requiredFields ){
                my $tfld = int($fld);
                $i++;
                if($tfld == $index){
#print "\n$tfld:$index:$i\n";
                    $flag = 1;
                    last;
                }
            }
            if($flag == 1){
                $comma = "" if($index == $requiredFields[$#requiredFields]);
                $i--;
                if(isnumeric($farray->[$index])){
                    printf("%$widths[$index-1]s$comma ","$farray->[$index]");
                }else{
                    if($requiredFields[$i]=~/\./){
                        my $req=$requiredFields[$i];
                        @req = split(/\s*\.\s*/,$req);
                        my ($from,$to) = (1,0);
                        $from = int($req[1])-1;
                        $to = int($req[2]) if(defined($req[2]) && $req[2]=~/\d+/);
                        if($to){
                            $from++;;
                        }
                        if(! $to){
                            $to=$from+1;
                            $from=1;
                        }
                        
#print "\nFrom:$from To:$to\n";
                        $widths[$index-1] = $to;
                            if("$farray->[$index]" eq "\"\""){
                                my $tmpwidth = $widths[$index-1]+1;
                                printf("%-${tmpwidth}s$comma ",$farray->[$index]);
                            }else{
                                if($from){
                                    if( ($from+$to) >= length($farray->[$index])){
                                        if($from > 1){
                                            printf("\"%-$widths[$index-1]s $comma ",substr($farray->[$index],$from,$to));
                                        }else{
                                            printf("\"%-$widths[$index-1]s $comma ",substr($farray->[$index],$from+1,$to));
                                        }
                                    }else{
#print "$from+$to :$farray->[$index]: ".length($farray->[$index])."\n";
                                        printf("\"%-$widths[$index-1]s$comma ",substr($farray->[$index],$from,$to)."\"");
                                    }
                                }else{
                                    printf("\"%-$widths[$index-1]s$comma ",substr($farray->[$index],$from,$to)."\"");
                                }
                            }
                    }else{
                        if("$farray->[$index]" eq "\"\""){
                            printf("%-$widths[$index-1]s$comma ","$farray->[$index]");
                        }else{
                            printf("%-$widths[$index-1]s$comma ","$farray->[$index]");
                        }
                    }
                }
            }
        }
    }
    print " );\n";
}

#my $index = 0;
#foreach(@widths) {
#    print("$widths[$index++], ") if($widths[$index]);
#}

sub isnumeric {
    return $_[0] =~ /^\s*[0-9.]+\s*$/;
}

sub processRange {
    my ($rangeStr) = @_;
    my @range = ();
    if($rangeStr =~ /^\s*$/){
        $range[0]="all";
        return(@range);
    }
    my @rf = split(/\s*,\s*/,$rangeStr);
    foreach my $fld ( @rf ){
        if($fld=~/^\s*\d+\s*$/){
            push @range , int($fld);
            next;
        }
        if($fld=~/^\s*\d+\.\d+(?:\.\d+)?\s*$/){
            push @range , $fld;
            next;
        }
        if($fld=~/-/){
            my ($start,$end) = split(/\s*-\s*/,$fld);
            
            push @range , $_ foreach ( $start..$end );;
            next;
        }
    }
    return(@range);
}
