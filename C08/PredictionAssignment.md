---
title: 'Coursera: Practical Machine Learning Prediction Assignment'
author: 'Susmitha Saripalli'
output:
  html_document:
    keep_md: yes
---

 **Background**
 Using devices such as Jawbone Up, Nike FuelBand, and Fitbit it is now possible to collect a large amount of data about personal activity relatively inexpensively. These type of devices are part of the quantified self movement - a group of enthusiasts who take measurements about themselves regularly to improve their health, to find patterns in their behavior, or because they are tech geeks. One thing that people regularly do is quantify how much of a particular activity they do, but they rarely quantify how well they do it. In this project, your goal will be to use data from accelerometers on the belt, forearm, arm, and dumbell of 6 participants. They were asked to perform barbell lifts correctly and incorrectly in 5 different ways. More information is available from the website here: http://groupware.les.inf.puc-rio.br/har (see the section on the Weight Lifting Exercise Dataset). 

 **Data **
 The training data for this project are available here: 
 https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv
 The test data are available here: 
 https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv
 The data for this project come from this source: http://groupware.les.inf.puc-rio.br/har. If you use the document you create for this class for any purpose please cite them as they have been very generous in allowing their data to be used for this kind of assignment. 
 
 **What you should submit**
 The goal of your project is to predict the manner in which they did the exercise. This is the "classe" variable in the training set. You may use any of the other variables to predict with. You should create a report describing how you built your model, how you used cross validation, what you think the expected out of sample error is, and why you made the choices you did. You will also use your prediction model to predict 20 different test cases. 
 1. Your submission should consist of a link to a Github repo with your R markdown and compiled HTML file describing your analysis. Please constrain the text of the writeup to < 2000 words and the number of figures to be less than 5. It will make it easier for the graders if you submit a repo with a gh-pages branch so the HTML page can be viewed online (and you always want to make it easy on graders :-).
 2. You should also apply your machine learning algorithm to the 20 test cases available in the test data above. Please submit your predictions in appropriate format to the programming assignment for automated grading. See the programming assignment for additional details. 
 
 **Reproducibility **
 Due to security concerns with the exchange of R code, your code will not be run during the evaluation by your classmates. Please be sure that if they download the repo, they will be able to view the compiled HTML version of your analysis. 
 
# Prepare the datasets
Read in the training data.

```r
require(data.table)
```

```
## Loading required package: data.table
```

```r
url1 <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
D <- fread(url1)
```
Read in the testing data.

```r
url2 <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"
DatTest <- fread(url2)
```

Find variables with complete sets of data to use as predictors.
Belt, arm, dumbbell, and forearm variables that have no `NAs`.


```r
missingDat <- sapply(DatTest, function (x) any(is.na(x) | x == ""))
PV <- "belt|[^(fore)]arm|dumbbell|forearm"
predData <- !missingDat & grepl(PV, names(missingDat))
predVariables <- names(missingDat)[predData]
predVariables
```

```
##  [1] "roll_belt"            "pitch_belt"           "yaw_belt"            
##  [4] "total_accel_belt"     "gyros_belt_x"         "gyros_belt_y"        
##  [7] "gyros_belt_z"         "accel_belt_x"         "accel_belt_y"        
## [10] "accel_belt_z"         "magnet_belt_x"        "magnet_belt_y"       
## [13] "magnet_belt_z"        "roll_arm"             "pitch_arm"           
## [16] "yaw_arm"              "total_accel_arm"      "gyros_arm_x"         
## [19] "gyros_arm_y"          "gyros_arm_z"          "accel_arm_x"         
## [22] "accel_arm_y"          "accel_arm_z"          "magnet_arm_x"        
## [25] "magnet_arm_y"         "magnet_arm_z"         "roll_dumbbell"       
## [28] "pitch_dumbbell"       "yaw_dumbbell"         "total_accel_dumbbell"
## [31] "gyros_dumbbell_x"     "gyros_dumbbell_y"     "gyros_dumbbell_z"    
## [34] "accel_dumbbell_x"     "accel_dumbbell_y"     "accel_dumbbell_z"    
## [37] "magnet_dumbbell_x"    "magnet_dumbbell_y"    "magnet_dumbbell_z"   
## [40] "roll_forearm"         "pitch_forearm"        "yaw_forearm"         
## [43] "total_accel_forearm"  "gyros_forearm_x"      "gyros_forearm_y"     
## [46] "gyros_forearm_z"      "accel_forearm_x"      "accel_forearm_y"     
## [49] "accel_forearm_z"      "magnet_forearm_x"     "magnet_forearm_y"    
## [52] "magnet_forearm_z"
```

