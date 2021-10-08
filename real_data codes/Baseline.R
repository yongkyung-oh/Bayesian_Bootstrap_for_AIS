##### Read Package for reading Python output (pickle) --------------------------
library(reticulate)
#py_install("pandas")
pd <- import("pandas")

## Read Python code Output
best_route_list <- pd$read_pickle("out/best_route_list")
grid_info_list <- pd$read_pickle("out/grid_info_list")


PATH_START <- c(121.46, 31.22) #(CNWGQ: 31.22N, 121.46E) 
PATH_END <- c(174.77, -36.87) #(NZAKL: 36.87S 174.77E)

PATH_START <- c(floor(PATH_START[1])+0.5, floor(PATH_START[2])+0.5)
PATH_END <- c(floor(PATH_END[1])+0.5, floor(PATH_END[2])+0.5)

ZERO = PATH_START + c(grid_info_list[[1]][1], grid_info_list[[1]][2])

important_node_list <- list()
important_node_list[[1]] <- ZERO + c(+grid_info_list[[1]][1], -grid_info_list[[1]][2])
for (i in 1:length(grid_info_list)){
  important_node_list[[i+1]] = ZERO + c(+grid_info_list[[i]][3], -grid_info_list[[i]][4])
}


##### Use Packages  ------------------------------------------------------------
#library(gdistance)
library(raster)
#library(MCMCpack)
#library(ggplot2)

## Read Grid as matrix 
grid_file_list = list.files("out", pattern="*.csv", full.names = T)
grid_list = lapply(grid_file_list, read.delim)

grid_list <- list()
for (i in 1:length(grid_file_list)){
  grid_list[[i]] <- as.matrix(data.frame(read.csv(grid_file_list[i], header = F)))
}


sPath<-list()

for (i in 1:length(grid_list)){
  grid <- grid_list[[i]]
  n <- nrow(grid)
  m <- ncol(grid)
  
  r1 <- raster(grid, xmn=0, xmx=m, ymn=0, ymx=n, crs=NA)
  plot(r1, main = paste("Grid ", i), axes=FALSE, box=FALSE, legend=FALSE)
  text(r1)
  
  best_path <- best_route_list[[i]]$path
  best_route <- matrix(0, length(best_path), 2)
  best_route2 <- matrix(0, length(best_path), 2)
  
  if (grid_info_list[[i]][5] == 1 && grid_info_list[[i]][6] == -1){
    for (j in 1:length(best_path)){
      best_route[j, 2] <- best_path[[j]][[1]] + 0.5
      best_route[j, 1] <- best_path[[j]][[2]] + 0.5
      best_route2[j, 2] <- best_path[[j]][[1]] + important_node_list[[i]][2]
      best_route2[j, 1] <- best_path[[j]][[2]] + important_node_list[[i]][1]
    }
  }
  else if (grid_info_list[[i]][5] == -1 && grid_info_list[[i]][6] == -1){
    for (j in 1:length(best_path)){
      best_route[j, 2] <- best_path[[j]][[1]] + 0.5
      best_route[j, 1] <- m-best_path[[j]][[2]] - 0.5
      best_route2[j, 2] <- best_path[[j]][[1]] + important_node_list[[i]][2]
      best_route2[j, 1] <- -best_path[[j]][[2]] + important_node_list[[i]][1]
    }
  }
  else if (grid_info_list[[i]][5] == 1 && grid_info_list[[i]][6] == 1){
    for (j in 1:length(best_path)){
      best_route[j, 2] <- n-best_path[[j]][[1]] - 0.5
      best_route[j, 1] <- best_path[[j]][[2]] + 0.5
      best_route2[j, 2] <- -best_path[[j]][[1]] + important_node_list[[i]][2]
      best_route2[j, 1] <- best_path[[j]][[2]] + important_node_list[[i]][1]
    }
  }
  else if (grid_info_list[[i]][5] == -1 && grid_info_list[[i]][6] == 1){
    for (j in 1:length(best_path)){
      best_route[j, 2] <- n-best_path[[j]][[1]] - 0.5
      best_route[j, 1] <- m-best_path[[j]][[2]] - 0.5
      best_route2[j, 2] <- -best_path[[j]][[1]] + important_node_list[[i]][2]
      best_route2[j, 1] <- -best_path[[j]][[2]] + important_node_list[[i]][1]
    }
  }
  
  s_path <- spLines(best_route)
  lines(s_path, col = rgb(0,0,0), lwd = 2)
  
  file_name = paste("out/Grid", formatC(i, width=2, flag="0"), "best_route.png", sep="_")
  png(file_name)
  plot(r1, main = paste("Grid ", i), axes=FALSE, box=FALSE, legend=FALSE)
  text(r1)
  lines(s_path, col = rgb(0,0,0), lwd = 2)
  dev.off()
  
  sPath[[i]] <- spLines(best_route2)
}

merged.lines <- do.call(rbind, sPath)

##### Plot on the map  ---------------------------------------------------------
library(devtools)
library(ggplot2)
library(ggmap)

x_min <- min(data.frame(important_node_list)[1,])
x_max <- max(data.frame(important_node_list)[1,])
y_min <- min(data.frame(important_node_list)[2,])
y_max <- max(data.frame(important_node_list)[2,])

long_all <- range(x_min, x_max)
lati_all <- range(y_min, y_max)

register_google(key="[Google_API]")
myLocation <- c(lon=as.numeric(mean(long_all)), lat=as.numeric(mean(lati_all)))

ids <- data.frame()
for (i in (1:length(merged.lines))) {
  id <- data.frame(merged.lines@lines[[i]]@ID)
  ids <- rbind(ids, id)
}

merged.lines.df <- SpatialLinesDataFrame(merged.lines, data = ids, match.ID = FALSE)
merged.lines.fortify <- fortify(merged.lines.df)

ggplot(data = merged.lines.fortify, aes(x=long, y=lat, group=group))+geom_path()

p <- ggmap(get_map(location=myLocation, zoom=3))+xlab('')+ylab('')

raw_data <- read.csv('target_raw.csv')

p+geom_point(data=raw_data , aes(x=LON, y=LAT), size=0.1)+geom_path(data = merged.lines.fortify, aes(x=long, y=lat, group=group), colour = "red", size=1)

png("map.png")
p <- ggmap(get_map(location=myLocation, zoom=3))+xlab('')+ylab('')
p+geom_point(data=raw_data , aes(x=LON, y=LAT), size=0.1)+geom_path(data = merged.lines.fortify, aes(x=long, y=lat, group=group), colour = "red", size=1)
dev.off()


