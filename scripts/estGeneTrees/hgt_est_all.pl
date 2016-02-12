#!/usr/bin/perl

# perl script that will simulate genetrees with ms, 
# and analyze them with phylonet and astral
# for nrep replicates
# calls: hgt.pl for each replicate
# Claudia March 2015
# modified to new way to call hgt_est.pl after meeting Steve G.
# not modified here to call hgt_all the exact same way as before
# Claudia August 2015
# modified to do the loop on nloci too
# Claudia August 2015

#------- Parameters
my $from = 1;
my $to = 10;
my $gamma = 0.3;


# -------------- read arguments from command-line -----------------------
foreach(@ARGV){
    if (/\bgamma\s*=\s*([^\s]+)/i){$gamma = $1; }
    if (/\bfrom\s*=\s*(\d+)/i){$from = $1; }
    if (/\bto\s*=\s*(\d+)/i){$to = $1; }
}



# -------------- replicates of hgt.pl -----------------------------------
foreach my $nloci (1000){
    $logfile = 'gamma'.$gamma.'_n'.$nloci.".log".'_rep'.$from.'_'.$to;
    for my $i ($from..$to){
	system("perl hgt_est.pl -gamma $gamma -nloci $nloci -irep $i -logfile $logfile");
    }
}
