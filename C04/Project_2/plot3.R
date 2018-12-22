library(data.table)
library(ggplot2)
library(dplyr)

path <- getwd()
download.file(url = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
              , destfile = paste(path, "dataFiles.zip", sep = "/"))
unzip(zipfile = "dataFiles.zip")

NEI <- as.data.table(x = readRDS(file = "summarySCC_PM25.rds"))
SCC <- as.data.table(x = readRDS(file = "Source_Classification_Code.rds"))


# Subset NEI data by Baltimore
baltimoreNEI <- NEI[fips=="24510",]

tidyBaltimore <- baltimoreNEI %>%
  group_by(type,year) %>%
  summarise(Emissions = sum(Emissions))
g <- ggplot(data = tidyBaltimore, aes(x = factor(year), Emissions, color = type))
g + geom_line(aes(group = type)) + geom_point() + guides(fill=FALSE)+
  labs(x="year", y=expression("Total PM"[2.5]*" Emission (Tons)")) + 
  labs(title=expression("Baltimore City Emissions by Source Type (1999-2008)"))

dev.copy(png, file="plot3.png", height=480, width=480)
dev.off()

# Question 3: Of the four types of sources indicated by the type (point, nonpoint, onroad, nonroad) 
# variable, which of these four sources have seen decreases in emissions from 1999–2008 
# for Baltimore City? Which have seen increases in emissions from 1999–2008? 
# Use the ggplot2 plotting system to make a plot answer this question.
# Answer: Everything except Point emissions have reduced in Baltimore between 1999 and 2008.
# Point emisions are also the only ones that follow a different pattern than the other three.
# The other three decrease significantly between 1999 and 2002, stay fairly stagnant for 3 years
# and then drop a little more from 2005 to 2008. Point emissions increase drastically between 
# 1999 and 2002 and then increase even more drastically between 2002 and 2005. 