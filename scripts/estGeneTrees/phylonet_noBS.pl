#!/usr/bin/perl

# perl script to use the estimated trees by raxml
# to run phylonet, after rooting them with checkRootGT.r
# Claudia January 2016
# modified from phylonet.pl to not do bootstrap
# Claudia January 2016

use Getopt::Long;
use File::Path qw( make_path );
use strict;
use warnings;
use Carp;
#use lib '/u/c/l/claudia/lib/perl/lib/site_perl/'; # we need this because I had to install locally the Statistics module
#use Statistics::R;


# ================= parameters ======================
# Number of replicate of the whole process
my $irep = 1;

# -------------- Folder ----------------
my $gamma = 0.3;
my $nloci = 10;
my $logfile;

# -------------- Parameters phylonet ----------------
my $phylonet = '~/software/phylonet/PhyloNet_3.5.5.jar';
my $command = 'InferNetwork_ML';
my $numHyb = 1;
my $numProc = 1;
my $PNargs = "-x 5";

# -------------- read arguments from command-line -----------------------
GetOptions( 'gamma=f' => \$gamma,
	    'nloci=i' => \$nloci,
	    'irep=i' => \$irep,
	    'PNargs=s' => \$PNargs,
	    'logfile=s' => \$logfile, #you can leave this comma
    );

my $oneminusgamma = 1-$gamma;

if (not defined $logfile){
    $logfile = "gamma${gamma}_n$nloci.log_irep${irep}_noBS";
}


# create directories for ms, seqgen:
my $rootdir = "gamma${gamma}_n${nloci}/";
my $PNpath = 'phylonet_noBS/'.$rootdir;
my $raxmlpath =  'raxml/'.$rootdir;

foreach my $path ($PNpath){
    make_path $path unless(-d $path);
}

# files:
my $phylonetIN = $PNpath.$irep."_phylonet.nex";
my $phylonetOUT = $PNpath.$irep."_phylonet.out";
my $raxmlOUT =  $raxmlpath.$irep."_raxmlRoot.out"; #need checkRootGT.r run before

open FHlog, ">> $logfile";
print FHlog "============================================\n";
print FHlog "running phylonet for replicate $irep\n";
close FHlog;
system("date >> $logfile");
system("hostname >> $logfile");

#================ write input files for PhyloNet  ===================
my @trees = `grep "(" $raxmlOUT`;

open FHnex, ">$phylonetIN";
print FHnex "#NEXUS\n\nBEGIN TREES;\n";

my $i = 0;
foreach(@trees){
    print FHnex "Tree gt$i = $_";
    $i += 1;
}
print FHnex "END;\n";

print FHnex "\nBEGIN PHYLONET;\n";
print FHnex "$command (";

my $nTrees = @trees;

for $i (0..($nTrees-1)){
    print FHnex "gt$i";
    if ($i<$nTrees-1) {print FHnex ",";}
}
print FHnex ") $numHyb -di -pl $numProc";
print FHnex " $PNargs;\n";
print FHnex "END;";
close FHnex;


#========================= run PhyloNet =======================
open FHlog, ">> $logfile";
print FHlog "running phylonet for replicate $irep\n";
my $phylonetcmd = "java -jar $phylonet $phylonetIN > $phylonetOUT";
print FHlog "$phylonetcmd\n";
close FHlog;
system("date >> $logfile");
system("echo 'running phylonet...' >> $logfile");
system($phylonetcmd);
system("date >> $logfile");

open FHlog, ">> $logfile";
print FHlog "end for replicate $irep\n";
close FHlog;

