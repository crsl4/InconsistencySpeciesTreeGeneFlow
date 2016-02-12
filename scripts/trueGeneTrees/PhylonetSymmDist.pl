# perl script to create nexus files and runs phylonet to calculate the distance 
# of the estimated trees on Astral and the true tree
# warning: need to match the true tree with the one that comes from the network used simulated the
# gene trees in ms in hgt.pl file
# warning: takes the name of file with list of estimated trees set in
# summarizeOutputPhylonetPath.pl, so need to run this first
# warning: the order of cmpnets files (1,2,...) does not necessarily match the 
# input files 1_astral,..., but it should if phylonet files starts in 1 and have no gaps
# Claudia April 2015

$truetree = "((((1,2),(3,4)),5),6);"; #warning: see up
$phylonet = '~/software/phylonet/PhyloNet_3.5.5.jar';
$path = 'astral/gamma0.1_n10';

foreach(@ARGV){
    if (/\bpath\s*=\s*([^\s]+)/i){$path = $1; }
    if (/\btruetree\s*=\s*([^\s]+)/i){$truetree = $1; }
}

$esttrees = $path."/estTrees.out"; #warning: see up
$listfiles = $path."/listFiles.out"; #warning: see up
$distances = $path."/distances.out";
open $FHest, "<$esttrees";
chomp(@trees = <$FHest>);
close $FHest;
open $FHlist, "<$listfiles";
chomp(@list = <$FHlist>);
close $FHlist;

open FHdist, ">$distances";
print FHdist "tree RFdist\n";
my $i = 0;
foreach(@trees){
    $cmpnetsnex = $path."/".$i."cmpnets.nex";
    $cmpnetsout = $path."/".$i."cmpnets.out";
    open FHnex, ">$cmpnetsnex";
    print FHnex "#NEXUS\n\nBEGIN NETWORKS;\n";
    print FHnex "Network tree1 = $_"; 
    print FHnex "\nNetwork tree2 = $truetree"; 
    print FHnex "\nEND;\n";
    print FHnex "\nBEGIN PHYLONET;\n";
    print FHnex "SymmetricDifference tree1 tree2;";
    print FHnex "\nEND;";
    close FHnex;
    system("java -jar $phylonet $cmpnetsnex > $cmpnetsout");
    @namefile = split('/',@list[$i]);
    open FHout, "<$cmpnetsout";
    while(<FHout>){
	if(/\bRF-Distance: (\d+\.\d+)/){print FHdist "@namefile[2] $1\n";}
    }
    close FHout;
    $i += 1;
}
close FHdist;
