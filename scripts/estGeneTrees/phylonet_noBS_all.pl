#!/usr/bin/perl

# perl script that will run phylonet
# for nrep replicates
# calls: phylonet_noBS.pl for each replicate
# Claudia January 2016


#------- Parameters
$from = 1;
$to = 10;
$gamma = 0.3;
$nloci = 10;

# -------------- read arguments from command-line -----------------------
foreach(@ARGV){
    if (/\bgamma\s*=\s*([^\s]+)/i){$gamma = $1; }
    if (/\bfrom\s*=\s*(\d+)/i){$from = $1; }
    if (/\bto\s*=\s*(\d+)/i){$to = $1; }
    if (/\bnloci\s*=\s*(\d+)/i){$nloci = $1; }
}

# -------------- replicates of phylonet.pl -----------------------------------
$logfile = 'gamma'.$gamma.'_n'.$nloci.".log".'_rep'.$from.'_'.$to.'_noBS';
for my $i ($from..$to){
    system("perl phylonet_noBS.pl -gamma $gamma -nloci $nloci -irep $i -logfile $logfile");
}
