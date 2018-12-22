library(data.table)
library(ggplot2)

path <- getwd()
download.file(url = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
              , destfile = paste(path, "dataFiles.zip", sep = "/"))
unzip(zipfile = "dataFiles.zip")

NEI <- as.data.table(x = readRDS(file = "summarySCC_PM25.rds"))
SCC <- as.data.table(x = readRDS(file = "Source_Classification_Code.rds"))

baltimoreNEI <- NEI[fips=="24510",]
# Subset coal combustion related NEI data
mvRelated <- grepl("vehicles", SCC[, SCC.Level.Three], ignore.case=TRUE)
mvSCC <- SCC[mvRelated, SCC]
mvNEI <- baltimoreNEI[baltimoreNEI[,SCC] %in% mvSCC]


ggplot(baltimoreNEI,aes(x = factor(year),y = Emissions)) +
  geom_bar(stat="identity", fill ="plum3", width=0.65) +
  labs(x="Year", y=expression("Motor Vehicle Emisssions")) + 
  labs(title=expression("Baltimore City Motor Vehicle emissions 1999-2008"))

dev.copy(png, file="plot5.png", height=480, width=480)
dev.off()

# Question 5: How have emissions from motor vehicle sources
# changed from 1999–2008 in Baltimore City? 
# Answer: Overall the the motor vehicle emissions in Baltimore have decreased over the 10 years.
