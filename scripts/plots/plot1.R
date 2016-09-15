library(plotrix)
library(phybase)
library(ape)
gamma=c(0.1,0.3)
method=c("astral","NJst")
cols=grey(c(.5,0))
ltys=c(1,2)
#xpos = c(1,2,3,4,5,6,7)
nloci=c(10,20,50,100,200,500,10000)
xpos = log(nloci)
xpos[7] = log(2000)
#pdf(paste("meandist.pdf",sep=""), width=6, height=5)
setEPS()
postscript(paste("meandist.eps",sep=""), width=6, height=5)
par(mar=c(3.1,3.6,.5,.5), mgp=c(1.5,.5,0), tck=-0.01, las=1, yaxs="r", xaxs="r")

for (m in method) {
  for (g in gamma) {
    load(paste0(g,"_alltable",m,".Rda"))
    add=F
    if (m == "astral") {
      if (g == 0.3) add=T
      meanplot=with(alltable,plotCI(xpos+0.05*(-1+2*add),meandist,sddist/10,
                                    main ="",xlab="Number of Gene Trees",
                                    xlim=range(xpos)*c(0.9,1.05),col=cols[2],
                                    ylab="",ylim=c(0,0.35),axes=F, add=add,pch=16))
      axis(side=1,at=xpos,labels=nloci)
      axis(side=2,ylim=c(0,0.5))
      mtext("Mean RF distance", line=2.5,side=2,las=0)
      lines(meanplot,col=cols[2],lty=ltys[add+1])
    } else {
      if (g==0.3) add=T
      meanplot=with(alltable,plotCI(xpos+0.05*(1-2*add),meandist,sddist/10,
                                    main ="",xlab="Number of Gene Trees",
                                    xlim=range(xpos)*c(0.9,1.05),col=cols[1],
                                    ylab="",ylim=c(0,0.35),axes=F, add=T,pch=17))
      axis(side=1,at=xpos,labels=nloci)
      axis(side=2,ylim=c(0,0.5))
      mtext("Mean RF distance", line=2.5,side=2,las=0)
      lines(meanplot,col=cols[1],lty=ltys[add+1])
    }
  }
}

legend(x=log(600),y=0.17,lty=ltys[2:1],bty="n",
       legend=c(expression(gamma==0.3),expression(gamma==0.1)))
legend(x=log(700),y=0.13,pch=c(17,16),col=cols[1:2],bty="n",legend=c("NJst","ASTRAL"))
dev.off()


## legend with tree plots
#pdf(paste("freqency.pdf",sep=""), width=8,height=5)
setEPS()
postscript(paste("freqency.eps",sep=""), width=8,height=5)
layout(matrix(c(rep(1,2),rep(2,2),5,6,rep(3,2),rep(4,2),7,8),2,6,byrow=T))
par(mar=c(2,2,2,1.1), mgp=c(1.5,.5,0), tck=-0.01, las=1,
    oma=c(2,2,0,0))
#cols2=grey(c(1,0.9,0.7,0.4,0))
#cols2=colors()[c(1,444,498,258,100)]
cols2=colors()[c(1,445,498,24,136)]
for (m in method) {
  for (g in gamma) {
    load(paste(g,"_alltable",m,".Rda",sep=""))
    add=F
    if (g==.3) add=T
    freqs=matrix(c(alltable$freqtruetree,alltable$freq2ndtree,alltable$freq3rdtree,
                   alltable$freq4thtree,alltable$freqothertree),ncol=7,byrow=T)
    colnames(freqs)=c(10,20,50,100,200,500,"10k")
    rownames(freqs)=c("freqtruetree","freq2ndtree","freq3rdtree","freq4thtree",
                      "freqothertree")
    freqs=as.table(freqs)
    #par(mar=c(5, 4, 4, 2), xpd=TRUE)
    #par(mar=c(5, 4, 4, 2) + 0.1)  #restore the default
    barplot(freqs,main="",xlab="",ylab="",col=cols2,bty="L")
    mtext(bquote(gamma== .(g)), adj=0.5)

    if (m == "astral") {
      mtext("ASTRAL",side=3,adj=0,line=0.5)
    } else {
      mtext("NJst",side=3,adj=0,line=0.5)
    }

  }
}
  mtext("Number of Gene Trees",side=1,line=0,outer=T,adj=0.3)
  mtext("Frequency",side=2,line=0,las=0,outer=T)
  #par(mar=c(0,0,0,0))
  #plot(0:1,0:1, type="n",axes=F,xlab="",ylab="")
  #legend("center", legend=c("truetree","2ndtree","3rdtree","4thtree",
  #"othertree"),pch=0,fill=cols2,horiz=T,cex=1,bty="n")

  t=read.tree(text=toString(read.table("truetree.tre")[1,1]))
  t21=read.tree(text=toString(read.table("2ndtree.tre")[1,1]))
  t22=read.tree(text=toString(read.table("2ndtree.tre")[2,1]))
  t31=read.tree(text=toString(read.table("3rdtree.tre")[1,1]))
  t32=read.tree(text=toString(read.table("3rdtree.tre")[2,1]))
  t4=read.tree(text=toString(read.table("4thtree.tre")[1,1]))

  par(xpd=TRUE)
  plot(t,type = "phylogram",cex=1.2,font=1)
  legend(0.9,6.6,legend="true tree",pch=0,horiz=F,bty="n",pt.cex=1.5)

  plot(t21,type = "phylogram",cex=1.2,font=1)
  legend(1.25,6.6,legend="type a",pch=22,horiz=F,bty="n",pt.cex=1.8,pt.bg = cols2[2])
  #legend(1.25,6.6,legend="type a",pch=15,col="black",horiz=F,bty="n",pt.cex=1.8,pt.bg = cols2[2])
  #legend(x=4,y=6.47,legend="6",horiz=F,bty="n",cex=1.2)
  #legend(x=4,y=5.47,legend="5",horiz=F,bty="n",cex=1.2)
  legend(x=4,y=4.47,legend="(3)",horiz=F,bty="n",cex=1.2)
  legend(x=4,y=3.47,legend="(4)",horiz=F,bty="n",cex=1.2)
  #legend(x=4,y=2.47,legend="2",horiz=F,bty="n",cex=1.2)
  #legend(x=4,y=1.47,legend="1",horiz=F,bty="n",cex=1.2)

  plot(t31,type = "phylogram",cex=1.2,font=1)
  legend(1.25,6.6,legend="type b",pch=22,horiz=F,bty="n",pt.cex=1.8,pt.bg = cols2[3])
  legend(0.9,0.7,legend="other trees",pch=22,horiz=F,bty="n",pt.cex=1.8,pt.bg = cols2[5])
  #legend(x=4,y=6.48,legend="6",horiz=F,bty="n",cex=1.2)
  #legend(x=4,y=5.48,legend="5",horiz=F,bty="n",cex=1.2)
  legend(x=4,y=4.47,legend="(3)",horiz=F,bty="n",cex=1.2)
  legend(x=4,y=3.47,legend="(4)",horiz=F,bty="n",cex=1.2)
  #legend(x=4,y=2.47,legend="2",horiz=F,bty="n",cex=1.2)
  #legend(x=4,y=1.47,legend="1",horiz=F,bty="n",cex=1.2)

  plot(t4,type = "phylogram",cex=1.2,font=1)
  legend(1.25,6.6,legend="type c",pch=22,pt.bg =cols2[4],horiz=F,bty="n",pt.cex=1.8)

  #legend(0.5,0.5,legend=c("type a","type b","type c","other trees"),
  #pch=15,col=cols2[2:5],horiz=F,bty="n")

  dev.off()
