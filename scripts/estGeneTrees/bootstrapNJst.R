# r script to take list of bootstrap raxml.out estimated gene trees and
# run NJst to get species tree
# written by Mengyao
# need to run this before bestNJst.r to create the files ?_njst.out
# just like the ?_astral.out files

library(phybase)
library(ape)
gamma=c(0.1)
nloci=c(10,20,50,100,200,500)

spname=c("1","2","3","4","5","6")
nspecies=length(spname)
species.structure=diag(nspecies)

for(g in gamma) {
  for (n in nloci) {
    raxmldir ="raxml"
    njstdir = "njst"
    dir = paste0("gamma",g,"_n",n)
    print(paste0("dir ",dir))
    rep=1
    
    while(rep <= 100) {
      bootstrapfilename=paste0(raxmldir,"/",dir,"/",rep,"_bootstrap")
      print(paste0("rep ", rep))
      finalMatrix = matrix(nrow = n, ncol = 100)
      numG = 0
      for (k in 1:n) {
        filename=paste0(bootstrapfilename,"/RAxML_bootstrap.",rep,"_raxml",k)
        if(file.exists(filename)){
          print(paste0("gene ",k, " exists!"))
          numG = numG + 1
          curFile = read.table(filename,header=FALSE)
          finalMatrix[k,] = as.character(curFile$V1)
        }
      }
      print(paste0("for rep ",rep," there are ", numG, " genes"))
      finalMatrix = finalMatrix[complete.cases(finalMatrix),]
      nrows = nrow(finalMatrix)
      print(paste0("finalMatrix has rows: ",nrows))

      for (j in 1:100){
        print(paste0("boostrap ",j))
        genetree = finalMatrix[,j]
        tre = NJst(genetree,spname, spname, species.structure)
        tre = root(read.tree(text=tre),"6", resolve=T)
        line = write.tree(tre)
        if(file.exists(paste0(njstdir,"/",dir))){
          write(line,file=paste0(njstdir,"/",dir,"/",rep,"_njst.out"),append=TRUE) #distances.out?
        }else{
          dir.create(file.path(njstdir,dir))
          file.create(paste0(njstdir,"/",dir,"/",rep,"_njst.out"))
          write(line,file=paste0(njstdir,"/",dir,"/",rep,"_njst.out"),append=TRUE)
        }
      }
      rep = rep+1
    }
  }
}
