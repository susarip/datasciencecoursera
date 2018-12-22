library(data.table)

path <- getwd()
download.file(url = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
              , destfile = paste(path, "dataFiles.zip", sep = "/"))
unzip(zipfile = "dataFiles.zip")

NEI <- as.data.table(x = readRDS(file = "summarySCC_PM25.rds"))
SCC <- as.data.table(x = readRDS(file = "Source_Classification_Code.rds"))

NEI[, Emissions := lapply(.SD, as.numeric), .SDcols = c("Emissions")]

totalNEI <- NEI[, lapply(.SD, sum, na.rm = TRUE), .SDcols = c("Emissions"), by = year]

barplot(totalNEI[, Emissions],
        names = totalNEI[, year],
        xlab = "Years", ylab = "Emissions",
        main = "Emissions over Ten Years")

dev.copy(png, file="plot1.png", height=480, width=480)
dev.off()

# Question 1: Have total emissions from PM2.5 decreased in the United States from 1999 to 2008? 
# Using the base plotting system, make a plot showing the total PM2.5 emission from all sources 
# for each of the years 1999, 2002, 2005, and 2008.
# Answer: Emissions have definitely decreased from 1999 to 2008