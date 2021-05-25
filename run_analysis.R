
# Author : Vishwajeet Kulkarni
# Getting and Cleaning Data Course Project

# Loading the required libraries
library(dplyr)
# We use dplyr to chain functions

# Downloading and Unzipping the data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,"zipped_data.zip")
unzip("zipped_data.zip")

# Assigning the files in the UCI HAR Dataset Folder to Appropriate tables
# The column names are not specified in the data so we explicitly write them with
# the col.names argument of read.table

features <- read.table("./UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activities <- read.table("./UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))

# Reading the train sets
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", col.names = "code")

# Reading the test sets
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", col.names = "code")

# Merging the training and test data to create one data set

merged_x <- rbind(x_train,x_test)
merged_y <- rbind(y_train,y_test)
merged_subject <- rbind(subject_train,subject_test)
final_data <- cbind(merged_subject,merged_x,merged_y)

# Extracting only the measurements on mean and standard deviations for
# each measurement

# the contain argument of dplyr select matches patterns containing a literal string
req_data <- final_data %>% select(subject,code,contains("mean"),contains("std"))

# Using descriptive activity names to name the activities in the data set
# We use the activities data set here which has activity names corresponding to code.
req_data$code <- activities[req_data$code,2]

# Appropriately labeling the data sets with descriptive variable names
# We use the gsub function here to replace all occurrences of a sub-string within a string

names(req_data)[2] = "Activity"
names(req_data) <- gsub("angle","Angle",names(req_data))
names(req_data) <- gsub("gravity","Gravity",names(req_data))
names(req_data) <- gsub("Acc","Accelerometer",names(req_data))
names(req_data) <- gsub("Gyro","Gyroscope",names(req_data))
names(req_data) <- gsub("BodyBody","Body",names(req_data))
names(req_data) <- gsub("Mag","Magnitude",names(req_data))
names(req_data) <- gsub("^t","Time",names(req_data))
names(req_data) <- gsub("^f","Frequency",names(req_data))
names(req_data) <- gsub("tBody","TimeBody",names(req_data))
# The ignore.case = TRUE implies non case sensitive matching
names(req_data) <- gsub("mean()","Mean",names(req_data),ignore.case=TRUE)
names(req_data) <- gsub("-std()","Standard_Dev",names(req_data),ignore.case=TRUE)
names(req_data) <- gsub("-freq()","Frequency",names(req_data),ignore.case=TRUE)

# From the above data creating a second, independent tidy data set with the average of
# each variable for each activity and each subject

# We use dplyr here to first group the data set by subject and activity
# and then use summarize all to affect all variables and get their mean 
second_data <- req_data %>% group_by(subject,Activity) %>% summarise_all(list(mean=mean))

# Writing the final data set into a file
write.table(second_data,"final_tidy_data.txt",row.name = FALSE)


