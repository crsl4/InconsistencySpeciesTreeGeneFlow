# created to summarize *njst.out files
# Claudia January 2016

$path = 'njst/gamma0.1_n10';

foreach(@ARGV){
    if (/\bpath\s*=\s*(.+)/i){$path = $1; }
}

$where = $path."/*njst.out";

@files = `ls $where`;
$outputfile = $path."/estTrees.out";
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
