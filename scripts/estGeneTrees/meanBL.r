# r code to compute the mean branch length of a collection of trees
# from ms (a *.ms file)
# claudia August 2015

library(ape)
#g1=0.3
#g2=0.2
#n=10
#rep=1
#filename=paste0("ms/gamma",g,"_n",n,"/",rep,".ms")

genetree = read.table(filename, skip=4, as.is=T)$V1
genetree = genetree[genetree!="//"]
sum = 0
for(g in genetree){
  t = read.tree(text=g)
  m = mean(t$edge.length)
  sum = sum + m
}

sum = sum/length(genetree)
