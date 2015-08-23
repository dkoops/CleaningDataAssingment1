# Code Book

Two datasets have been included in this project.  

## MergedData.txt
The first, MergedData.txt is the complete merge of both the Test and Training datasets.  The final format chosen was a narrow and long table format.  All features were split into a domain (t=time, f=frequency), the main feature itself and the functionname (derived from the function and axis).  The merged dataset contains over 800K rows.

head(MergedData.txt)

*   subject partition activity domain           feature functionname  variable
*1:       2      test standing   time Bodyaccelerometer        meanX 0.2571778
*2:       2      test standing   time Bodyaccelerometer        meanX 0.2860267
*3:       2      test standing   time Bodyaccelerometer        meanX 0.2754848
*4:       2      test standing   time Bodyaccelerometer        meanX 0.2702982
*5:       2      test standing   time Bodyaccelerometer        meanX 0.2748330
*6:       2      test standing   time Bodyaccelerometer        meanX 0.2792199

##tidydata.txt
The tidydata.txt file contains the final script output.  This dataset contains the following fields;
* subject - This identifies one of the 30 participants that collected these measures
* activity - This identifies the type of activity taking place at the time the variable was recorded.  Each activity is one of walking, walkingupstairs, walkingdownstairs, sitting, standing, laying.
* domain - the domain was split off the original feature to indicate either a frequency or time measure.
* feature - This is the type of telemetary capturing the variable.
* functionname - Is the agregated calculation including it's angular vector.
* Variable - Is the mean of all values summarised over subject, activity, domain, feature and functionname. 
NB. Although the project only required teh mean over activity and subject for each feature, because my dataset split the feature into domain, feature and functioname columns, all three were supplied in the output.

head(tidydata.txt)

*  subject activity   domain           feature functionname    variable
*1       1   laying fequency Bodyaccelerometer    meanFreqX -0.15879267
*2       1   laying fequency Bodyaccelerometer    meanFreqY  0.09753484
*3       1   laying fequency Bodyaccelerometer    meanFreqZ  0.08943766
*4       1   laying fequency Bodyaccelerometer        meanX -0.93909905
*5       1   laying fequency Bodyaccelerometer        meanY -0.86706521
*6       1   laying fequency Bodyaccelerometer        meanZ -0.88266688