# perl script to make one output file from astral
# from one given path
# Claudia April 2015

$path = 'astral/gamma0.1_n10';

foreach(@ARGV){
    if (/\bpath\s*=\s*(.+)/i){$path = $1; }
}

$where = $path."/*astral.out";

@files = `ls $where`;
$outputfile = $path."/estTrees.out";
$listfile = $path."/listFiles.out";
open FHout, ">$outputfile";
open FHlist, ">$listfile";
foreach(@files){
    open FHin, "<$_";
    print FHlist "$_";
    while(<FHin>){
	print FHout "$_";	
    }
    close FHin;
}
close FHlist;
close FHout;
