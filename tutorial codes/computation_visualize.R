##### Read Package for reading Python output (pickle) --------------------------
library(reticulate)
#py_install("pandas")
pd <- import("pandas")

library(ggplot2)

#####
computation <- pd$read_pickle("out/computation")

computation$n_reps <- as.numeric(computation$n_reps)
computation$n_routes <- as.numeric(computation$n_routes)
computation$m_dist <- as.numeric(computation$m_dist)
computation$time <- as.numeric(computation$time)

computation_df <- data.frame("Repetition"=c(computation$n_reps), "Possible Routes"=c(computation$n_routes), "Manhattan Distance"=c(computation$m_dist), "time"=c(computation$time))
computation_df$Repetition[computation_df$Repetition==100] <- "B=100"
computation_df$Repetition[computation_df$Repetition==1000] <- "B=1000"
computation_df$Repetition[computation_df$Repetition==10000] <- "B=10000"
computation_df$Repetition[computation_df$Repetition==100000] <- "B=100000"

computation_df <- computation_df[order( computation_df[,3], computation_df[,2] ),]

computation_df$Repetition <- as.factor(computation_df$Repetition)
computation_df$Repetition <- factor(computation_df$Repetition, levels = c("B=100", "B=1000", "B=10000", "B=100000"))

number_ticks <- function(n) {function(limits) pretty(limits, n)}

ggplot(data=computation_df, aes(x=Possible.Routes, y=time, group = Repetition)) + 
  geom_line(data=computation_df, aes(color = Repetition, linetype = Repetition), size = 1) + 
  geom_point(data=computation_df, aes(color = Repetition, shape = Repetition), size = 3) +
  theme(axis.title=element_text(size=14), axis.text=element_text(size=12), legend.title=element_text(size=14), legend.text=element_text(size=12)) + 
  xlab("Number of available routes") + ylab("Time(seconds)") + scale_x_continuous(breaks=number_ticks(10)) +
  ggsave("result/computation_time_Available_routes.png")

ggplot(data=computation_df, aes(x=Manhattan.Distance, y=time, group = Repetition)) + 
  geom_line(data=computation_df, aes(color = Repetition, linetype = Repetition), size = 1) + 
  geom_point(data=computation_df, aes(color = Repetition, shape = Repetition), size = 3) +
  theme(axis.title=element_text(size=14), axis.text=element_text(size=12), legend.title=element_text(size=14), legend.text=element_text(size=12)) + 
  xlab("Manhattan Distance") + ylab("Time(seconds)") + scale_x_continuous(breaks=number_ticks(10))+
  ggsave("result/computation_time_Manhattan_Distance.png")

computation_df$Manhattan.Distance <- computation_df$Manhattan.Distance+1

ggplot(data=computation_df, aes(x=Manhattan.Distance, y=time, group = Repetition)) + 
  geom_line(data=computation_df, aes(color = Repetition, linetype = Repetition), size = 1) + 
  geom_point(data=computation_df, aes(color = Repetition, shape = Repetition), size = 3) +
  theme(axis.title=element_text(size=14), axis.text=element_text(size=12), legend.title=element_text(size=14), legend.text=element_text(size=12)) + 
  xlab("Route Length") + ylab("Time(seconds)") + scale_x_continuous(breaks=number_ticks(10))+
  ggsave("result/computation_time_Route_Length.png")
