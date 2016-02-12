#!/usr/bin/perl

# perl script that will run raxml and astral
# for nrep replicates
# calls: raxml.pl for each replicate
# Claudia January 2016


#------- Parameters
$from = 1;
$to = 10;
$gamma = 0.3;

# -------------- read arguments from command-line -----------------------
foreach(@ARGV){
    if (/\bgamma\s*=\s*([^\s]+)/i){$gamma = $1; }
    if (/\bfrom\s*=\s*(\d+)/i){$from = $1; }
    if (/\bto\s*=\s*(\d+)/i){$to = $1; }
}

# -------------- replicates of raxml.pl -----------------------------------
foreach my $nloci (100,200){
    $logfile = 'gamma'.$gamma.'_n'.$nloci.".log".'_rep'.$from.'_'.$to;
    for my $i ($from..$to){
	system("perl raxml.pl -gamma $gamma -nloci $nloci -irep $i -logfile $logfile");
    }
}


