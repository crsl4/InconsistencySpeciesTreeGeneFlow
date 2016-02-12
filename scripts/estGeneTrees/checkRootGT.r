# r script that will read the .con.tre files in each
# mrbayes/gamma0.3_n* path and will root them in the
# correct outgroup
# Claudia September 2015
# modified to root estimated trees from raxml.out file
# Claudia January 2016


library(ape)
gamma = c(0.1,0.3)
nloci=c(10,20,50,100,200,500,1000)
nrep = 100

for(g in gamma){
    for(n in nloci){
        for(irep in 1:nrep){
            raxmlout = paste0("raxml/gamma",g,"_n",n,"/",irep,"_raxml.out")
            outfile = paste0("raxml/gamma",g,"_n",n,"/",irep,"_raxmlRoot.out")
            print(raxmlout)
            tre = read.tree(file=raxmlout)
            for(i in 1:length(tre)){
                #print("is rooted?")
                #b = is.rooted(tre[[i]])
                #print(b)
                Rtre = root(tre[[i]],"6",r=TRUE)
                write.tree(Rtre,file=outfile,append=TRUE)
            }
        }
    }
}
