#!/usr/bin/perl

# perl script to use sequences simulated by seqgen
# to run raxml per locus and in the concatenated gene
# Claudia December 2015
# warning: using 12 cores for raxml

use Getopt::Long;
use File::Path qw( make_path );
use strict;
use warnings;
use Carp;
#use lib '/u/c/l/claudia/lib/perl/lib/site_perl/'; # we need this because I had to install locally the Statistics module
#use Statistics::R;


# ================= parameters ======================
# Number of replicate of the whole process
my $irep = 38;

# -------------- Folder ----------------
my $gamma = 0.1;
my $nloci = 1000;
my $logfile;
my $numboot = 100;
my $numCores = 12;

# -------------- read arguments from command-line -----------------------
GetOptions( 'gamma=f' => \$gamma,
	    'nloci=i' => \$nloci,
	    'irep=i' => \$irep,
	    'logfile=s' => \$logfile, #you can leave this comma
    );

if (not defined $logfile){
    $logfile = "gamma${gamma}_n$nloci.log_irep$irep";
}

# create directories
my $rootdir = "gamma${gamma}_n${nloci}/";
my $astralpath =  'astral/'.$rootdir;
my $seqgenpath = 'seqgen/'.$rootdir;
my $raxmlpath = 'raxml/'.$rootdir;

foreach my $path ($astralpath,$raxmlpath){
    make_path $path unless(-d $path);
}

open FHlog, ">> $logfile";
print FHlog "============================================\n";
print FHlog "running raxml for replicate $irep\n";
close FHlog;
system("date >> $logfile");
system("hostname >> $logfile");

# chdir("...") or die "error message";
my $seqgenfile = "${irep}_seqgen.tar.gz";
my $seqgenOUT = "${seqgenpath}${irep}_seqgen.tar.gz";
system("cp $seqgenOUT .");
system("tar -zxvf $seqgenfile");

#-----------------------------------------------#
#  convert nexus to phylip files                #
#  interleaved format: do *not* repeat taxon names
#-----------------------------------------------#

for my $ig (1..$nloci){
    my $infn = "${irep}_seqgen${ig}.nex";
    my $oufn = "${irep}_seqgen${ig}.phy";
    my $read = 0;
    my $removeNames = 0; my $nReadNames = 0;
    my $ntax = 0;
    my $nchar = 0;
    my $ncopy = 0;
    open my $FHi, $infn or die "can't open NEXUS gene sequence file";
    open my $FHo, ">", $oufn or die "can't open PHYLIP gene sequence file";
    while (<$FHi>){
	if ($read){
	    # if (/^\s;$/){ last; } # for old data
	    if (/^\s*;/){ last; } # old data: /^;/
	    if (/copy/){ $ncopy++; next; }
            else {
                if ($removeNames){
                   if (/^[^\s]+\s+(.*)/) { print $FHo "$1\n"; }
                } else {                   print $FHo $_;
                   $nReadNames++;
                   if ($nReadNames == $ntax){ $removeNames = 1; }
                }
            }
	}
	if ($read==0){
	    if (/ntax=(\d+)/i){
	    	$ntax = $1;
#	    	$ntax -= $copyTaxonNumber[$ig];
	    	print $FHo " $ntax ";
	    }
	    if (/nchar=(\d+)/i){
		$nchar = $1;
		if ($ntax==0){ print "problem in gene $ig: found nchar before ntax\n"}
		print $FHo "$nchar\n";
	    }
	}
	if (/^\s*matrix/i){
	    $read=1;
	    if ($ntax==0 or $nchar==0){
		print "problem in gene $ig: was unable to find ntax ($ntax) or nchar ($nchar)\n";
	    }
	}
    }
  #  if ($ncopy or $copyTaxonNumber[$ig]){
  #	print "$gene: ". $copyTaxonNumber[$ig] ." copy taxa, removed $ncopy lines with copy taxa\n"; }
    close $FHi;
    close $FHo;
 }


#-----------------------------------------------#
#  run RAxML on phylip files                    #
#-----------------------------------------------#
#chdir("../raxml/") or die "can't go to raxml directory";
my $raxml = '~/software/standard-RAxML/raxmlHPC-PTHREADS-SSE3';
open FHlog, ">> $logfile";

