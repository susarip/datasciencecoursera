library(data.table)
library(ggplot2)
library(dplyr)
library(gridExtra)


path <- getwd()
download.file(url = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
              , destfile = paste(path, "dataFiles.zip", sep = "/"))
unzip(zipfile = "dataFiles.zip")

NEI <- as.data.table(x = readRDS(file = "summarySCC_PM25.rds"))
SCC <- as.data.table(x = readRDS(file = "Source_Classification_Code.rds"))


# motor vehicle emissions
mvRelated <- grepl("vehicles", SCC[, SCC.Level.Three], ignore.case=TRUE)
mvSCC <- SCC[mvRelated, SCC]
mvNEI <- NEI[NEI[,SCC] %in% mvSCC]

# Subset the data by city, add column of city name and add percentEm
# Percent Emission is the total emission of each city over the 10 years
# divided by the Emission of that time. 
mvBaltNEI <- mvNEI[fips == "24510",]
totBaltEm <- sum(mvBaltNEI$Emissions)
mvBaltNEI <- mvBaltNEI %>%
  mutate(city = "Baltimore")%>%
  mutate(percentEm = Emissions/totBaltEm)

mvLANEI <- mvNEI[fips == "06037",]
totLAEm <- sum(mvLANEI$Emissions)
mvLANEI <- mvLANEI %>%
  mutate(city = "LA") %>%
  mutate(percentEm = Emissions/totLAEm)


# Combine data.tables into one data.table
citiesNEI <- rbind(mvBaltNEI,mvLANEI)

citiesNEI <-citiesNEI %>%
  group_by(city,year) %>%
  summarise(Emissions = sum(Emissions),
            PercentEmissions = sum(percentEm)) 


# Comparing the cities emissions overall
g1 <- ggplot(data = citiesNEI, aes(x = factor(year), Emissions, color = city)) +
  geom_line(aes(group = city)) + geom_point() + guides(fill=FALSE)+
  labs(x="year", y=expression("Motor Vehicle Emissions")) + 
  labs(title=expression("Baltimore City and LA County Emissions (1999-2008)"))

# Comparing the cities emissions by percent to see the change in the cities' uses of motor vehicles
g2 <- ggplot(data = citiesNEI, aes(x = factor(year), PercentEmissions, color = city)) +
  geom_line(aes(group = city)) + geom_point() + guides(fill=FALSE)+
  labs(x="year", y=expression("Motor Vehicle Emissions")) + 
  labs(title=expression("Baltimore City and LA County Emissions by percentage (1999-2008)"))

png("plot6.png",width=960, height=480)
grid.arrange(g1, g2, ncol = 2)
dev.off()

# Question 6: Compare emissions from motor vehicle sources in Baltimore City with emissions
# from motor vehicle sources in Los Angeles County, California (fips=="06037"). 
# Which city has seen greater changes over time in motor vehicle emissions?
# Answer: Overall, LA county had between 6 to 8 times the amount of motor vehicle emissions 
# than Baltimore City. Looking at the percentage emissions, Baltimore severely dropped their 
# motor vehicle usage between 1999 and 2002 and a slight drop between 2005 and 2008. 
# LA's usage stayed about the same over the 10 years


