#!/usr/bin/perl

# perl script to simulate DNA sequences from the ms gene trees
# and analyze with RAXML and then input into JULIA, astral and phylonet
# this runs just one replicate
# Claudia June 2015
# modified with Steve G.'s help
# Claudia July 2015
# warning: all files need to be in working directory first to run TICR scripts
# also, need to be in scratch
# Claudia August 2015
# modified for HGTinconsistency paper
# Claudia December 2015
# added the simulation with ms for nloci=1000
# Claudia December 2015

use Getopt::Long;
use File::Path qw( make_path );
use strict;
use warnings;
use Carp;
use lib '/u/c/l/claudia/lib/perl/lib/site_perl/'; # we need this because I had to install locally the Statistics module
use Statistics::R;


# ================= parameters ======================
# Number of replicate of the whole process
my $irep = 1;

# -------------- Folder ----------------
my $gamma = 0.3;
my $nloci = 10;
my $logfile;

# -------------- Parameters ms ----------------
my $ms = '~/software/ms/msdir/ms';

# ------------- Parameters seg-gen ---------
my $seqgen = '~/software/Seq-Gen.v1.3.3/source/seq-gen';
my $model = 'HKY';
my $length = 500;
# upper bound
my $thetaU = 0.05; #mean as in phylonet paper Yu (2014)
my $freqU = 0.35; # freqs mean as in phylonet paper Yu (2014)
my $kappaU = 4; #mean set by cecile from steve h.'s work
my $alphaU = 3;
# lower bound
my $thetaL = 0.025; #as in phylonet paper Yu (2014)
my $freqL = 0.15; #as in phylonet paper Yu (2014)
my $kappaL = 1; #set by cecile from steve h.'s work
my $alphaL = 0.3;
# for each gene:
my $theta;
my $scaleBL;
my $freq1;
my $freq2;
my $freq3;
my $freq4;
my $freq;
my $kappa;
my $alpha;
my $seed;

# -------------- Parameters mrbayes -----------------
my $mbscript = '~/software/TICR/scripts/mb.pl';

# -------------- Parameters bucky -----------------
my $buckyscript = '~/software/TICR/scripts/bucky.pl';

# -------------- read arguments from command-line -----------------------
GetOptions( 'gamma=f' => \$gamma,
	    'nloci=i' => \$nloci,
	    'irep=i' => \$irep,
	    'logfile=s' => \$logfile, #you can leave this comma
    );

my $oneminusgamma = 1-$gamma;


if (not defined $logfile){
    $logfile = "gamma${gamma}_n$nloci.log_irep$irep";
}


# create directories for ms, seqgen:
my $rootdir = "gamma${gamma}_n${nloci}/";
my $mspath = "ms/$rootdir";
my $seqgenpath = "seqgen/$rootdir";

foreach my $path ($mspath,$seqgenpath){
    make_path $path unless(-d $path);
}

# create directories for mrbayes, bucky
my $mbpath = "mrbayes/$rootdir";
my $buckypath = "bucky/$rootdir";

foreach my $path ($mbpath,$buckypath){
    make_path $path unless(-d $path);
}
# warning: some errors occured when bucky folder was created
# at the beginning, they are fixed now, but keep in mind

# files:
my $msfile = "$mspath$irep.ms";
my $seqgenIN = "${irep}_seqgen.in";
my $mboutput = "${irep}_mbout";
my $buckyout = "${irep}_buckyout";
my $buckyout2 = "${irep}_buckyout2";

open FHlog, ">> $logfile";
print FHlog "============================================\n";
print FHlog "running seqgen,mrbayes,bucky for replicate $irep\n";
close FHlog;
system("date >> $logfile");
system("hostname >> $logfile");

