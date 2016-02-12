library(ape)
gamma=c(0.1,0.3)
nloci=c(10,20,50,100,200,500,1000)

freqtruetree=rep(0,length(nloci))
freq2ndtree=rep(0,length(nloci))
freqothertree=rep(0,length(nloci))

for(g in gamma){
  alltable = data.frame(n=nloci)
  i=1
  for(n in nloci){
    path=paste("./njst/gamma",g,"_n",n,"/",sep="") #also change filename at the end
    load(paste0(path,"bootstrapAll.Rda"))
    r <- rowMeans(bootstrapAll)
    freqtruetree[i] <- unname(r[1])
    freq2ndtree[i] <- unname(r[2])+unname(r[3])
    freqothertree[i] <- unname(r[4])
    i = i+1
  }
  alltable$freqtruetree = freqtruetree
  alltable$freq2ndtree = freq2ndtree
  alltable$freqothertree = freqothertree
  save(alltable,file=paste(g,"_alltablenjst_BS.Rda",sep=""))
  write.table(alltable,file=paste(g,"_alltablenjst_BS.txt",sep=""),sep=",",row.names=FALSE)
}
