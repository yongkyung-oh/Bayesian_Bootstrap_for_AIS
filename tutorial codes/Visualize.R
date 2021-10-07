##### Read Package for reading Python output (pickle) --------------------------
library(reticulate)
#py_install("pandas")
pd <- import("pandas")

grid_example <- pd$read_pickle("grid_example_normal")
grid_example_df <- data.frame(grid_example)
grid_example_df[,1] <- as.factor(grid_example_df[,1]+1)
grid_example_df[,2] <- grid_example_df[,2]/sum(grid_example_df[,2])

grid_example_df <- data.frame("Route" = grid_example_df[,1], "Percentage" = grid_example_df[,2])

library(ggplot2)
p<-ggplot(data=data.frame(grid_example_df), aes(x=Route, y=Percentage)) + geom_bar(stat="identity") + geom_text(aes(label=sprintf("%0.2f", round(Percentage, digits = 2))), vjust=-0.5, size=3.5) + 
  theme(axis.title=element_text(size=14), axis.text=element_text(size=12), legend.title=element_text(size=14), legend.text=element_text(size=12))
p
