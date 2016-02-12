# perl script to summarize all the concatenation outputs
# it calls summarizeOutputConcatPath.pl
# Claudia January 2016

@subfolder = `find raxml -type d`;
shift @subfolder;

foreach(@subfolder){
    system("perl summarizeOutputConcatPath.pl path=$_");
}
