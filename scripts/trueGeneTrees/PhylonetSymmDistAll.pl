# perl script to calculate distances of estimated trees
# to true trees in all subfolders
# inside the phylonet folder
# it calls PhylonetSymmDist.pl
# Claudia April 2015

@subfolder = `find astral -type d`;
shift @subfolder;

foreach(@subfolder){
    system("perl PhylonetSymmDist.pl path=$_");
}
