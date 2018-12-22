library(data.table)

path <- getwd()
download.file(url = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
              , destfile = paste(path, "dataFiles.zip", sep = "/"))
unzip(zipfile = "dataFiles.zip")

NEI <- as.data.table(x = readRDS(file = "summarySCC_PM25.rds"))
SCC <- as.data.table(x = readRDS(file = "Source_Classification_Code.rds"))

NEI[, Emissions := lapply(.SD, as.numeric), .SDcols = c("Emissions")]
totalNEI <- NEI[fips=='24510', lapply(.SD, sum, na.rm = TRUE), .SDcols = c("Emissions"), by = year]


barplot(totalNEI[, Emissions],
        names = totalNEI[, year],
        xlab = "Years", ylab = "Emissions",
        main = "Baltimore Emissions over 10 Years")

dev.copy(png, file="plot2.png", height=480, width=480)
dev.off()

# Question 2: Have total emissions from PM2.5 decreased in the Baltimore City, Maryland 
# (fips == "24510"|}fips=="24510") from 1999 to 2008? 
# Use the base plotting system to make a plot answering this question.
# Answer: Overall the Baltimore emissions decreased from 1999 to 2008 but they did increase
# between 2002 and 2005