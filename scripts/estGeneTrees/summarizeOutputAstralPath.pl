# perl script to make one output file from astral
# from one given path
# Claudia April 2015
# modified to consider bootstrap trees in ?_astral.out
# Claudia January 2016

$path = 'astral/gamma0.1_n10';

foreach(@ARGV){
    if (/\bpath\s*=\s*(.+)/i){$path = $1; }
}

$where = $path."/*astral.out";

@files = `ls $where`;
$outputfile = $path."/estTrees0.out";
$listfile = $path."/listFiles.out";
open FHout, ">$outputfile";
open FHlist, ">$listfile";
foreach(@files){
    open FHin, "<$_";
    print FHlist "$_";
    my $line = 1;
    while(<FHin>){
	if($line == 102){ #only print line #102
	    print FHout "$_";
	}
	$line++;
    }
    close FHin;
}
close FHlist;
close FHout;