# ============================= run ms =====================================
open FHlog, ">> $logfile";
print FHlog "running ms for replicate $irep\n";
print FHlog "$ms 6 $nloci -T -I 6 1 1 1 1 1 1 -ej 0.1 1 2 -ej 0.5 3 4 -es 0.55 4 $oneminusgamma -ej 0.55 7 5 -ej 0.6 2 4 -ej 1.6 4 5 -ej 2.1 5 6 > $msfile\n";
close FHlog;
system("$ms 6 $nloci -T -I 6 1 1 1 1 1 1 -ej 0.1 1 2 -ej 0.5 3 4 -es 0.55 4 $oneminusgamma -ej 0.55 7 5 -ej 0.6 2 4 -ej 1.6 4 5 -ej 2.1 5 6 > $msfile");
__END__
#================== running seq-gen ===========================
open FHlog, ">> $logfile";
print FHlog "running seq-gen for replicate $irep\n";
system("grep '(' $msfile > $seqgenIN"); 
# need one input file per tree:
open my $FHseq, "<$seqgenIN";
chomp(my @trees = <$FHseq>);
close $FHseq;
my $i = 1;
my $seqgenINi;
my $seqgenOUTi;
my $seqgencmd;
my $seqgenLOGi;
my $sumaScaleBL = 0;
foreach(@trees){
    $seqgenINi = "${irep}_seqgen${i}.in";
    $seqgenOUTi = "${irep}_seqgen".$i.".nex";
    $seqgenLOGi = "${irep}_seqgen${i}.log";
    open my $FHin, ">$seqgenINi";
    print $FHin "$_";
    close $FHin;
    $theta = ($thetaU-$thetaL)*rand()+$thetaL;
    $scaleBL = $theta/2;
    $freq1 = ($freqU-$freqL)*rand()+$freqL;
    $freq2 = ($freqU-$freqL)*rand()+$freqL;
    $freq3 = ($freqU-$freqL)*rand()+$freqL;
    $freq4 = ($freqU-$freqL)*rand()+$freqL;
    $freq1 = $freq1/($freq1+$freq2+$freq3+$freq4);
    $freq2 = $freq2/($freq1+$freq2+$freq3+$freq4);
    $freq3 = $freq3/($freq1+$freq2+$freq3+$freq4);
    $freq4 = $freq4/($freq1+$freq2+$freq3+$freq4);
    $freq = "$freq1,$freq2,$freq3,$freq4";
    $kappa = ($kappaU-$kappaL)*rand()+$kappaL;
    $alpha = ($alphaU-$alphaL)*rand()+$alphaL;
    $seed = int(rand(10000));
    $seqgencmd = "$seqgen -m$model -l$length -s$scaleBL -f$freq -a$alpha -z$seed -t$kappa -on < $seqgenINi 1> $seqgenOUTi 2> $seqgenLOGi"; 
    #output -on = nexus format (needed for Steve H./Noah scripts)
    print FHlog "$seqgencmd\n";
    system("$seqgencmd");
    $i = $i + 1;
    $sumaScaleBL = $sumaScaleBL + $scaleBL;
}
close FHlog;

# ================= formatting seqgen output into mb.pl input ==========

# we do not need to split seqgenOUT anymore because we are simulating each gene separately
# open FHfile, "<$seqgenOUT";
# my $i = 1;
# my $newfile = "${irep}_seqgen".$i.".nex";
# open FHnew, "> $newfile";

# while(<FHfile>){
#     if(/END/){
# 	print FHnew "$_"; 
# 	close FHnew;
# 	if($i < $nloci){ #warning: only makes sense now that nloci matches the number of parts in seqgenOUT
# 	    $i += 1;
# 	    $newfile = "${irep}_seqgen".$i.".nex";
# 	    open FHnew, "> $newfile";
# 	}
#     }else{
# 	if(!/^$/){print FHnew "$_"; }
#     }
# }

# close FHfile;

my $tarfile = "${irep}_seqgen.tar.gz";
system("tar czf $tarfile ${irep}_seqgen*.nex --remove-files");

# ====== creating mrbayes block file ==========

my $mbblockfile = ${irep}."_mbblock.txt";

# calling R to calculate the mean BL
my $R = Statistics::R->new();
$R->startR ;
$R->set( 'filename', $msfile);
$R -> run('source("meanBL.r")');
my $meanBL = $R->get('sum');
$meanBL = $meanBL*($sumaScaleBL/scalar(@trees)); #fixit: make sure using mean scaleBL is ok
my $lambda = int(1/$meanBL); 

