# perl script to calculate distances of estimated trees
# to true trees in all subfolders
# inside the NJst folder
# it calls PhylonetSymmDistNJst.pl
# Claudia July 2015



@subfolder = `find njst -type d`;
shift @subfolder;

foreach(@subfolder){
    system("perl PhylonetSymmDistNJst.pl path=$_");
}
