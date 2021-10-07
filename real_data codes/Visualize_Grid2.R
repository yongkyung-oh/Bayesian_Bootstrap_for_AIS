##### Read Package for reading Python output (pickle) --------------------------
library(reticulate)
#py_install("pandas")
pd <- import("pandas")

grid2_available_route_list <- pd$read_pickle("out_exp/grid2_available_route_list")
grid2_best_route_list <- pd$read_pickle("out_exp/grid2_best_route_list")

exp_grid_list2 <- pd$read_pickle("out_exp/exp_grid_list2")


par(mar = c(2,2,2,2))

for (i in 1:length(exp_grid_list2)){
  grid <- exp_grid_list2[[i]]
  n <- nrow(grid)
  m <- ncol(grid)
  
  r1 <- raster(grid, xmn=0, xmx=m, ymn=0, ymx=n, crs=NA)
  plot(r1, main = paste("Grid 2"), axes=FALSE, box=FALSE, legend=FALSE)
  text(r1, cex=1.5)
  
  # Draw each cases
  route_list <- grid2_available_route_list
  
  print(length(route_list))
  
  for (j in 1:length(route_list)){
    best_path <- route_list[[j]]$path
    best_route <- matrix(0, length(best_path), 2)
    
    for (k in 1:length(best_path)){
      best_route[k, 2] <- n-best_path[[k]][[1]] - 0.5
      best_route[k, 1] <- best_path[[k]][[2]] + 0.5
    }
    
    s_path <- spLines(best_route)
    lines(s_path, col = rgb(red = 0, green = 0, blue = 0, alpha = 0.3), lwd = 1)
  }
  
  # Draw best route
  route_list <- grid2_best_route_list
  
  for (j in 1:length(route_list)){
    best_path <- route_list[[j]]$path
    best_route <- matrix(0, length(best_path), 2)
    
    for (k in 1:length(best_path)){
      best_route[k, 2] <- n-best_path[[k]][[1]] - 0.5
      best_route[k, 1] <- best_path[[k]][[2]] + 0.5
    }
    
    s_path <- spLines(best_route)
    lines(s_path, col = rgb(red = 0, green = 0, blue = 0, alpha = 1.0), lwd = 2)
  }
  
}


grid2_example <- pd$read_pickle("out_exp/grid2_example")
grid2_example_df <- data.frame(grid2_example)
grid2_example_df[,1] <- as.factor(grid2_example_df[,1]+1)
grid2_example_df[,2] <- round(grid2_example_df[,2]/sum(grid2_example_df[,2]), 2)

grid2_example_df <- data.frame("Route" = grid2_example_df[,1], "Percentage" = grid2_example_df[,2])

library(ggplot2)
p<-ggplot(data=data.frame(grid2_example_df), aes(x=Route, y=Percentage)) + geom_bar(stat="identity") + geom_text(aes(label=Percentage), vjust=-0.5, size=4.5) + 
  theme(axis.title=element_text(size=14), axis.text=element_text(size=12), legend.title=element_text(size=14), legend.text=element_text(size=12))
p