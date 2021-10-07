##### Read Package for reading Python output (pickle) --------------------------
library(reticulate)
#py_install("pandas")
pd <- import("pandas")

## Read Python code Output
best_route_list <- pd$read_pickle("out_exp/grid_best_route")
available_route_list_normal <- pd$read_pickle("out_exp/available_route_list_normal")
available_route_list_noise <- pd$read_pickle("out_exp/available_route_list_noise")
available_route_list_missing <- pd$read_pickle("out_exp/available_route_list_missing")

exp_grid_list <- pd$read_pickle("out_exp/exp_grid_list")


##### Use Packages  ------------------------------------------------------------
#library(gdistance)
library(raster)
#library(MCMCpack)
#library(ggplot2)

par(mar = c(2,3,2,0))
status <- c('(Normal)', '(Noise)', '(Missing)')

for (i in 1:length(exp_grid_list)){
  grid <- exp_grid_list[[i]]
  n <- nrow(grid)
  m <- ncol(grid)
  
  r1 <- raster(grid, xmn=0, xmx=m, ymn=0, ymx=n, crs=NA)
  plot(r1, axes=FALSE, box=FALSE, legend=FALSE)
  text(r1, cex=2)
  
  # Draw each cases
  if (i == 1){
    route_list <- available_route_list_normal
  }
  else if (i == 2){
    route_list <- available_route_list_noise
  } 
  else if (i ==3){
    route_list <- available_route_list_missing
  }
  
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
  route_list <- best_route_list
  
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