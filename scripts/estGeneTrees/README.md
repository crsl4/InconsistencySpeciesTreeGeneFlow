####SETUP:

1. Copy the ms folder from the true gene trees simulations per scenario:
gamma (0.1, 0.3),nloci (10,...,500)

2. Git clone [TICR](https://github.com/nstenz/TICR) in the software folder

3. Need to install
[Seq-Gen](http://tree.bio.ed.ac.uk/software/seqgen/),
[MrBayes](http://mrbayes.sourceforge.net/download.php),
[BUCKy](http://www.stat.wisc.edu/~ane/bucky/index.html) and
[RAxML](http://sco.h-its.org/exelixis/software.html) in the software
folder. For RAxML, the scripts assume it was installed and compiled
with: git clone https://github.com/stamatak/standard-RAxML.git, make
-f Makefile.SSE3.PTHREADS.gcc, rm *.o.  Also need
[astral](https://github.com/smirarab/ASTRAL),
[ms](http://home.uchicago.edu/rhudson1/source/mksamples/msdir/msdoc.pdf)
and [phylonet](http://bioinfo.cs.rice.edu/phylonet),
[NJst](https://code.google.com/archive/p/phybase/downloads) installed
in a software folder.  Also need to install
[Julia](http://julialang.org) and the
[PhyloNetworks](https://github.com/crsl4/PhyloNetworks) package.

4. Need to have subfolders: seqgen, bucky, mrbayes, raxml in the
project folder.  It also needs astral, phylonet and njst folders. Make sure
they are empty (not containing the results from true gene trees).

####SIMULATIONS:

1. run: 
   ```
   perl hgt_est_all.pl gamma=0.3 from=1 to=100 
   perl hgt_est_all.pl gamma=0.1 from=1 to=100
   ```
   This script will
        simulate sequences with seqgen on the true gene trees
        (simulated with ms already), and will then estimate gene tree
        with MrBayes. It will then estimate concordance factors with
        BUCKy.  This script will create per replicate: `?_mb.out` (file
        with list of estimated trees) and `?_buckyCF.csv` (table with
        estCF) this perl script was modified from `hgt_all.pl` to do the
        loop on `nloci` as well.  

2. If you do not have true gene trees simulated with ms already, run
   ```
   perl hgt_est_all2.pl gamma=0.3 from=1 to=100
   perl hgt_est_all2.pl gamma=0.1 from=1 to=100
   ```
   instead. This script calls `hgt_est2.pl`.

3. run
```
perl raxml_all.pl gamma=0.1 from=1 to=100
```
(this runs
nloci=10,...,1000), run perl
```
perl raxml_all2.pl gamma=0.3 nloci=xxx from=1 to=100
```
(to parallelize per nloci).  This runs
raxml (with bootstrap) on the simulated sequences in the seqgen folder
and astral (with bootstrap) in the estimated raxml gene trees.

4. run
```
R CMD BATCH bootstrapNJst.R
```
and after it's finished:
```
R CMD BATCH bestNJst.R
```
to run NJst with bootstrap from the raxml estimated
gene trees.

5. need to root raxml trees for phylonet, so need to run:
```
R CMD BATCH checkRootGT.r
```

6. run
```
perl phylonet_all.pl gamma=0.1 nloci=10 from=1 to=100
```
which will run PhyloNet with bootstrap. Be careful with memory use, do not
start too many jobs in the same machine.

7. Alternative, you can also run:
```
perl phylonet_noBS_all.pl gamma=0.1 nloci=10 from=1 to=100
```
to run only for original data (no bootstrap)
for gamma=0.1,0.3, nloci=10,20,50,100,200,500,1000.  You need a folder
called phylonet_noBS

####SUMMARY OF RESULTS:

#####ASTRAL/ NJst

1. run
```
perl summarizeOutputAstralAll.pl
perl summarizeOutputNJstAll.pl
```
to create estTrees.out files inside each folder (estTrees0.out for astral)

2. For astral, we need an intermediate step to remove the bootstrap
support on the trees:
```
R CMD BATCH removeBSAstral.r
```

3. run
```
perl PhylonetSymmDistAll.pl
perl PhylonetSymmDistNJstAll.pl
```
to create a file distances.out inside each folder WARNING: beware of the path, it has to say astral or njst, could have been changed.

4.
```
R CMD BATCH summarizeAstralDistances.r
R CMD BATCH summarizeNjstDistances.r
```
to create two files per folder:
   freqtable.txt and statdf.txt WARNING: the path could be changed to
   other than astral or njst, so check!

5.
```
R CMD BATCH summarizeAstralAll.r
R CMD BATCH summarizeNjstAll.r
```
   to create one summary table per gamma:
   gamma_alltableastral(njst).txt needs: 2ndtree.tre, 3rdtree.tre,
   4thtree.tre with other trees different to the true species tree.
   WARNING: the path could be changed to other than astral or njst, so
   check!

#####PhyloNet

WARNING: for phylonet, we are using folder phylonet_noBS

1. run
```
perl summarizeOutputPhylonetAll.pl
```
(make sure correct folder
phylonet_noBS) to get estNetworks.out inside each folder

2. get into the file extractMainTrees.jl and put the desired folder
(phylonet_noBS) and corresponding filename (estNetworks.out), run:
```
julia extractMainTrees.jl
```
This script will create a estTrees.out file
in each folder.

3. Warning: next step takes time, so better to use a screen: change
the path to phylonet_noBS in PhylonetSymmDist.pl and run: run
```
perl PhylonetSymmDistAll.pl
```

4. change the path to phylonet_noBS in summarizeAstralDistance.r
```
R CMD BATCH summarizeAstralDistances.r
```
this will create freqtable and statdf files inside each folder

5. change path to phylonet_noBS and run
```
R CMD BATCH summarizeAstralAll.r
```
to create one summary table per gamma:
gamma_alltablephylonet.txt needs: 2ndtree.tre, 3rdtree.tre,
4thtree.tre: other trees different that the true species tree

#####Concatenation

1.
```
perl summarizeOutputConcatAll.pl
```
which will create the
estTrees.out and listFiles.out in each folder

2. change path to raxml and run
```
perl PhylonetSymmDistAll.pl
```
to create
a file distances.out inside each folder

3. change the path to raxml and run
```
R CMD BATCH summarizeAstralDistances.r
```
to create two files per folder:
freqtable.txt and statdf.txt

4. change the path to raxml and run
```
R CMD BATCH summarizeAstralAll.r
```
 to create one summary table per gamma: gamma_alltableconcat.txt
 needs: 2ndtree.tre, 3rdtree.tre, 4thtree.tre: other trees different
 that the true species tree


