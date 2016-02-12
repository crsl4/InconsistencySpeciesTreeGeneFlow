# perl script to calculate distances of estimated networks
# to true network in all subfolders
# inside the phylonet folder
# it calls PhylonetCmpnets.pl
# Claudia April 2015

@subfolder = `find phylonet -type d`;
shift @subfolder;

foreach(@subfolder){
    system("perl PhylonetCmpnets.pl path=$_");
}
