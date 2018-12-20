# Getting and Cleaning Data Project John Hopkins Coursera
# Week 3 Programming Assignment
# Susmitha Saripalli

library(reshape2)
library(data.table)
# Load Packages and get the Data
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()

# Get activity labels + features from data
actLabs <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                 , col.names = c("classLabels", "activityName"))
feats <- fread(file.path(path, "UCI HAR Dataset/features.txt")
               , col.names = c("index", "featureNames"))
measurementsWanted <- grep("(mean|std)\\(\\)", feats[, featureNames])
measurements <- feats[measurementsWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

# Load training datasets X, Y, and their subjects (Steps 1 and 3)
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, measurementsWanted, with = FALSE]
setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

# Load testing datasets X, Y, and their subjects (Steps 1 and 3)
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, measurementsWanted, with = FALSE]
setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

# merge testing and training datasets together
d <- rbind(train, test)

# Change classLabes to activity names (Step 4)
d[["Activity"]] <- factor(d[, Activity]
                          , levels = actLabs[["classLabels"]]
                          , labels = actLabs[["activityName"]])

d[["SubjectNum"]] <- as.factor(d[, SubjectNum])
d <- melt(data = d, id = c("SubjectNum", "Activity"))

ave_d <- dcast(data = d, SubjectNum + Activity ~ variable, fun.aggregate = mean)

write.table(x = ave_d, file = "tidyData.txt", row.names = FALSE)
