#download the file

library(RCurl)

if(!file.exists("./R/data")){dir.create("./R/data")}

fUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fUrl,destfile="./R/data/Dataset.zip",method="libcurl")



#unzip the file

unzip(zipfile="./R/data/Dataset.zip",exdir="./R/data")



#read the files

path_f <- file.path("./R/data" , "UCI HAR Dataset")

dataActTest  <- read.table(file.path(path_f, "test" , "Y_test.txt" ),header = FALSE)

dataActTrain <- read.table(file.path(path_f, "train", "Y_train.txt"),header = FALSE)



dataSubTrain <- read.table(file.path(path_f, "train", "subject_train.txt"),header = FALSE)

dataSubTest  <- read.table(file.path(path_f, "test" , "subject_test.txt"),header = FALSE)



dataFeatTest  <- read.table(file.path(path_f, "test" , "X_test.txt" ),header = FALSE)

dataFeatTrain <- read.table(file.path(path_f, "train", "X_train.txt"),header = FALSE)



#Merges the training and the test sets to create one data set.

dataSub <- rbind(dataSubTrain, dataSubTest)

dataAct<- rbind(dataActTrain, dataActTest)

dataFeat<- rbind(dataFeatTrain, dataFeatTest)



names(dataSub)<-c("subject")

names(dataAct)<- c("activity")

dataFeatNames <- read.table(file.path(path_f, "features.txt"),head=FALSE)

names(dataFeat)<- dataFeatNames$V2



dataSubAct <- cbind(dataSub, dataAct)

dataAll <- cbind(dataFeat, dataSubAct)



#Extracts only the measurements on the mean and standard deviation for each measurement.

subdataFeatNames<-dataFeatNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeatNames$V2)]

selectedNames<-c(as.character(subdataFeatNames), "subject", "activity" )

subData<-subset(dataAll,select=selectedNames)



#Uses descriptive activity names to name the activities in the data set

actLabels <- read.table(file.path(path_f, "activity_labels.txt"),header = FALSE)

subData$activity<-factor(subData$activity);

subData$activity<- factor(subData$activity,labels=as.character(actLabels$V2))



#Appropriately labels the data set with descriptive variable names

names(subData)<-gsub("^t", "time", names(subData))

names(subData)<-gsub("^f", "frequency", names(subData))

names(subData)<-gsub("Acc", "Accelerometer", names(subData))

names(subData)<-gsub("Gyro", "Gyroscope", names(subData))

names(subData)<-gsub("Mag", "Magnitude", names(subData))

names(subData)<-gsub("BodyBody", "Body", names(subData))



#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(dplyr);

Data2<-aggregate(. ~subject + activity, subData, mean)

Data2<-Data2[order(Data2$subject,Data2$activity),]

write.table(Data2, file = "tidydataset.txt",row.name=FALSE)
