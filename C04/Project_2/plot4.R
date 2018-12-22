library(data.table)
library(ggplot2)
library(dplyr)

path <- getwd()
download.file(url = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
              , destfile = paste(path, "dataFiles.zip", sep = "/"))
unzip(zipfile = "dataFiles.zip")

NEI <- as.data.table(x = readRDS(file = "summarySCC_PM25.rds"))
SCC <- as.data.table(x = readRDS(file = "Source_Classification_Code.rds"))

# Subset coal combustion related NEI data
combSCC <- grepl("comb", SCC[, SCC.Level.One], ignore.case=TRUE)
coalSCC <- grepl("coal", SCC[, SCC.Level.Four], ignore.case=TRUE) 
combustionSCC <- SCC[combSCC & coalSCC, SCC]
combustionNEI <- NEI[NEI[,SCC] %in% combustionSCC]

ggplot(combustionNEI,aes(x = factor(year),y = Emissions)) +
  geom_bar(stat="identity", fill ="mediumaquamarine", width=0.65) +
  labs(x="year", y=expression("Coal combustion emissions")) + 
  labs(title=expression("Coal Combustion Source Emissions (1999-2008)"))

dev.copy(png, file="plot4.png", height=480, width=480)
dev.off()

# Question 4: Across the United States, how have emissions 
# from coal combustion-related sources changed from 1999–2008?
# Answer: There has been an overal Coal Combustion source emissions
# decrease from 1999 to 2008
