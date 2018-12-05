library(reshape2)

fName <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(fName)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, fName, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(fName) 
}



# Load activity labels + features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])



# Extract only the data on mean and standard deviation
ftrWtd <- grep(".*mean.*|.*std.*", features[,2])
ftrWtd.names <- features[ftrWtd,2]
ftrWtd.names = gsub('-mean', 'Mean', ftrWtd.names)
ftrWtd.names = gsub('-std', 'Std', ftrWtd.names)
ftrWtd.names <- gsub('[-()]', '', ftrWtd.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[ftrWtd]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[ftrWtd]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)


# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", ftrWtd.names)



# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)