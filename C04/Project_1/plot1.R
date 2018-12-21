library(dplyr)
library(ggplot2)
setwd("/Users/susmithasaripalli/Documents/GitHub/datasciencecoursera/C04/Project 1")

# load data
d <- read.csv("household_power_consumption.txt", header=T, sep=';', na.strings="?", stringsAsFactors=F, comment.char="", quote='\"')
d$Date <- as.Date(d$Date, format="%d/%m/%Y")

# subset the data
d <- subset(d, subset=(Date >= "2007-02-01" & Date <= "2007-02-02"))


# plot histogram
hist(d$Global_active_power, main = "Global Active Power",
     xlab = "Global Active Power (kilowatts)", ylab = "Frequency",
     col="red")

# png file
dev.copy(png, file="plot1.png", height=480, width=480)
dev.off()
