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
barplot(toplot, main=testdir, horiz=TRUE, xlab="Time (s)",
        names.arg=gsub('([[:alpha:]]*-[0-9]*-[0-9]*-[0-9]*-)', '\\1\n', configs),
        cex.names=0.6, las=0)

dev.off()
