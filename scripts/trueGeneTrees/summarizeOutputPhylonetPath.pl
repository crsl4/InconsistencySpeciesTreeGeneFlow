# perl script to make one output file from phylonet
# from one given path
# Claudia April 2015

#@subfolder = `find /phylonet -type d`;

$path = 'phylonet/gamma0.1_n10';

foreach(@ARGV){
    if (/\bpath\s*=\s*(.+)/i){$path = $1; }
}

$where = $path."/*phylonet.out"; #needs to match with name given in hgt.pl

@files = `ls $where`;
$outputfile = $path."/estNetworks.out";
$listfile = $path."/listFiles.out";
@goodtrees = ();
open FHlist, ">$listfile";
foreach(@files){
    open FHin, "<$_";
    print FHlist "$_";
    while(<FHin>){
	if(/\bDendroscope : ([^\s]+)/){push @goodtrees, $1;}
    }
    close FHin;
}
close FHlist;

open FHout, ">$outputfile";
foreach(@goodtrees){
    print FHout "$_\n";
}
close FHout;
    


# mejor:
# @subfolder = system(find /phylonet -type d), 
# or find /phylonet -type d > somewhere.txt
# esto te da la lista de subfolders, el primero es solo phylonet/
# luego el grep "Dendroscope" en cada subfolder, 
# cuidado que te da todo el path primero, hay q buscar el arbol con (...)
# cuidar de guardar el output final en el subfolder

# mejor hacer el perl script para un path especifico, y luego otro perl script con la lista de paths, porque no queremos tener q correr todos caada vez.

# tmb hacer perl script q cree el nexus file para cmpnets y symmetricdistances en phylonet