Combine predictors with and the outcome variable, `classe` into one data set.


```r
finVars <- c("classe", predVariables)
D <- D[, finVars, with=FALSE]
dim(D)
```

```
## [1] 19622    53
```

```r
names(D)
```

```
##  [1] "classe"               "roll_belt"            "pitch_belt"          
##  [4] "yaw_belt"             "total_accel_belt"     "gyros_belt_x"        
##  [7] "gyros_belt_y"         "gyros_belt_z"         "accel_belt_x"        
## [10] "accel_belt_y"         "accel_belt_z"         "magnet_belt_x"       
## [13] "magnet_belt_y"        "magnet_belt_z"        "roll_arm"            
## [16] "pitch_arm"            "yaw_arm"              "total_accel_arm"     
## [19] "gyros_arm_x"          "gyros_arm_y"          "gyros_arm_z"         
## [22] "accel_arm_x"          "accel_arm_y"          "accel_arm_z"         
## [25] "magnet_arm_x"         "magnet_arm_y"         "magnet_arm_z"        
## [28] "roll_dumbbell"        "pitch_dumbbell"       "yaw_dumbbell"        
## [31] "total_accel_dumbbell" "gyros_dumbbell_x"     "gyros_dumbbell_y"    
## [34] "gyros_dumbbell_z"     "accel_dumbbell_x"     "accel_dumbbell_y"    
## [37] "accel_dumbbell_z"     "magnet_dumbbell_x"    "magnet_dumbbell_y"   
## [40] "magnet_dumbbell_z"    "roll_forearm"         "pitch_forearm"       
## [43] "yaw_forearm"          "total_accel_forearm"  "gyros_forearm_x"     
## [46] "gyros_forearm_y"      "gyros_forearm_z"      "accel_forearm_x"     
## [49] "accel_forearm_y"      "accel_forearm_z"      "magnet_forearm_x"    
## [52] "magnet_forearm_y"     "magnet_forearm_z"
```

Make `classe` into a factor.


```r
D <- D[, classe := factor(D[, classe])]
D[, .N, classe]
```

```
##    classe    N
## 1:      A 5580
## 2:      B 3797
## 3:      C 3422
## 4:      D 3216
## 5:      E 3607
```

Split dataset into a 60:40 training test.


```r
require(caret)
```

```
## Loading required package: caret
```

```
## Loading required package: lattice
```

```
## Loading required package: ggplot2
```

```r
set.seed(1234)
inTrain <- createDataPartition(D$classe, p=0.6)
DTrain <- D[inTrain[[1]]]
DProbe <- D[-inTrain[[1]]]
```

Preprocess the prediction variables by centering and scaling.


```r
X <- DTrain[, predVariables, with=FALSE]
preProc <- preProcess(X)
preProc
```

```
## Created from 11776 samples and 52 variables
## 
## Pre-processing:
##   - centered (52)
##   - ignored (0)
##   - scaled (52)
```

```r
XCS <- predict(preProc, X)
DTrainCS <- data.table(data.frame(classe = DTrain[, classe], XCS))
```

Apply the centering and scaling to the probing dataset.


```r
X <- DProbe[, predVariables, with=FALSE]
XCS <- predict(preProc, X)
DProbeCS <- data.table(data.frame(classe = DProbe[, classe], XCS))
```

Check for near zero variance.


```r
nzv <- nearZeroVar(DTrainCS, saveMetrics=TRUE)

if (any(nzv$nzv)) nzv else message("No variables with nzv")
```

```
## No variables with nzv
```

Group and examine predictor variables.


```r
require(ggplot2)
require(reshape2)
```

```
## Loading required package: reshape2
```

```
## 
## Attaching package: 'reshape2'
```

```
## The following objects are masked from 'package:data.table':
## 
##     dcast, melt
```

```r
histGroup <- function (data, regex) {
  col <- grep(regex, names(data))
  col <- c(col, which(names(data) == "classe"))
  n <- nrow(data)
  DMelt <- melt(data[, col, with=FALSE][, rows := seq(1, n)], id.vars=c("rows", "classe"))
  ggplot(DMelt, aes(x=classe, y=value)) +
    geom_violin(aes(color=classe, fill=classe), alpha=3/4) +
    facet_wrap(~ variable, scale="free_y") +
    labs(x="", y="") +
    theme(legend.position="none")
} 

histGroup(DTrainCS, "belt")   
```

![](PredictionAssignment_files/figure-html/histGroup-1.png)<!-- -->

```r
histGroup(DTrainCS, "[^(fore)]arm")
```

![](PredictionAssignment_files/figure-html/histGroup-2.png)<!-- -->

