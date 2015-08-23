
# You should create one R script called run_analysis.R that does the following. 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, 
#    independent tidy data set with the average of each variable 
#    for each activity and each subject.
#
#  Dataset info http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#
library(dplyr)
library(data.table)

# 3. Uses descriptive activity names to name the activities in the data set
# Load Activities and merge with training dataset
activities <- read.csv2("activity_labels.txt", header=FALSE, sep = " ",stringsAsFactors = FALSE)
names(activities) <- c('activityid', 'activity')
activities$activity <- tolower(sub("_","", activities$activity))

# Load traing dataset and merge with Activities
trainY <- read.csv2("train/y_train.txt", header=FALSE, sep = " ",stringsAsFactors = FALSE)
trainY <- trainY %>%
  mutate( origidx=seq(1,nrow(trainY))) %>%
  merge(activities, trainY, by.x=1,by.y=1) %>%
  arrange(origidx) %>%
  select(activity)

# Load testing dataset and merge with Activities
testY <- read.csv2("test/y_test.txt", header=FALSE, sep = " ",stringsAsFactors = FALSE)
testY <- testY %>%
  mutate( origidx=seq(1,nrow(testY))) %>%
  merge(activities, testY, by.x=1,by.y=1) %>%
  arrange(origidx) %>%
  select(activity)

rm(activities)

# Load Subjects and merge with training dataset
trainsubject <- read.csv2("train/subject_train.txt", header=FALSE, sep = " ", col.names = c("subject"))
#trainsubject$subject <- factor(trainsubject$subject )
trainsubject <- mutate(trainsubject, partition='train')
#trainsubject$partition <- factor(trainsubject$partition)
trainsubject <- mutate(trainsubject, activity=trainY$activity)
rm(trainY)

# Loading Subjects and merge with test dataset
testsubject <- read.csv2("test/subject_test.txt", header=FALSE, sep = " ", col.names = c("subject"))
# Create factors after merging with main dataset
#testsubject$subject <- factor(testsubject$subject )
testsubject <- mutate(testsubject, partition='test')
testsubject <- mutate(testsubject, activity=testY$activity)
rm(testY)

# Filtering Columns
features <- read.csv2("features.txt", header=FALSE, sep = " ", stringsAsFactors = FALSE)
names(features) <- c('columnindex', 'columnname')
#str(features)
#class(features)
features <- mutate(features, domaintype=substr(features$columnname,1,1))
domain <- data.frame( domaintype=c("t","f","a"), domain=c('time', 'fequency','gravity'))
features <- merge(features, domain) %>%
    select(-domaintype) %>%
    arrange(columnindex)

rm(domain)
#features$domain <- factor(features$domain)

# 4. Appropriately labels the data set with descriptive variable names.
# Function - Parse function name to remove non-alpha characters
parsefunctionName <- function(f){
    paste0(regmatches(f[2], 
              regexpr("[a-zA-Z]*", f[2])), 
          ifelse(is.na(f[3]), "",f[3])
          )
}

# Function - Parse Feature names to remove first character
parseFeatureName <- function(f){substring(f[1],2)}

# Split features names on "-" and breakout column names into variable types
splitnames <- strsplit(features$columnname, "-")
featureNames <- sapply(splitnames, parseFeatureName)
features <- mutate(features, featureNames)
rm(featureNames)

functionNames <-sapply(splitnames, parsefunctionName)
features <- mutate(features, functionNames) 
rm(functionNames)
rm(splitnames)

#features$featureNames <- factor(features$featureNames)
#features$functionNames <- factor(features$functionNames)

# Look for BodyBody and replace with Body
dupBodyIdx <- grep("BodyBody", features$featureNames)
features$featureNames[dupBodyIdx] <- sub( "BodyBody", "Body", features$featureNames[dupBodyIdx])
rm(dupBodyIdx)

# Replace Short form names with long form names
AccIdx <- grep("Acc", features$featureNames)
features$featureNames[AccIdx] <- sub( "Acc", "accelerometer", features$featureNames[AccIdx])
rm(AccIdx)

GyroIdx <- grep("Gyro", features$featureNames)
features$featureNames[GyroIdx] <- sub( "Gyro", "gyroscope", features$featureNames[GyroIdx])
rm(GyroIdx)

