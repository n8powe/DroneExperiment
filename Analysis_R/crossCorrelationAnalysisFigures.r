
library('ggplot2')
library('lme4')
library(lmerTest)
library(gridExtra)
library(tidyverse)
library(ggpubr)
library(rstatix)



#orientationData <- read.csv('droneOrientationDatasetUpdatedAngles.txt', sep=',')
orientationData <- read.csv('droneOrientationDatasetUpdatedAnglesABSangles.txt', sep=',')
orientationData <- orientationData[orientationData$block<5,]

orientationData$hoopNum[orientationData$hoopNum>42] = orientationData$hoopNum[orientationData$hoopNum>42] - 42

orientationData$highCurve <- abs(orientationData$VisualAngleBetweenHoops)>20


highCurve <- orientationData[abs(orientationData$VisualAngleBetweenHoops)>20,]
lowCurve <- orientationData[abs(orientationData$VisualAngleBetweenHoops)<20,]



########################################## Gaze/Heading and Thrust/Heading cross correlation

meanrGH <- aggregate(orientationData$rGH_THp, list( orientationData$Condition, orientationData$hoopNum, orientationData$prevHoopVisualAngle, orientationData$highCurve), FUN=mean)

colnames(meanrGH) <- c('Condition', 'hoopNum','VisualAngleBetweenHoops', 'highCurve', 'rGH')

avgGH <- ggplot(data=meanrGH, aes(y=rGH, x=VisualAngleBetweenHoops, colour=Condition)) + stat_summary(fun.y=mean, geom = "point", size=3)+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + ylim(-1,1) + ggtitle('Average cross-correlation coefficient - Gaze/Thrust angles')#+ geom_point()
avgGH


meanLagGH <- aggregate(orientationData$lagTH_GH, list( orientationData$Condition, orientationData$hoopNum, orientationData$VisualAngleBetweenHoops), FUN=mean)

colnames(meanLagGH) <- c('Condition', 'hoopNum','VisualAngleBetweenHoops', 'lagGH')

avgGHlag <- ggplot(data=meanLagGH, aes(y=lagGH/60, x=VisualAngleBetweenHoops, colour=Condition)) + stat_summary(fun.y=mean, geom = "point", size=3)+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + ggtitle('Average cross-correlation lag - Gaze/Thrust angles')#+ geom_point()
avgGHlag




##################################################

meanrGH <- aggregate(orientationData$lagTHp_GHp, list( orientationData$Condition, orientationData$hoopNum, orientationData$prevHoopVisualAngle, orientationData$highCurve), FUN=mean)

colnames(meanrGH) <- c('Condition', 'hoopNum','VisualAngleBetweenHoops', 'highCurve', 'lagTH_GHp')

ggplot(data=orientationData, aes(x=ApproachAngleY, y=rTH_GH, colour=Condition)) + geom_point() + geom_smooth()# stat_summary(fun.y=mean, geom = "point", size=3)  


########################################################################



gazeThrust <- ggplot(data=orientationData, aes(x=prevHoopVisualAngle, y=rTH_GH, colour=Condition)) + stat_summary(fun.y=mean, geom = "point", size=3)+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + ylim(-1,1)  +
  ggtitle('Average cross-correlation coefficient - Gaze/Thrust angles') + theme(legend.position = "none")#+ geom_point()
gazeThrust

gazeThrustDen <- ggplot(data=orientationData, aes(x=rTH_GH, colour=Condition)) + geom_density() + coord_flip()  + ggtitle('Density - xCorr Gaze/Thrust angles') 
gazeThrustDen





gazeThrustHC <- ggplot(data=orientationData, aes(x=Condition, y=rTH_GH, colour=Condition)) + stat_summary(fun.y=mean, geom = "point", size=3)+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + ylim(-1,1)  +
  ggtitle('Average cross-correlation coefficient - Gaze/Thrust angles') + theme(legend.position = "none")#+ geom_point()
gazeThrustHC

gazeThrustDenHC <- ggplot(data=orientationData, aes(x=rTH_GH, colour=Condition)) + geom_density() + coord_flip()  + ggtitle('Density - xCorr Gaze/Thrust angles') 
gazeThrustDenHC




gazeThrustLC <- ggplot(data=lowCurve, aes(x=Condition, y=rHpH, colour=Condition)) + stat_summary(fun.y=mean, geom = "point", size=3)+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + ylim(-1,1)  +
  ggtitle('Average cross-correlation coefficient - Gaze/Thrust angles') + theme(legend.position = "none")#+ geom_point()
gazeThrustLC

gazeThrustDenLC <- ggplot(data=lowCurve, aes(x=rHpH, colour=Condition)) + geom_density() + coord_flip()  + ggtitle('Density - xCorr Gaze/Thrust angles') 
gazeThrustDenLC




grid.arrange(gazeThrust, gazeThrustDen,
             gazeThrustHC, gazeThrustDenHC,
             gazeThrustLC, gazeThrustDenLC, nrow=3)

#avgGTlag <- ggplot(data=orientationData, aes(x=Subject, y=rGH, colour=highCurve))+ geom_violin() + ggtitle('Average cross-correlation lag - Gaze/Thrust angles') + geom_smooth(method='lm')#+ geom_point()
#avgGTlag


avgGTlag <- ggplot(data=orientationData, aes(x=, y=ApproachAngleY, colour=Subject))+ geom_point() + ggtitle('Average cross-correlation lag - Gaze/Thrust angles') + geom_smooth(method='lm')#+ geom_point()
avgGTlag


####################################################################


########################################## Camera/Heading and Thrust/Heading cross correlation





meanrCT <- aggregate(orientationData$rCT, list(orientationData$Subject, orientationData$Condition), FUN=mean)

colnames(meanrCT) <- c('Subject','Condition','rCT')

avgCT <- ggplot(data=meanrCT, aes(y=rCT, x=Condition, colour=Condition)) + geom_point()+ stat_summary(fun.y=mean, geom = "point", size=3)+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + ylim(-1,1) + ggtitle('Average cross-correlation coefficient - Camera/Thrust angles')#+ geom_point()
avgCT


meanLagCT <- aggregate(orientationData$lagCT, list(orientationData$Subject, orientationData$Condition, orientationData$block), FUN=mean)

colnames(meanLagCT) <- c('Subject','Condition','block','lagCT')

avgCT <- ggplot(data=meanLagCT, aes(y=lagCT/60, x=Condition, colour=Condition)) + geom_point()+ stat_summary(fun.y=mean, geom = "point", size=3) + ylab('Lag (s)')+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + ggtitle('Average cross-correlation lag - Camera/Thrust angles')#+ geom_point()
avgCT


