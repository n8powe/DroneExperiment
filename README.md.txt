# Drone Experiment

**Any questions ask Nate**

# Post-processing gaze and position data

1) In pupil player post process each of your eye tracking folders. Then export gaze positions. 

2) In the python/finalsetcreation folder, add (one at a time) the position/gaze files recorded during the experiment, the exported gaze location, and the info.json file. Then run the python script in the folder to combine the dataset. 

3) After (3) is done, again take each output dataset and read it into the Unity post-processing pipeline. Make sure the correct condition is chosen. Then run the further post-processing function in playback mode. 
	a) The output file should then be saved to your data folder inside the Matlab repository (See below). 


## Matlab

Add your data to the Data Folder in the Matlab folder. 

In the following scripts adjust the file paths to your data. 

The following two scripts call runAnalyses.m to create different datasets. 

--createDroneOrientationAtHoopDatasets
--createTimeSeriesDataset

1) The main matlab function is runAnalyses.m found in the Matlab folder. This function creates a new dataset based on the data recorded in each interhoop segments between each hoop. 
	a) Line 209 starts the main function which calculates all of the data that is added to the dataset which is then exported. 
	b) Note that there are parameters at the top of this function that are hardcoded and should be changed for debugging purposes. 
	c) Also, note that the cross correlation function will produces graphs at each iteration. Can't figure out a way to supress the output. 
	d) Also also, note that this function (line 209) is about 1500 lines long and should be broken up so that it is more modular. 


2) There are several other functions that create the descriptive statistics for each of the experiments. 
	a) writeGazeObjectCategories.m and the same with exp2 at the end. 
	b) generatePerformanceMeasureDataset.m and the same for exp2 at the end. 


3) The remaining scripts are utility scripts that are used by runAnalyses.m to perform various calculations. 

4) The various outputs from the matlab scripts should be placed in the AnalysisData folder in the Analysis_R folder, or just in the Analysis_R folder and make sure to set that folder as the working directory in R.

## Python

In the folder labeled Python. 

1) The main functions in python are the one that removes duplicate frames from the recorded datasets and the cross-correlation analysis. 
	a) 2DxCorrPlot.py
	b) removeDuplicateFrames.py

2) The cross-correlation script takes output from runAnalyses.m

## R

In the folder labeled analyses_R.

1) gazeObjectCategoryAllinOneGraph.r produces the visualization for gaze object categories. 

2) performanceMeasuresAnalysis.r produces the visualization for performance measures. 

3) gazeBehaviorMeasures.r produces visualization for gaze behavior in each condition. 

4) anticipatorySteeringRsqrd.r runs the partial r-squared analysis on anticipatory steering. 

Each of these scripts have the linear models used for statistical analyses as well. 