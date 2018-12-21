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

par(mfrow=c(2,2))

# line plot
with(d, {
  # top left plot
  plot(dateTime, Global_active_power, type="l", xlab="", ylab="Global Active Power (kilowatts)")
  # top right plot
  plot(dateTime, Voltage, type = "l", xlab = "datetime", ylab = "Voltage")
  # bottom left plot
  plot(dateTime, Sub_metering_1, col = "black", type="l", xlab = "", ylab = "Energy sub metering")
  lines(dateTime, Sub_metering_2, col = "Red")
  lines(dateTime, Sub_metering_3, col = "Blue")
  legend("topright",
         legend= c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), 
         col=c("black","red","blue"), lty=c(1,1), lwd=1, bty="n", cex=.5)
  # bottom right plot
  plot(dateTime, Global_reactive_power, type = "l", xlab = "datetime", ylab = "Global Rective Power")
  })

# png file
dev.copy(png, file="plot4.png", height=480, width=480)
dev.off()
