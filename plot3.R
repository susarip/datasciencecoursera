library(dplyr)
library(ggplot2)
setwd("/Users/susmithasaripalli/Documents/GitHub/datasciencecoursera/C04/Project 1")

# load data
d <- read.csv("household_power_consumption.txt", header=T, sep=';', na.strings="?", stringsAsFactors=F, comment.char="", quote='\"')
d$Date <- as.Date(d$Date, format="%d/%m/%Y")

# subset the data
d <- subset(d, subset=(Date >= "2007-02-01" & Date <= "2007-02-02"))

# make dateTime as a POSIXct class
d$dateTime <- as.POSIXct(paste(d$Date, d$Time))

# line plot
with(d, {
  plot(dateTime,
       Sub_metering_1,
       xlab="",
       ylab="Energy sub metering",
       type="l",
       col="black")
  lines(dateTime, Sub_metering_2, col = "red")
  lines(dateTime, Sub_metering_3, col="blue")
})
legend("topright", lty = 1, lwd=2, 
       legend= c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), 
       col=c("black","red","blue"))
# png file
dev.copy(png, file="plot3.png", height=480, width=480)
dev.off()