library(phybase)
library(ape)

gamma = c(0.1,0.3)
nloci=c(10,20,50,100,200,500,10000)
#truetree = "(((1,2),(3,4)),5,6);"
#truetree = root(read.tree(text=truetree),"6", resolve=T)

for(g in gamma) {
  for (n in nloci) {
    maindir ="~/project/NJst"
    dir = paste0("gamma",g,"_n",n)
    rep=1
    while(rep <= 100) {
      filename=paste0("~/project/ms/gamma",g,"_n",n,"/",rep,".ms")
      genetree = read.table(filename, skip=4, as.is=T)$V1
      genetree = genetree[genetree!="//"]
      spname=c("1","2","3","4","5","6")
      nspecies=length(spname)
      species.structure=diag(nspecies)
      #species.structure means 
      tre = NJst(genetree,spname, spname, species.structure)
      tre = root(read.tree(text=tre),"6", resolve=T)
      ##dist = RF.dist(truetree,tre)
      line = write.tree(tre)
      if(file.exists(paste0(maindir,"/",dir))){
        # write() appends to an existing file
        write(line,file=paste0(maindir,"/",dir,"/estTrees.out"),append=TRUE) #distances.out?
      }else{
        # file.path requires no "/" between maindir and dir
        dir.create(file.path(maindir, dir))
        file.create(paste0(maindir,"/",dir,"/estTrees.out"))
        write(line,file=paste0(maindir,"/",dir,"/estTrees.out"),append=TRUE)
      }
      rep = rep+1
    }
  }
}

