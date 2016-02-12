library(phybase)
#library(ape)
gamma=c(0.1,0.3)
nloci=c(10,20,50,100,200,500,1000)
bip1=read.tree(text="((3,4),1,2,5,6);")
bip2=read.tree(text="((1,2,3),4,5,6);")
bip3=read.tree(text="((1,2,4),3,5,6);")
freqbip1=rep(0,100)
freqbip2=rep(0,100)
freqbip3=rep(0,100)
others=rep(0,100)
bootstrapAll = data.frame(matrix(0,ncol=100,nrow=4))

maindir ="njst"

for (g in gamma) {
    for (n in nloci) {
        dir = paste0("gamma",g,"_n",n)
        for (i in 1:100) {
            if(maindir != "raxml"){
                filename = paste0(maindir,"/",dir,"/",i,"_",maindir,".out")
            } else {
                filename = paste0(maindir,"/",dir,"/RAxML_bootstrap.",i,"_raxml_concat")
            }
            list = read.tree(file = filename)
            if(maindir != "raxml"){
                list = list[1:100]
            }
            j=1
            for(t in list){
                rt <- root(t,"6",resolve=TRUE)
                if(j == 1){
                    sum1 = prop.clades(bip1,rt,rooted=TRUE)
                    sum2 = prop.clades(bip2,rt,rooted=TRUE)
                    sum3 = prop.clades(bip3,rt,rooted=TRUE)
                } else {
                    sum1 = sum1 + prop.clades(bip1,rt,rooted=TRUE)
                    sum2 = sum2 + prop.clades(bip2,rt,rooted=TRUE)
                    sum3 = sum3 + prop.clades(bip3,rt,rooted=TRUE)
                }
                j=j+1
            }
            freqbip1[i] = sum1[2]
            freqbip2[i] = sum2[2]
            freqbip3[i] = sum3[2]
            others[i] = 100 - freqbip1[i] - freqbip2[i] - freqbip3[i]
        }
        bootstrapAll[1,] = freqbip1
        bootstrapAll[2,] = freqbip2
        bootstrapAll[3,] = freqbip3
        bootstrapAll[4,] = others
        colnames(bootstrapAll) = c(1:100)
        rownames(bootstrapAll) = c("34|1256","123|456","124|356","others")
        save(bootstrapAll,file=paste0(maindir,"/",dir,"/bootstrapAll.Rda"))
        write.table(bootstrapAll,file=paste0(maindir,"/",dir,"/bootstrapAll.txt"),sep=",",row.names=FALSE)
    }
}