MagIdx <- grep("Mag", features$featureNames)
features$featureNames[MagIdx] <- sub( "Mag", "magnitude", features$featureNames[MagIdx])
rm(MagIdx)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# Projecting columns of type mean or std
featuresubset <- features[ grep( 'mean|std', features$functionNames),]

featuresubset <- mutate( featuresubset, newindex=seq(1,nrow(featuresubset)))
featuresubset$columnname <- factor(featuresubset$columnname)
featuresubset$domain <- factor(featuresubset$domain)
featuresubset$featureNames <- factor(featuresubset$featureNames)
featuresubset$functionNames <- factor(featuresubset$functionNames)


# Loading table in iterations into fast table
# Extra step required due to limited PC memory 1.5Gb
makefastfile <- function(infile, outfile, colwidths, buffersize = 100){
  rowsread <-0
  rowstoread <- buffersize
  readmore <-TRUE
  while (readmore){
    intable <- read.fwf(infile, widths = colwidths, colClasses="numeric", skip = rowsread, n = rowstoread, buffersize = rowstoread )
    if( nrow(intable) < rowstoread) {readmore <- FALSE}
    if(rowsread == 0){
      write.table(intable, outfile, row.name=FALSE)
    } else
    {
      write.table(intable, outfile, row.name=FALSE, col.names = FALSE, append = TRUE )
    }
    rowsread <- rowsread + nrow(intable)
    print( paste("Read",rowsread , "rows.") )
  }
}

numfeatures <- nrow( features)
cols <- rep(16, numfeatures)
makefastfile("test/X_test.txt", "ff_Xtest.txt", cols)
XTest <- fread("ff_Xtest.txt", colClasses="numeric", select=featuresubset$columnindex)
#format( object.size(intable), units='MB')
#rm(XTest)

head( cbind(testsubject, XTest), 5)

makefastfile("train/X_train.txt", "ff_Xtrain.txt", cols)
XTrain <- fread("ff_Xtrain.txt", colClasses="numeric", select=featuresubset$columnindex)
#format( object.size(intable), units='MB')
#rm(XTrain)
rm(features)
rm(numfeatures)
rm(cols)

# 1. Merges the training and the test sets to create one data set.
# Function - Make Long narrow data.frame
makeNarrowTable <- function(subjectDS, featureDS, variableDS){
  mergedDF <- data.frame()
  nrows <- nrow(subjectDS)
  for( i in featureDS$newindex){
    newdf <- data.frame(subject=subjectDS$subject,
                        partition=subjectDS$partition,
                        activity=subjectDS$activity,
                        domain=rep( featureDS$domain[featureDS$newindex == i], nrows),
                        feature=rep( featureDS$featureNames[featureDS$newindex == i], nrows),
                        functionname=rep( featureDS$functionNames[featureDS$newindex == i], nrows),
                        variable=variableDS[[i]]
    )
    if( nrow(mergedDF) == 0 ){ 
      mergedDF = newdf
    } else{
      mergedDF = rbind(mergedDF, newdf)
    }
  }
  mergedDF
}

mergedTestDS <- makeNarrowTable(testsubject, featuresubset, XTest)
rm(testsubject)
rm(XTest)
mergedTrainDS <- makeNarrowTable(trainsubject, featuresubset, XTrain)
rm(trainsubject)
rm(XTrain)
rm(featuresubset)
rm(features)
mergedDS <- rbind(mergedTestDS, mergedTrainDS)
rm(mergedTestDS)
rm(mergedTrainDS)

mergedDS$subject <- factor(mergedDS$subject)
format( object.size(mergedDS), units='MB')

# UPTO HERE

# Output
# 5. From the data set in step 4, creates a second, 
#    independent tidy data set with the average of each variable 
#    for each activity and each subject.

library(data.table)
write.table(mergedDS, 'mergeddata.txt', row.name=FALSE)
mergeDS <- fread('mergeddata.txt')
 
library(reshape2)
featureMelt <- melt(mergeDS, id=c("subject","partition","activity","domain","feature","functionname"), measure.vars = c("variable") )
tidyDS <- dcast(featureMelt, subject + activity + domain + feature ~ functionname, mean)
head( tidyDS)
write.table(tidyDS, 'tidydata.txt', row.name=FALSE)

#intable <- fread('tidydata.txt')

