# r script to remove the boostrap support from astral trees
# needs estTrees.out
# Claudia January 2016

library(ape)
gamma=c(0.1,0.3)
nloci=c(10,20,50,100,200,500,1000)

for(g in gamma){
  for(n in nloci){
    dir = paste0("astral/gamma",g,"_n",n,"/")
    filename = paste0(dir,"estTrees0.out")
    trees = read.tree(filename)
    outname = paste0(dir,"estTrees.out")
    for(i in 1:length(trees)){
      trees[[i]]$node.label <- NULL
      write.tree(trees[[i]],file=outname,append=TRUE)
    }
  }
}
      
