#!/usr/local/bin/perl
use Data::Dumper;
my %maxSize;
my %datatypes;
my $fcount=0;
my @rows;
my $numRegex = qr/^\s*\d+(?:\.\d+)?\s*$/o;
my $l1,$l2;
while( <STDIN> ){
    next if( /^\s*$/ );
    chomp;
    $l1=$_;
    push @rows,$_;
    last;
}

$delim = qr/\s*\|\s*/;
$delim = qr/\s*,\s*/;
my $lcount = 0;
while(<STDIN>)
{
    chomp;
    next if( /^\s*$/ );
    push @rows,$_;
    if ( $lcount == 0 ){
        $l2=$_ ;
        $delim = findDelim( $l1,$l2 );
        my @fields=split($delim,$l1);
        $fcount=$#fields;
        for my $i(0..$#fields)
        {
            my $len=length($fields[$i]);
            $maxSize{$i}=$len if($len > $maxSize{$i});
        }
    }
    $lcount++;
    @fields=split($delim,$_);
    for my $i(0..$#fields)
    {
        my $len=length($fields[$i]);
        $maxSize{$i}=$len if($len > $maxSize{$i});
        if( isnumeric( $fields[ $i ] ) && defined( $datatypes{ $i } ) && $datatype{ $i } ne 'str'  ) {
            $datatypes{ $i } = 'int';
        }else{
            $datatypes{ $i } = 'str' ;
        }
    }
}
#print Dumper( %maxSize );
#close(FH);
$fmstr="| ";
my $sepLine="+";
for my $i(0..$#fields)
{
    if( $datatypes{ $i }  eq 'int'  ){
        $fmstr.="%+$maxSize{$i}s | ";
    }else{
        $fmstr.="%-$maxSize{$i}s | ";
    }
    if( $i == 0 ) {
        $sepLine.=('-' x $maxSize{$i} ).'---+';
        next;
    }
    if( $i == $#fields ) {
        $sepLine.=('-' x $maxSize{$i} ).'-+';
        last;
    }
    $sepLine.=('-' x $maxSize{$i} ).'-+-';
}

#print findDelim( $l1,$l2 );
#print $fmstr."\n";
#print Dumper( %datatypes ) ;
if( $ARGV[ 0 ] =~ /html/i){
    htmlTable( @rows ) ;
}else{
    asciiTable( $ARGV[ 1],@rows ) ;
}


sub asciiTable {
    my  ( $everyRow, @rows ) = @_;
    $count=0;
    my $preSpace=" ";
    print "$preSpace$sepLine\n";
    foreach (@rows)
    {
        if($count==1)
        {
            print "$preSpace$sepLine\n";
        }
        #print "$preSpace$sepLine\n" if $count > 1;
        printf("%s$fmstr",$preSpace,split($delim,$_));
        print "\n";
        print "$preSpace$sepLine\n" if ( $everyRow && $count>0);
        $count++;
    }
    print "$preSpace$sepLine\n" if ! $everyRow;
}


#------------------------------------------------------------
# Function Name : htmlTable 
# Purpose       :  
# Arguments     : --- 
# Returns       : --- 
#------------------------------------------------------------
sub htmlTable {
    my  @rows = @_;
    $count=0;
    my $preSpace="      ";
    print "<table>\n";
    foreach my $r (@rows)
    {
        my $row = "";
        if($count==0)
        {
            print "\t<tr>\n";
            map { $row.="\t\t<th>$_</th>\n" } split( $delim,$r);
            print "$row\t</tr>\n";
            $count++;
            next;
        }
        print "\t<tr>\n";
        my $findex = 0;
        map { $row.="\t\t<td".( ($datatypes{$findex} eq 'int' ) ? " align='right' ":" align='left' " ).">$_</td>\n";$findex++; } split( $delim,$r);
        print "$row\t</tr>\n";
        $count++;
    }
    print "</table>\n"

}


#------------------------------------------------------------
# Function Name : isnumeric 
# Purpose       :  
# Arguments     : --- 
# Returns       : --- 
#------------------------------------------------------------
sub isnumeric {
    my (  $num ) = @_;
    if($num =~ $numRegex ) {
        return 1;
    }
    return 0;
}


#------------------------------------------------------------
# Function Name : findDelim 
# Purpose       :  
# Arguments     : --- 
# Returns       : --- 
#------------------------------------------------------------
sub findDelim {
    my ( $l1, $l2 ) = @_;
    my $delims = ();
    my @f1 = split(/\s*\|\s*/,$l1);
    my @f2 = split(/\s*\|\s*/,$l2);
    if( $#f1 > 0 && ( $#f1 == $#f2) ){
        $delims[ 0 ] = [ $#f1,"\\s*\\|\\s*" ];
        #return "\\s*\\|\\s*";
    }
    my @f1 = split(/\s*,\s*/,$l1);
    my @f2 = split(/\s*,\s*/,$l2);
    if( $#f1 > 0 && ( $#f1 == $#f2) ){
        $delims[ 1 ] = [ $#f1,"\\s*,\\s*" ];
        #return "\\s*,\\s*";
    }
    my @f1 = split(/\t/,$l1);
    my @f2 = split(/\t/,$l2);
    if( $#f1 > 0 && ( $#f1 == $#f2) ){
        $delims[ 2 ] = [ $#f1,"\\t" ];
        #return "\\t";
    }
    if( $delims[ 0 ][ 0 ] >= $delims[ 1 ][ 0 ]){
        $max = $delims[ 0 ][ 0 ];
        $delim=$delims[ 0 ][ 1 ];
    }else{
        $delim=$delims[ 1 ][ 1 ];
        $max = $delims[ 1 ][ 0 ];
    }
    if( $max <= $delims[ 2 ][ 0 ]){
        $delim=$delims[ 2 ][ 1 ];
    }
    return $delim;
}

