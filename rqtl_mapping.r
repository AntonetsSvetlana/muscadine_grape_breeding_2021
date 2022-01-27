cross_6 <- read.cross("csvr", ".", "cross_6.csvr")
summary(cross_6)
plotMissing(cross_6)
par(mfrow=c(1,2), las=1)
plot(ntyped(cross_6), ylab="No. typed markers", main="No. genotypes by individual")
plot(ntyped(cross_4, "mar"), ylab="No. typed individuals", main="No. genotypes by marker")
cross_7 <- subset(cross_6, ind=(ntyped(cross_6)>50000))
nt.bymar <- ntyped(cross_7, "mar")
todrop <- names(nt.bymar[nt.bymar < 20])
cross_8 <- drop.markers(cross_7, todrop)
cg <- comparegeno(cross_8)
hist(cg[lower.tri(cg)], breaks=seq(0, 1, len=101), xlab="No. matching genotypes")
rug(cg[lower.tri(cg)])
wh <- which(cg > 0.8, arr=TRUE)
wh <- wh[wh[,1] < wh[,2],]
wh
g <- pull.geno(cross_8)
for(i in 1:nrow(wh)) {
    tozero <- !is.na(g[wh[i,1],]) & !is.na(g[wh[i,2],]) & g[wh[i,1],] != g[wh[i,2],]
    mapthis$geno[[1]]$data[wh[i,1],tozero] <- NA
}
nmar(cross_8)
cross_9 <- subset(cross_8, ind=-wh[,2])
duplicated_markers <- findDupMarkers(cross_9, exact.only=FALSE)
capture.output(duplicated_markers, file = "duplicated_markers.txt")
gt <- geno.table(cross_9)
gt[gt$P.value < 0.05/totmar(cross_9),]
todrop <- rownames(gt[gt$P.value < 1e-15,])
cross_10 <- drop.markers(cross_9, todrop)
g <- pull.geno(cross_10)
gfreq <- apply(g, 1, function(a) table(factor(a, levels=1:3)))
gfreq <- t(t(gfreq) / colSums(gfreq))
par(mfrow=c(1,3), las=1)
for(i in 1:3) {
    plot(gfreq[i,], ylab="Genotype frequency", main=c("AA", "AB", "BB")[i],
         ylim=c(0,1))
}
### Next - example for the 20th chromosome
chr20 <- subset(cross_10, 20) 
chr20_rf <- est.rf(chr20)
checkAlleles(chr20_rf, threshold=5)
rf <- pull.rf(chr20_rf)
lod <- pull.rf(chr20_rf, what="lod")
plot(as.numeric(rf), as.numeric(lod), xlab="Recombination fraction", ylab="LOD score")
lg <- formLinkageGroups(chr20_rf, max.rf=0.35, min.lod=6)
chr20_link <- formLinkageGroups(chr20_rf, max.rf=0.35, min.lod=6, reorgMarkers=TRUE)
plotRF(chr20_link, alternate.chrid=TRUE)

