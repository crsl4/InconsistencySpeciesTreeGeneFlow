# perl script that will simulate genetrees with ms, 
# and analyze them with phylonet and astral
# for ONE replicate
# Claudia March 2015

#!/usr/bin/perl

use File::Path qw( make_path );

# =========================== Paramters =============================
# Number of replicate of the whole process
$irep = 1;

# -------------- Parameters ms ----------------
$ms = '~/software/ms/msdir/ms';
$gamma = 0.3;
$oneminusgamma = 1-$gamma;
$nloci = 10;


# -------------- Parameters phylonet ----------------
$phylonet = '~/software/phylonet/PhyloNet_3.5.5.jar';
$command = 'InferNetwork_ML';
$numHyb = 1;
$numProc = 1;
$PNargs = "";

# -------------- Parameters ASTRAL ----------------
$astral = '~/software/astral/astral.4.7.6.jar';
$astralpath = "./astral/";

$logfile = 'gamma'.$gamma.'_n'.$nloci.".log".'_irep'.$irep;
# -------------- read arguments from command-line -----------------------
foreach(@ARGV){
    if (/\bnumHyb\s*=\s*(\d+)/i){$numHyb = $1; }
    if (/\bPNargs\s*=\s*(.+)/i){$PNargs = $1; }
    if (/\bgamma\s*=\s*([^\s]+)/i){$gamma = $1; }
    if (/\bnloci\s*=\s*(\d+)/i){$nloci = $1; }
    if (/\birep\s*=\s*(\d+)/i){$irep = $1; }
    if (/\bnumProc\s*=\s*(\d+)/i){$numProc = $1; }
    if (/\blogfile\s*=\s*(.+)/i){$logfile = $1; }
}

$oneminusgamma = 1-$gamma;

# create directories for ms, phylonet, astral files:
$rootdir = 'gamma'.$gamma.'_n'.$nloci.'/';
$mspath = 'ms/'.$rootdir;
$PNpath = 'phylonet/'.$rootdir;
$astralpath =  'astral/'.$rootdir;

unless(-d $mspath){make_path $mspath;}
unless(-d $PNpath){make_path $PNpath;}
unless(-d $astralpath){make_path $astralpath;}

# files:
$msfile = $mspath.$irep.".ms";
$phylonetIN = $PNpath.$irep."_phylonet.nex";
$phylonetOUT = $PNpath.$irep."_phylonet.out";
$astralIN = $astralpath.$irep."_astral.in";
$astralOUT =  $astralpath.$irep."_astral.out";
$astralLOG =  $astralpath.$irep."_astral.screenlog";

open FHlog, ">> $logfile";
print FHlog "============================================\n";
print FHlog "running ms,phylonet and astral for replicate $irep\n";
close FHlog;
system("date >> $logfile");
system("hostname >> $logfile");

# ============================= run ms =====================================
open FHlog, ">> $logfile";
print FHlog "running ms for replicate $irep\n";
print FHlog "$ms 6 $nloci -T -I 6 1 1 1 1 1 1 -ej 0.1 1 2 -ej 0.5 3 4 -es 0.55 4 $oneminusgamma -ej 0.55 7 5 -ej 0.6 2 4 -ej 1.6 4 5 -ej 2.1 5 6 > $msfile\n";
close FHlog;
system("$ms 6 $nloci -T -I 6 1 1 1 1 1 1 -ej 0.1 1 2 -ej 0.5 3 4 -es 0.55 4 $oneminusgamma -ej 0.55 7 5 -ej 0.6 2 4 -ej 1.6 4 5 -ej 2.1 5 6 > $msfile");

# ================ write input files for PhyloNet and ASTRAL ===================
@trees = `grep "(" $msfile`;

open FHnex, ">$phylonetIN";
open FHastral, ">$astralIN";
print FHnex "#NEXUS\n\nBEGIN TREES;\n";

my $i = 0;
foreach(@trees){
    print FHnex "Tree gt$i = $_"; 
    print FHastral "$_";
    $i += 1;
}
print FHnex "END;\n";

print FHnex "\nBEGIN PHYLONET;\n";
print FHnex "$command (";

$nTrees = @trees;

for $i (0..($nTrees-1)){
    print FHnex "gt$i";
    if ($i<$nTrees-1) {print FHnex ",";}
}
print FHnex ") $numHyb -di -pl $numProc";
print FHnex " $PNargs;\n"; 
print FHnex "END;";
close FHnex;
close FHastral;


# ========================= run ASTRAL =========================
open FHlog, ">> $logfile";
print FHlog "running astral for replicate $irep\n";
print FHlog "java -jar $astral -i $astralIN -o $astralOUT > $astralLOG 2>&1\n";
close FHlog;
system("java -jar $astral -i $astralIN -o $astralOUT > $astralLOG 2>&1");

# ========================= run PhyloNet =======================
open FHlog, ">> $logfile";
print FHlog "running phylonet for replicate $irep\n";
print FHlog "java -jar $phylonet $phylonetIN > $phylonetOUT\n";
close FHlog;
system("date >> $logfile");
system("echo 'running phylonet...' >> $logfile");
system("java -jar $phylonet $phylonetIN > $phylonetOUT");
system("date >> $logfile");

open FHlog, ">> $logfile";
print FHlog "end for replicate $irep\n";
close FHlog;