```r
histGroup(DTrainCS, "dumbbell")
```

![](PredictionAssignment_files/figure-html/histGroup-3.png)<!-- -->

```r
histGroup(DTrainCS, "forearm")
```

![](PredictionAssignment_files/figure-html/histGroup-4.png)<!-- -->


# Training prediction model

Using random forest:
Setting up parallel clusters.


```r
require(parallel)
```

```
## Loading required package: parallel
```

```r
require(doParallel)
```

```
## Loading required package: doParallel
```

```
## Loading required package: foreach
```

```
## Loading required package: iterators
```

```r
cl <- makeCluster(detectCores() - 1)
registerDoParallel(cl)
```

Setting control parameters.


```r
ctrl <- trainControl(classProbs=TRUE,
                     savePredictions=TRUE,
                     allowParallel=TRUE)
```

Fit model over the tuning parameters.


```r
method <- "rf"
system.time(trainingModel <- train(classe ~ ., data=DTrainCS, method=method))
```

```
##     user   system  elapsed 
##   39.458    1.413 1034.772
```

Stop the clusters.


```r
stopCluster(cl)
```

## Evaluate model on training set


```r
trainingModel
```

```
## Random Forest 
## 
## 11776 samples
##    52 predictor
##     5 classes: 'A', 'B', 'C', 'D', 'E' 
## 
## No pre-processing
## Resampling: Bootstrapped (25 reps) 
## Summary of sample sizes: 11776, 11776, 11776, 11776, 11776, 11776, ... 
## Resampling results across tuning parameters:
## 
##   mtry  Accuracy   Kappa    
##    2    0.9859145  0.9821742
##   27    0.9860918  0.9824010
##   52    0.9764769  0.9702352
## 
## Accuracy was used to select the optimal model using the largest value.
## The final value used for the model was mtry = 27.
```

```r
finPred <- predict(trainingModel, DTrainCS)
confusionMatrix(finPred, DTrain[, classe])
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction    A    B    C    D    E
##          A 3348    0    0    0    0
##          B    0 2279    0    0    0
##          C    0    0 2054    0    0
##          D    0    0    0 1930    0
##          E    0    0    0    0 2165
## 
## Overall Statistics
##                                      
##                Accuracy : 1          
##                  95% CI : (0.9997, 1)
##     No Information Rate : 0.2843     
##     P-Value [Acc > NIR] : < 2.2e-16  
##                                      
##                   Kappa : 1          
##  Mcnemar's Test P-Value : NA         
## 
## Statistics by Class:
## 
##                      Class: A Class: B Class: C Class: D Class: E
## Sensitivity            1.0000   1.0000   1.0000   1.0000   1.0000
## Specificity            1.0000   1.0000   1.0000   1.0000   1.0000
## Pos Pred Value         1.0000   1.0000   1.0000   1.0000   1.0000
## Neg Pred Value         1.0000   1.0000   1.0000   1.0000   1.0000
## Prevalence             0.2843   0.1935   0.1744   0.1639   0.1838
## Detection Rate         0.2843   0.1935   0.1744   0.1639   0.1838
## Detection Prevalence   0.2843   0.1935   0.1744   0.1639   0.1838
## Balanced Accuracy      1.0000   1.0000   1.0000   1.0000   1.0000
```

## Evaluate the model on the testing data


```r
finPred <- predict(trainingModel, DProbeCS)
confusionMatrix(finPred, DProbeCS[, classe])
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction    A    B    C    D    E
##          A 2231   18    0    0    0
##          B    0 1493   13    1    2
##          C    1    7 1349   21    2
##          D    0    0    6 1262    4
##          E    0    0    0    2 1434
## 
## Overall Statistics
##                                           
##                Accuracy : 0.9902          
##                  95% CI : (0.9877, 0.9922)
##     No Information Rate : 0.2845          
##     P-Value [Acc > NIR] : < 2.2e-16       
##                                           
##                   Kappa : 0.9876          
##  Mcnemar's Test P-Value : NA              
## 
## Statistics by Class:
## 
##                      Class: A Class: B Class: C Class: D Class: E
## Sensitivity            0.9996   0.9835   0.9861   0.9813   0.9945
## Specificity            0.9968   0.9975   0.9952   0.9985   0.9997
## Pos Pred Value         0.9920   0.9894   0.9775   0.9921   0.9986
## Neg Pred Value         0.9998   0.9961   0.9971   0.9963   0.9988
## Prevalence             0.2845   0.1935   0.1744   0.1639   0.1838
## Detection Rate         0.2843   0.1903   0.1719   0.1608   0.1828
## Detection Prevalence   0.2866   0.1923   0.1759   0.1621   0.1830
## Balanced Accuracy      0.9982   0.9905   0.9907   0.9899   0.9971
```
Accuracy is 99.07% so there's less than 1% error with random forests. 


