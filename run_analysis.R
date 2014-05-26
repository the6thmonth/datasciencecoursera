#!/usr/bin/Rscript
require(plyr)
#download the zip file from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
if(!file.exists("~/data")){
  dir.create("~/data")
}
setwd("~/data")
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "assignment.zip", method="wget")
unzip("assignment.zip")

setwd("~/data/UCI HAR Dataset");
#read the feature text
feature_tbl <- readLines("features.txt")
#read the activity text
activities_tbl <- read.table("activity_labels.txt", col.names=c("activity_id", "activity"))

#read the test data, each column corresponds to a feature
test_set <- read.table("test//X_test.txt", col.names=feature_tbl)
#read the activity data
test_feature_set <- read.table("test//y_test.txt", col.names=c("activity_id"))[,1]
#interpret activity id
activity <- sapply(test_feature_set,function(num) {
  return(activities_tbl$activity[activities_tbl$activity_id==num])
})
#read the subject data
test_subject_set <- read.table("test//subject_test.txt", col.names=c("subject_id"))
#combine the subject id and activity type and filter out the mean and std measurements
final_test_set <- cbind(test_subject_set, activity, test_set[,grepl("((mean)|(std))\\(\\).*", feature_tbl)])

#read the training data, each column corresponds to a feature
training_set <- read.table("train//X_train.txt", col.names=feature_tbl)
#read the activity data
training_feature_set <- read.table("train//y_train.txt", col.names=c("activity_id"))[,1]
activity <- sapply(training_feature_set,function(num) {
  return(activities_tbl$activity[activities_tbl$activity_id==num])
})

#read the subject data
training_subject_set <- read.table("train//subject_train.txt", col.names=c("subject_id"))
#combine the subject id and activity type and filter out the mean and std measurements
final_training_set <- cbind(training_subject_set, activity, training_set[,grepl("((mean)|(std))\\(\\).*", feature_tbl)])
nrow(final_training_set)
nrow(final_test_set)
#merge two sets
final_metrics <- rbind(final_test_set, final_training_set)
colnames(final_metrics)
nrow(final_metrics)

#produce clean data
final_avg_aggregation <- aggregate(final_metrics[, -which(names(final_metrics) %in% c("subject_id", "activity"))], final_metrics[,c("subject_id","activity")], mean, na.rm=TRUE)

nrow(final_avg_aggregation)

#output into a file
write.table(final_avg_aggregation, "~/final_avg_aggregation.txt", row.names = FALSE)
