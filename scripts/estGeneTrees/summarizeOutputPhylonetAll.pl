# perl script to summarize all the Phylonet outputs
# inside the phylonet folder
# it calls summarizeOutputPhylonetPath.pl
# Claudia April 2015
# modified folder to phylonet_noBS for HGT paper
# Claudia January 2016

@subfolder = `find phylonet_noBS -type d`;
shift @subfolder;

foreach(@subfolder){
    system("perl summarizeOutputPhylonetPath.pl path=$_");
}
