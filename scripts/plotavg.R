args <- commandArgs(trailingOnly = TRUE)
print(args)

testdir <- args[1]

gsub("(^ +)|( +$)", "", testdir)

configsfile <- paste(testdir, "configs", sep="/")
print(configsfile)

configs <- scan(configsfile, what="")

toplot <- vector()
for (samplefile in configs) {
  sfpath <- paste(testdir, "/result-", samplefile, ".dat", sep="", collapse="")
  print(sfpath)
  samples <- scan(sfpath, list(real=0, cpu=0), comment.char="<")
  toplot <- c(toplot, mean(samples$real))
}

svg(paste(testdir, "/avg.svg", sep=""))
par(mar = c(7, 4, 4, 2) + 0.1)
plot(toplot, type="b", main=testdir, ylab="Time (s)", xlab="", axes=FALSE)
#45 deg rotated tick labels on X axis
#axis(1, at=1:length(configs), labels=F)
#text(x=1:length(configs), par("usr")[3] - 0.04, srt=45, adj=1, labels=configs,
#     cex=0.6, pos=1, xpd=TRUE)


axis(1, at=1:length(configs), labels=configs, cex.axis=0.5, las=2)
axis(2)
dev.off()