for my $ig (1..$nloci){
    my $infn = "${irep}_seqgen${ig}.phy";
    my $raxmlOUT = "${irep}_raxml${ig}";
    my $str = "$raxml  -T $numCores -m GTRGAMMA --HKY85  -f a -N $numboot";
    $str .= " -p " . int(rand(10000));
    $str .= " -x " . int(rand(10000));
    $str .= " -s $infn -n $raxmlOUT";
    print FHlog "starting RAxML for gene $ig...\n";
    print FHlog "$str\n";
    system($str);
#    print FHlog "done.\n";
}
system("date >> $logfile");
close FHlog;

# ----------------------------------------------#
#   raxml concatenated analysis                 #
# ----------------------------------------------#

# create concatenated file
my $concatfile = "${irep}_concat.in";
my $tmp = "${irep}.tmp";
my $tmp3 = "${irep}.tmp3";
my $files = "${irep}_seqgen1.phy ";

for my $ig (2..$nloci){
    `cut -c3- ${irep}_seqgen${ig}.phy > ${irep}_reduced${ig}.phy`;
    $files .= "${irep}_reduced${ig}.phy ";
}

`paste -d : $files > $tmp`;
`sed -i 's/://g' $tmp`;
`tail -n +2 $tmp > $tmp3`;

my $length = $nloci * 500;
`echo '6 $length' | cat - $tmp3 > temp && mv temp $concatfile`;

unlink glob("${irep}*reduced*");
unlink("${irep}.tmp");
unlink("${irep}.tmp3");

my $raxmlOUT = "${irep}_raxml_concat";
my $str = "$raxml  -T $numCores -m GTRGAMMA --HKY85  -f a -N $numboot";
$str .= " -p " . int(rand(10000));
$str .= " -x " . int(rand(10000));
$str .= " -s $concatfile -n $raxmlOUT";
print "$str\n";
system($str);

# ---- move files ------
for my $ig (1..$nloci){
	unlink("${irep}_seqgen${ig}.nex");
	unlink("${irep}_seqgen${ig}.phy");
}
unlink("${irep}_seqgen.tar.gz");

my $raxmltar = "${irep}_raxml.tar.gz";
`tar -cvf $raxmltar RAxML_bipartitions*.${irep}* RAxML_info.${irep}* --remove-files`;
`mv RAxML_bestTree.${irep}*_concat $raxmlpath`;
`mv RAxML_bootstrap.${irep}*_concat $raxmlpath`;
`mv $raxmltar $raxmlpath`;

my $bootpath = "$raxmlpath${irep}_bootstrap/";
foreach my $path ($bootpath){
    make_path $path unless(-d $path);
}
`mv RAxML_bootstrap.${irep}* $bootpath`;

$raxmlOUT = "$raxmlpath${irep}_raxml.out";
`cat RAxML_bestTree.${irep}_raxml* > $raxmlOUT`;
my $raxmltar2 = "${irep}_besttree_raxml.tar.gz";
`tar -cvf $raxmltar2 RAxML_bestTree*.${irep}* --remove-files`;
`mv $raxmltar2 $raxmlpath`;

#`mv ${irep}_concat.in $seqgenpath`;
unlink("${irep}_concat.in");

# ----------------------------------------------#
#   astral analysis                             #
# ----------------------------------------------#

my $astral = '~/software/ASTRAL/Astral/astral.4.7.6.jar';
my $bsfiles =  $astralpath.$irep."_bsfiles";
my $astralLOG =  $astralpath.$irep."_astral.screenlog";
my $astralOUT =  $astralpath.$irep."_astral.out";

$bootpath = "$raxmlpath${irep}_bootstrap/*";
`ls -d $bootpath > $bsfiles`;

#========================= run ASTRAL =========================
open FHlog, ">> $logfile";
print FHlog "running astral for replicate $irep\n";
my $astralcmd = "java -jar $astral -i $raxmlOUT -b $bsfiles -r $numboot -o $astralOUT > $astralLOG 2>&1";
print FHlog "$astralcmd\n";
close FHlog;
system($astralcmd);


