# perl script to summarize all the Phylonet outputs
# inside the phylonet folder
# it calls summarizeOutputPhylonetPath.pl
# Claudia April 2015

@subfolder = `find phylonet -type d`;
shift @subfolder;

foreach(@subfolder){
    system("perl summarizeOutputPhylonetPath.pl path=$_");
}