## Final model


```r
varImp(trainingModel)
```

```
## rf variable importance
## 
##   only 20 most important variables shown (out of 52)
## 
##                      Overall
## roll_belt             100.00
## pitch_forearm          60.39
## yaw_belt               55.87
## magnet_dumbbell_y      45.12
## pitch_belt             43.49
## magnet_dumbbell_z      42.90
## roll_forearm           40.61
## accel_dumbbell_y       21.71
## roll_dumbbell          18.78
## magnet_dumbbell_x      16.08
## magnet_belt_z          15.91
## accel_forearm_x        15.54
## total_accel_dumbbell   14.58
## accel_dumbbell_z       13.85
## accel_belt_z           13.52
## magnet_belt_y          13.02
## magnet_forearm_z       12.75
## yaw_arm                11.59
## gyros_belt_z           11.15
## magnet_belt_x          10.46
```

```r
trainingModel$finalModel
```

```
## 
## Call:
##  randomForest(x = x, y = y, mtry = param$mtry) 
##                Type of random forest: classification
##                      Number of trees: 500
## No. of variables tried at each split: 27
## 
##         OOB estimate of  error rate: 0.89%
## Confusion matrix:
##      A    B    C    D    E class.error
## A 3341    5    0    1    1 0.002090800
## B   22 2251    6    0    0 0.012286090
## C    0   19 2028    7    0 0.012658228
## D    0    0   27 1901    2 0.015025907
## E    0    1    6    8 2150 0.006928406
```

Save training model


```r
save(trainingModel, file="trainingModel.RData")
```


# Predict on the test data

Load training model.


```r
load(file="trainingModel.RData", verbose=TRUE)
```

```
## Loading objects:
##   trainingModel
```

Get predictions and evaluate.


```r
DatTestCS <- predict(preProc, DatTest[, predVariables, with=FALSE])
finPred <- predict(trainingModel, DatTestCS)
DatTest <- cbind(finPred , DatTest)
subset(DatTest, select=names(DatTest)[grep(PV, names(DatTest), invert=TRUE)])
```

```
##     finPred V1 user_name raw_timestamp_part_1 raw_timestamp_part_2
##  1:       B  1     pedro           1323095002               868349
##  2:       A  2    jeremy           1322673067               778725
##  3:       B  3    jeremy           1322673075               342967
##  4:       A  4    adelmo           1322832789               560311
##  5:       A  5    eurico           1322489635               814776
##  6:       E  6    jeremy           1322673149               510661
##  7:       D  7    jeremy           1322673128               766645
##  8:       B  8    jeremy           1322673076                54671
##  9:       A  9  carlitos           1323084240               916313
## 10:       A 10   charles           1322837822               384285
## 11:       B 11  carlitos           1323084277                36553
## 12:       C 12    jeremy           1322673101               442731
## 13:       B 13    eurico           1322489661               298656
## 14:       A 14    jeremy           1322673043               178652
## 15:       E 15    jeremy           1322673156               550750
## 16:       E 16    eurico           1322489713               706637
## 17:       A 17     pedro           1323094971               920315
## 18:       B 18  carlitos           1323084285               176314
## 19:       B 19     pedro           1323094999               828379
## 20:       B 20    eurico           1322489658               106658
##       cvtd_timestamp new_window num_window problem_id
##  1: 05/12/2011 14:23         no         74          1
##  2: 30/11/2011 17:11         no        431          2
##  3: 30/11/2011 17:11         no        439          3
##  4: 02/12/2011 13:33         no        194          4
##  5: 28/11/2011 14:13         no        235          5
##  6: 30/11/2011 17:12         no        504          6
##  7: 30/11/2011 17:12         no        485          7
##  8: 30/11/2011 17:11         no        440          8
##  9: 05/12/2011 11:24         no        323          9
## 10: 02/12/2011 14:57         no        664         10
## 11: 05/12/2011 11:24         no        859         11
## 12: 30/11/2011 17:11         no        461         12
## 13: 28/11/2011 14:14         no        257         13
## 14: 30/11/2011 17:10         no        408         14
## 15: 30/11/2011 17:12         no        779         15
## 16: 28/11/2011 14:15         no        302         16
## 17: 05/12/2011 14:22         no         48         17
## 18: 05/12/2011 11:24         no        361         18
## 19: 05/12/2011 14:23         no         72         19
## 20: 28/11/2011 14:14         no        255         20
```
