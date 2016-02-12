library(ape)

data = read.table("distances.out",header=TRUE,sep=" ")
dist.frequency = cbind(table(data[2]))

distvalues = as.numeric(rownames(dist.frequency))

mean.dist=mean(data$RFdist)
sd.dist=sd(data$RFdist)

statdf=data.frame(mean=mean.dist,sd=sd.dist)
save(statdf,file="statdf.Rda")
write.table(statdf,file="statdf.txt",sep=",",row.names=FALSE)

data2 = read.table("estTrees.out",header=F,sep=" ")
data2$dis = data$RFdist
data2$V2 = NULL

freqtable = data.frame(tree=character(),freq=numeric(),dist=numeric())

for(k in 1:length(distvalues)){
  number=distvalues[k]
  indeces = sapply(data2$dis,function(x) isTRUE(all.equal(x,number)))
  indeces2 = which(indeces == TRUE)
  datawithdis= data2[indeces2,]

  tree = c()
  freq = c(rep(1,nrow(datawithdis)))

  data4=datawithdis

  for (i in 1:(nrow(data4)-1)){
    j = i+1
    while(j <= nrow(data4)) {
    if(is.na(data4[j,1])){
      break
    } else{
        t1=read.tree(text=toString(data4[i,1]))
        t2=read.tree(text=toString(data4[j,1]))
      
        if (dist.topo(t1,t2) == 0) {
          freq[i] = freq[i] +1
          data4 = data4[-j,]
          j = j-1
        } 
      j = j+1
      }
    }
    tree[i] = toString(data4[i,1])
  }

  tree[length(tree)+1] = "NA"
  a = data.frame(tree,freq)
  b = a[-which(a$tree == "NA"),]
  b
  sort = b[order(b$freq),]
  sort = within(sort,dist<-number)
  freqtable<-rbind(freqtable,sort)
}
dist0<-freqtable[1,]
freqtable<-freqtable[2:nrow(freqtable),]
freqtable<-freqtable[with(freqtable, order(-freq)), ]
freqtable<-rbind(dist0,freqtable)

save(freqtable,file="freqtable.Rda")
write.table(freqtable,file="freqtable.txt",sep=",")