# reading the seeds from ms to use the same ones
open FHms, "< $msfile";
my @lines = <FHms>;
my $seeds = $lines[1];
my @vseeds = split / /, $seeds;

# num gen chosen to have some precision on estCF
open FHmb, "> $mbblockfile";
print FHmb "begin mrbayes;\n";
print FHmb "set nowarnings=yes;\n";
print FHmb "set autoclose=yes;\n";
print FHmb "set seed=$vseeds[0];\n" ;
print FHmb "set swapseed=$vseeds[1];\n"; 
print FHmb "lset nst=2 rates=gamma;\n";
print FHmb "prset BrLenspr = Unconstrained:Exp($lambda);\n"; 
print FHmb "mcmcp ngen=1000000 burninfrac=.25 samplefreq=200 printfreq=100000\n";
print FHmb    "diagnfreq=100000 nruns=3 nchains=3 temp=0.40 swapfreq=10;\n";
print FHmb "mcmc;\n";
print FHmb "sumt;\n"; #to get consensus tree in .nex.con.tre file
print FHmb "end;";
close FHmb;

# ==================== running mrbayes =====================================
open FHlog, ">> $logfile";
print FHlog "running mrbayes for replicate $irep\n";
my $mbcmd = "$mbscript $tarfile -m $mbblockfile -o $mboutput --machine-file hosts.txt";
print FHlog "$mbcmd\n";
close FHlog;
system("$mbcmd");

# # ==================== running bucky =====================================
my $mboutfile = $mboutput."/".${irep}."_seqgen.mb.tar";
open FHlog, ">> $logfile";
print FHlog "running bucky for replicate $irep\n";
my $buckycmd = "$buckyscript $mboutfile -o $buckyout --machine-file hosts.txt";
print FHlog "$buckycmd\n";
close FHlog;
system("$buckycmd");

# move files to folders
my $seqgenINall = "${irep}_seqgen*.in";
my $seqgenLOGall = "${irep}_seqgen*.log";

system("mv $seqgenINall $seqgenpath");
system("mv $seqgenLOGall $seqgenpath");
system("mv $tarfile $seqgenpath");
system("mv $mbblockfile $mbpath");

my $path = $mbpath.$mboutput;
if(-d $path){
    system("mv $mboutput/* $path");
    system("rm -rf $mboutput");
}else{
    system("mv $mboutput $mbpath");
}

$path =$buckypath.$buckyout; 
if(-d $path){
    system("mv $buckyout/* $path");
    system("rm -rf $buckyout");
}else{
    system("mv $buckyout $buckypath");
}

# ====== extract consensus tree from mrbayes output per gene

$mboutfile = $mbpath.$mboutput."/".${irep}."_seqgen.mb.tar";
system("perl ~/software/TICR/scripts/extract.pl $mboutfile"); #extract only the consensus tree file .nex.con.tre

# calling R to write the tree file
my $mbtrees = ${irep}."_mb.out";
my $nexus;
for(my $i=1; $i <= $nloci; $i++){
    $nexus = ${irep}."_seqgen".$i.".nex.con.tre";
    $R = Statistics::R->new();
    $R->startR ;
    $R -> run('library(ape)');
    $R->set( 'nexus', $nexus);
    $R->set('outfile', $mbtrees);
    $R -> run('tre=read.nexus(file=nexus)'); #do we need to check if resolved?
    $R -> run('write.tree(tre,file=outfile,append=TRUE)');
}


system("rm -f *.nex.*"); # delete all .nex.con.tre files
system("mv $mbtrees $mbpath"); # mv mb list of est trees to mbpath
#delete the extra columns in the CF table
my $buckytable = $buckypath.$buckyout."/".$irep."_seqgen.CFs.csv";
my $newbuckytable = $buckypath."/".$irep."_buckyCF.csv";
system("cut -d, -f6-7,9-10,12-13 --complement $buckytable > $newbuckytable");

