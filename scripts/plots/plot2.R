library(plotrix)
library(phybase)
#library(ape)
gamma=c(0.1,0.3)
method=c("concat","astral","njst","phylonet")
cols=colors()[c(498,24,136)]
cols=c(cols[1:2],grey(0.5),cols[3 ])
ltys=c(1,2)
pchs = c(1, 16,17,15)
nloci=c(10,20,50,100,200,500,1000)
xpos = log(nloci)

pdf(paste("meandist_estGT.pdf",sep=""), width=6, height=5)
setEPS()
postscript(paste("meandist_estGT.eps",sep=""), width=6, height=5)
par(mar=c(3.1,3.6,.5,.5), mgp=c(1.5,.5,0), tck=-0.01, las=1, yaxs="r", xaxs="r")

i = 1
for (m in method) {
    for (g in gamma) {
        load(paste0(g,"_alltable",m,".Rda"))
        add=F
        l=F
        if (m == "concat") {
            if (g == 0.3) add=T
            meanplot=with(alltable,plotCI(xpos+0.05*(-1+i),meandist,sddist/10,
                main ="",xlab="Number of Genes",
                xlim=range(xpos)*c(0.9,1.05),col=cols[i],
                ylab="",ylim=c(0,0.7),axes=F, add=add,pch=pchs[i]))
            axis(side=1,at=xpos,labels=nloci)
            axis(side=2,ylim=c(0,0.7))
            mtext("Mean RF distance", line=2.5,side=2,las=0)
            lines(meanplot,col=cols[i],lty=ltys[add+1])
        } else {
            add=T
            if (g==0.3) l=T
            meanplot=with(alltable,plotCI(xpos+0.05*(1-i),meandist,sddist/10,
                main ="",xlab="Number of Genes",
                xlim=range(xpos)*c(0.9,1.05),col=cols[i],
                ylab="",ylim=c(0,0.7),axes=F, add=T,pch=pchs[i]))
            #axis(side=1,at=xpos,labels=nloci)
            #axis(side=2,ylim=c(0,0.5))
            #mtext("Mean RF distance", line=2.5,side=2,las=0)
            lines(meanplot,col=cols[i],lty=ltys[l+1])
        }
    }
    i = i+1
}

legend(x=log(15),y=0.7,lty=ltys[2:1],bty="n",
       legend=c(expression(gamma==0.3),expression(gamma==0.1)), horiz=TRUE)
legend(x=log(7),y=0.73,pch=pchs[1],col=cols[1],bty="n",legend=c("concatenation"), horiz=TRUE)
legend(x=log(30),y=0.73,pch=pchs[2],col=cols[2],bty="n",legend=c("ASTRAL"), horiz=TRUE)
legend(x=log(80),y=0.73,pch=pchs[3],col=cols[3],bty="n",legend=c("NJst"), horiz=TRUE)
legend(x=log(160),y=0.73,pch=pchs[4],col=cols[4],bty="n",legend=c("PhyloNet"), horiz=TRUE)
dev.off()
# -----------------------------------------------------------------------------------
library(plotrix)
library(phybase)
#library(ape)
gamma=c(0.1,0.3)
method=c("concat","astral", "njst")

## legend with tree plots
#cols2=grey(c(1,0.9,0.7,0.4,0))
#cols2=colors()[c(1,444,498,258,100)]
cols2=colors()[c(1,103,51,24,136)]

m2 = matrix(c(7,7,7,1,3,5,2,4,6),nrow=3,ncol=3,byrow=T)
w=c(0.33,0.33,0.33)
h=c(0.1,0.45,0.45)

pdf(paste("freqency_estGT.pdf",sep=""), width=7.5,height=6)
setEPS()
postscript(paste("freqency_estGT.eps",sep=""), width=7.5,height=6)

layout(mat=m2,widths=w,heights=h)
par(mar=c(2,2,2,0), mgp=c(1.5,.5,0), tck=-0.01, las=1,
    oma=c(2,2,0,0))
for (m in method) {
    for (g in gamma) {
        load(paste(g,"_alltable",m,"_BS.Rda",sep=""))
        add=F
        if (g==.3) add=T
        freqs=matrix(c(alltable$freqtruetree,alltable$freq2ndtree,alltable$freqothertree),ncol=7,byrow=T)
        colnames(freqs)=c(10,20,50,100,200,500,"1k")
        rownames(freqs)=c("freqtruetree","freq2ndtree","freqothertree")
        freqs=as.table(freqs)
        barplot(freqs,main="",xlab="",ylab="",col=cols2,bty="L")
        mtext(bquote(gamma== .(g)), adj=0.5)
        if (m == "astral" && g == 0.1) {
            mtext("ASTRAL",side=3,adj=0.5,line=1.5)
        } else if(m == "njst" && g==0.1) {
            mtext("NJst",side=3,adj=0.5,line=1.5)
        } else if(m == "concat" && g==0.1) {
            mtext("Concatenation",side=3,adj=0.5,line=1.5)
        }
    }
}

mtext("Number of Genes",side=1,line=0,outer=T,adj=0.53)
mtext("Mean Boostrap support",side=2,line=0,las=0,outer=T)
par(mar=c(0,0,0,0))
plot(1, type = "n", axes=FALSE, xlab="", ylab="")
legend(x=0.7,y=1.4,legend="34|1256", pch=0,pt.cex=3.5,pt.bg=cols2[1],horiz=T,bty="n",cex=1.5)
legend(x=0.85,y=1.4,legend="123|456 or 124|356", pch=22,pt.cex=3.5,pt.bg=cols2[2],horiz=T,bty="n",cex=1.5)
legend(x=1.11,y=1.4,legend="other", pch=22,pt.cex=3.5,pt.bg=cols2[3],horiz=T,bty="n",cex=1.5)

dev.off()
