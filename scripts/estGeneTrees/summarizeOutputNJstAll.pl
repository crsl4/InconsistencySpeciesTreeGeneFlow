# perl script to summarize all the NJst outputs
# it calls summarizeOutputNJstPath.pl
# Claudia January 2016

@subfolder = `find njst -type d`;
shift @subfolder;

foreach(@subfolder){
    system("perl summarizeOutputNJstPath.pl path=$_");
}
