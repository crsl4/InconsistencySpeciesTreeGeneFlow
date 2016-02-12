# Inconsistency of species-tree methods under gene flow
Scripts for simulation study on Syst Bio paper: Sol&iacute;s-Lemus, C., Yang, M. and An&eacute;, C. Inconsistency of species-tree methods under gene flow

### scripts

#### true gene trees analyses

The scripts will simulate gene trees with ms on a given species tree,
and then use the simulated gene trees as input in ASTRAL, NJst and
PhyloNet to estimate the species tree.

* Follow the steps in the README file inside scripts/trueGeneTrees.

* Links to Astral, NJst, ms and PhyloNet in the README file as well.

#### estimated gene trees analyses

The scripts will use the simulated gene trees from the true gene trees
analyses, and simulate DNA sequences with Seq-Gen. Then, use RAxML to
estimate gene trees, and use the estimated gene trees as input in
Astral, NJst and PhyloNet.

* Follow the steps in the README file inside scripts/estGeneTrees

* Links to Astral, NJst, PhyloNet, Seq-Gen and RAxML in the README file as well.


