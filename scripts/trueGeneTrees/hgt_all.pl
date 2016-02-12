# perl script that will simulate genetrees with ms, 
# and analyze them with phylonet and astral
# for nrep replicates
# calls: hgt.pl for each replicate
# Claudia March 2015

#!/usr/bin/perl

#------- Parameters
$from = 1;
$to = 10;
$gamma = 0.3;
$nloci = 10;
$numProc = 1;

# -------------- read arguments from command-line -----------------------
foreach(@ARGV){
    if (/\bgamma\s*=\s*([^\s]+)/i){$gamma = $1; }
    if (/\bnloci\s*=\s*(\d+)/i){$nloci = $1; }
    if (/\bfrom\s*=\s*(\d+)/i){$from = $1; }
    if (/\bto\s*=\s*(\d+)/i){$to = $1; }
    if (/\bnumProc\s*=\s*(\d+)/i){$numProc = $1; }
}

$logfile = 'gamma'.$gamma.'_n'.$nloci.".log".'_rep'.$from.'_'.$to;

# -------------- replicates of hgt.pl -----------------------------------
for my $i ($from..$to){
    system("perl hgt.pl gamma=$gamma nloci=$nloci irep=$i numProc=$numProc logfile=$logfile");
}
