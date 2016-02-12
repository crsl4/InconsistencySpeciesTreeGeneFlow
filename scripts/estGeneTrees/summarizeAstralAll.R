library(ape)
gamma=c(0.1,0.3)
nloci=c(10,20,50,100,200,500,1000)

meandist=c(length(nloci))
sddist=c(length(nloci))
freqtruetree=c(length(nloci))
freq2ndtree=c(length(nloci))
freq3rdtree=c(length(nloci))
freq4thtree=c(length(nloci))
freqothertree=c(length(nloci))

for(g in gamma){
  alltable = data.frame(n=nloci)
  for(n in nloci){
    path=paste("./raxml/gamma",g,"_n",n,"/",sep="") #also change filename at the end
    stats = paste(path,"statdf.txt",sep="")
    statsdata = read.table(stats,header=TRUE,sep=",")
    meandist[which(nloci==n)] = statsdata[1,1]
    sddist[which(nloci==n)] = statsdata[1,2]
    
    freq = paste(path,"freqtable.txt",sep="")
    freqdata = read.table(freq,header=TRUE,sep=",")
    if (freqdata[1,3] == 0) {
      freqtruetree[which(nloci==n)] = freqdata[1,2]
    } else {
      freqtruetree[which(nloci==n)] = 0
    }
    
    #freqtruetree[which(nloci==n)] = freqdata[1,2]
    
    
    t21=read.tree(text=toString(read.table("2ndtree.tre")[1,1]))
    t22=read.tree(text=toString(read.table("2ndtree.tre")[2,1]))
    t31=read.tree(text=toString(read.table("3rdtree.tre")[1,1]))
    t32=read.tree(text=toString(read.table("3rdtree.tre")[2,1]))
    t4=read.tree(text=toString(read.table("4thtree.tre")[1,1]))
    freq2ndtree[which(nloci==n)] = 0
    freq3rdtree[which(nloci==n)] = 0
    freq4thtree[which(nloci==n)] = 0

    for (i in 1:nrow(freqdata)) {
      if (freqdata[i,3] == 0) {
        next
      } else {
        t=read.tree(text=toString(freqdata[i,1]))
        if (dist.topo(t,t21) == 0 || dist.topo(t,t22) == 0) {
          freq2ndtree[which(nloci==n)] = freq2ndtree[which(nloci==n)] + freqdata[i,2]
        }
        
        if (dist.topo(t,t31) == 0 || dist.topo(t,t32) == 0) {
          freq3rdtree[which(nloci==n)] = freq3rdtree[which(nloci==n)] + freqdata[i,2]
        }
        
        if (dist.topo(t,t4) == 0) {
          freq4thtree[which(nloci==n)] = freq4thtree[which(nloci==n)] + freqdata[i,2]
        }
      }
    }
  }
  alltable$meandist = meandist
  alltable$sddist = sddist
  alltable$freqtruetree = freqtruetree
  alltable$freq2ndtree = freq2ndtree
  alltable$freq3rdtree = freq3rdtree
  alltable$freq4thtree = freq4thtree
  alltable$freqothertree = 100 - (freqtruetree + freq2ndtree +freq3rdtree+freq4thtree)
  save(alltable,file=paste(g,"_alltableconcat.Rda",sep=""))
  write.table(alltable,file=paste(g,"_alltableconcat.txt",sep=""),sep=",",row.names=FALSE)
  
}
