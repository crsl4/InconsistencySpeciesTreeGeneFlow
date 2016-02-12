# r script to take list of raxml.out estimated gene trees and
# run NJst to get species tree
# written by Mengyao
# need to run boostrapNJst.r first to create the files ?_njst.out
# just like the ?_astral.out files

library(phybase)
#library(ape)
gamma=c(0.1)
nloci=c(20,50,100,200,500)

##est species trees from best trees, sum in estTrees.out
for(g in gamma) {
  for (n in nloci) {
    raxmldir ="raxml"
    njstdir = "njst"
    dir = paste0("gamma",g,"_n",n)
    rep=1
    while(rep <= 100) {
        filename=paste0(raxmldir,"/",dir,"/",rep,"_raxml.out")
        if(file.exists(filename)){
            genetreetable = read.table(filename)
            genetree = genetreetable$V1
            spname=c("1","2","3","4","5","6")
            nspecies=length(spname)
            species.structure=diag(nspecies)
            tre = NJst(genetree,spname, spname, species.structure)
            tre = root(read.tree(text=tre),"6", resolve=T)
            line = write.tree(tre)
            if(file.exists(paste0(njstdir,"/",dir))){
                write(line,file=paste0(njstdir,"/",dir,"/",rep,"_njst.out"),append=TRUE)
                write(line,file=paste0(njstdir,"/",dir,"/",rep,"_njst.out"),append=TRUE) # line repeated twice to match astral.out
            }else{
                dir.create(file.path(njstdir, dir))
                file.create(paste0(njstdir,"/",dir,"/",rep,"_njst.out"))
                write(line,file=paste0(njstdir,"/",dir,"/",rep,"_njst.out"),append=TRUE)
                write(line,file=paste0(njstdir,"/",dir,"/",rep,"_njst.out"),append=TRUE) # line repeated twice to match astral.out
            }
        }
        rep = rep+1
    }
  }
}
