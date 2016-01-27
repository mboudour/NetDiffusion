
library(rPython)

python.load("2ModeTwitterNetworkGenerator.py")

library(netdiffuseR)
# rm(list=ls())
library(Matrix) # For coercing into sparse matrix format
library(stringr) # For (nice) text processing

# This part is for parsing the array
readPyArray <- function(x, as_dgCMatrix=TRUE) {
  # Importing data into R
  dat <- readLines(x)

  # Finding the boudaries of each adjmat
  index <- matrix(which(grepl("^(\\[[0-9]+|\\])$", dat)), ncol=2, byrow = TRUE)

  # Empty list to be filled
  graph <- vector("list", nrow(index))
  for (i in 1:nrow(index)) {

    # Subsetting matrix
    tmp <- index[i, ,drop=TRUE]
    tmp <- dat[(tmp[1] + 1):(tmp[2]-1)]

    # Cleaning and coercing into rows
    tmp <- stringr::str_replace_all(tmp, "\\[|\\]", "")
    tmp <- lapply(tmp, function(x) as.numeric(strsplit(x, ",")[[1]]))

    # Coercing into a matrix
    graph[[i]] <- do.call(rbind, tmp)

    if (as_dgCMatrix)
      graph[[i]] <- methods::as(graph[[i]], "dgCMatrix")
  }

  # Naming the adjmats
  names(graph) <- gsub("^\\[", "", dat[index[,1]])
  message("The file ", x," has been processed sussecsfully.")
  graph
}

# Reading data into R
graph <- readPyArray("List_of_Graphs1.txt")
toa <- readLines("toa1.txt")
toa <- as.numeric(strsplit(stringr::str_replace_all(toa, "\\[|\\]", ""), ",")[[1]])

# Checking size of the slices
str(lapply(graph, dim))

# Truncating the range of toa (so it fits the data!)
# toa[which(toa == max(toa, na.rm = TRUE))] <- 11

diffnet <- as_diffnet(graph, toa)
diffnet

summary(diffnet)

plot_threshold(diffnet, vertex.cex = 1/4)

# Threshold with vertex size = avg degree
cex <- rowMeans(dgr(diffnet))
cex <- (cex - min(cex) + 1)/(max(cex) - min(cex) + 1)/2
plot_threshold(diffnet, vertex.cex = cex)

plot_hazard(diffnet)

plot_adopters(diffnet)

# plot_diffnet(diffnet, vertex.cex = 1, slices=c(1,4,8,12))
plot_diffnet(diffnet, vertex.cex = 2)

dat <- plot_infectsuscep(diffnet, logscale = FALSE, bins = 20, K=4)

with(dat, cor.test(infect, suscept))

summary(threshold(diffnet))


