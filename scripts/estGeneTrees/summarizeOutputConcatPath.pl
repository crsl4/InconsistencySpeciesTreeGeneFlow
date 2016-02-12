# perl script to make one output file from concatenation:
# RAxML_bestTree.*_raxml_concat
# Claudia January 2016

$path = 'raxml/gamma0.1_n10';

foreach(@ARGV){
    if (/\bpath\s*=\s*(.+)/i){$path = $1; }
}

$where = $path."/RAxML_bestTree.*_raxml_concat";

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
