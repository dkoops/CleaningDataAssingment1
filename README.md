# CleaningDataProject1

The data transformation exercise was performed over the Human Activity Recognition Using Smartphones Dataset.  The basic steps were;
* Merge the Training and Test datasets into a single dataset
* Extract only the measures of type mean or standard deviation for each measure
* Use descriptive Activity names for the dataset
* Appropriately label all variables with descriptive names
* Create a tidy dataset which shows the average of all measures by activity and subject

Full source dataset can be found here;
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

## The main script 
* run_analysis.R

This script performs all the data transformations required in this project (listed above).  Due to limited memory (ie. 1.5Gb) the script was written to mimimise the use of available memory.  Therefore the order of the above transformations was altered and objects are regularly cleaned up when not required.  Also due to memory limitations many of the advanced R packages could not be used for merging and projecting data.

The basic steps used in the run_analysis.R script are as follows:

* Load Activity and strip "_" characters
* Load y_test and y_train datasetes and merge with Activity descriptions
* Load subjects_test and subject_train datasets adding partitions (test, train) and merge with Activity dataset.
* Load features dataset, split and clean variable names.
* Filter Features dataset to reduce to only columns containing a mean or std function.
* Load X_Test and X_Train datasets. NB Memory limits required loading 100 records at a time, appending to a tempory file and fread the files back in with only the mean and std columns required.
* Use melt and dcast to transform into a tidy dataset including the mean by subject, activity for each feature.

NB. The extraction of the mean and std fields was conducted by first reading 100 records at a time for both test and training datasets and then appending then to a temporary file.  This file was then read back into R with only the necessary fields for mean and std.  The fread function reduced the reload of all records to only a few seconds and the memory required was reduced conciderably.  Allowing the remained of the transformation to be carried out using reshape2 package.

R-Packages used in this script include dplyr, data.table and reshape2.

The tidydata.txt output file can be read in using the following code;
tidydata <- fread('tidydata.txt')
