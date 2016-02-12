# perl script to create nexus files and runs phylonet to calculate the distance 
# of the estimated networks on Phylonet and the true network
# warning: need to match the true network with the one that simulated the
# gene trees in ms in hgt.pl file
# warning: takes the name of file with list of estimated networks set in
# summarizeOutputPhylonetPath.pl, so need to run this first
# Claudia April 2015

$truenetwork = "((((1,2),((3,4))#H1),(#H1,5)),6);"; #warning: see up
$phylonet = '~/software/phylonet/PhyloNet_3.5.5.jar';
$path = 'phylonet/gamma0.1_n10';
$measure = "cluster";

foreach(@ARGV){
    if (/\bpath\s*=\s*([^\s]+)/i){$path = $1; }
    if (/\bmeasure\s*=\s*([^\s]+)/i){$measure = $1; }
    if (/\btruenetwork\s*=\s*([^\s]+)/i){$truenetwork = $1; }
}

$estnetworks = $path."/estNetworks.out"; #warning: see up
$listfiles = $path."/listFiles.out"; #warning: see up
$distances = $path."/distances.out";
open $FHest, "<$estnetworks";
chomp(@trees = <$FHest>);
close $FHest;
open $FHlist, "<$listfiles";
chomp(@list = <$FHlist>);
close $FHlist;

open FHdist, ">$distances";
print FHdist "network dist1$measure dist2$measure dist3$measure\n";
my $i = 0;
foreach(@trees){
    $cmpnetsnex = $path."/".$i."cmpnets.nex";
    $cmpnetsout = $path."/".$i."cmpnets.out";
    open FHnex, ">$cmpnetsnex";
    print FHnex "#NEXUS\n\nBEGIN NETWORKS;\n";
    print FHnex "Network net1 = $_"; 
    print FHnex "\nNetwork net2 = $truenetwork"; 
    print FHnex "\nEND;\n";
    print FHnex "\nBEGIN PHYLONET;\n";
    print FHnex "Cmpnets net1 net2 -m $measure;";
    print FHnex "\nEND;";
    close FHnex;
    system("java -jar $phylonet $cmpnetsnex > $cmpnetsout");
    @namefile = split('/',@list[$i]);
    open FHout, "<$cmpnetsout";
    while(<FHout>){
	if(/\bnetworks: (\d+\.\d+\s\d+\.\d+\s\d+\.\d+)/){print FHdist "@namefile[2] $1\n";}
    }
    close FHout;
    $i += 1;
}
close FHdist;
