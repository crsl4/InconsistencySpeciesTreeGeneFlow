# perl script to summarize all the astral outputs
# inside the phylonet folder
# it calls summarizeOutputAstralPath.pl
# Claudia April 2015

@subfolder = `find astral -type d`;
shift @subfolder;

foreach(@subfolder){
    system("perl summarizeOutputAstralPath.pl path=$_");
}
