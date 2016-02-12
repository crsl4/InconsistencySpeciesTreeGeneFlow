####SETUP:

1. You need to have [astral](https://github.com/smirarab/ASTRAL),
[ms](http://home.uchicago.edu/rhudson1/source/mksamples/msdir/msdoc.pdf)
and [phylonet](http://bioinfo.cs.rice.edu/phylonet),
[NJst](https://code.google.com/archive/p/phybase/downloads) installed
in a software folder

2. You need a project folder with all the scripts and create four
subfolders inside the project folder: ms, phylonet, astral, NJst

####SIMULATIONS:

1. perl hgt_all.pl gamma=0.3 nloci=10 from=1 to=10. This perl script
calls hgt.pl which simulates gene trees with ms, and analyzes them
with astral and phylonet.  Careful: no spaces between the variable, =
and the number. That is, gamma=0.3 is correct, but gamma = 0.3 is
wrong.

2. run R CMD BATCH getSpeTree.R in the project folder which will
create subfolders for each scenario in NJst directory and one file
(per folder) with the list of all estimated trees(in order)in NJst:
estTrees.out


####SUMMARIZE OUTPUT:

1. run perl summarizeOutputAstralAll.pl, perl
       summarizeOutputPhylonetAll.pl, which will create one file (per
       folder) with the list of all estimated trees in astral:
       estTrees.out and all the estimated networks in phylonet:
       estNetworks.out for that folder (given value of gamma, nloci)

2. run perl PhylonetCmpnetsAll.pl, perl PhylonetSymmDistAll.pl, which
       will calculate the distance of estimated networks/trees and
       true network/tree (need to match the one used for simulations
       in ms: hgt.pl) in every subfolder in phylonet/astral: this will
       create a file distances.out inside each subfolder

3. run R CMD BATCH summarizeAstralDistances.r,
                   summarizeNJstDistances.r, (distances.R is script
                   for only one specific case) that will get into each
                   subfolder in astral/NJst and will summarize results
                   based on distances.out into two files:
                   freqtable.txt (that contains the list of trees and
                   its frequency), and statdf.txt (that has the
                   mean/sd distance)

4. run R CMD BATCH summarizeAstralAll.R, summarizeNJstAll.R, that will
                   summarize all summary tables and will summarize it
                   into two files:
                   0.1_alltableastral.txt/0.1_alltableNJst.txt (that
                   contains mean distances, std distances,
                   freqtrueetree, freq2ndtree, freq3rdtree,
                   freq4thtree and freqothertree according to n for
                   gamma=0.1), and
                   0.3_alltableNJst.txt/0.3_alltableNJst.txt (that
                   contains all above statistics for gamma=0.3)

