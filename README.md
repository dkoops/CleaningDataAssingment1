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

This script performs all the data transformations required in this project (listed above).  Due to limited memory (ie. 1.5Gb) the script was written to mimimise the use of available memory.  Therefore the order of the above transformations was altered and objects are regularly cleaned up when not required.  

The extraction of the mean and std fields was conducted by first reading 100 records at a time for both test and training datasets and then appending then to a temporary file.  This file was then read back into R with only the necessary fields for mean and std.

R-Packages used in this script include dplyr, data.table and reshape2.

The tidydata.txt output file can be read in using the following code;
tidydata <- fread('tidydata.txt')
