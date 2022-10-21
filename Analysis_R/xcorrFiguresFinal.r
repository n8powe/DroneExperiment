library('ggplot2')
library('lme4')
library(lmerTest)
library(gridExtra)
library(tidyverse)
library(ggpubr)
library(rstatix)

orientationData <- read.csv('droneOrientationDataset120SecondCrossCorrelations.txt', sep=',')
orientationData$hoopNum[orientationData$hoopNum>42] = orientationData$hoopNum[orientationData$hoopNum>42] - 42
orientationData$highCurve <- abs(orientationData$prevHoopVisualAngle)>30
#orientationData <- orientationData[orientationData$numberCollisions<5,]

orientationData$absVisualAngleBetweenHoops <- abs(orientationData$VisualAngleBetweenHoops)
orientationData$absPrevAngleBetweenHoops <- abs(orientationData$prevHoopVisualAngle)

ggplot(data=orientationData, aes(x=Condition, y=rTH_GH, colour=Condition)) + stat_summary(fun.y=mean, geom = "point", size=3)+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + geom_smooth(method='lm')


ggplot(data=orientationData, aes(x=absVisualAngleBetweenHoops, y=rTH_GH, colour=Condition)) + geom_point() + geom_smooth(method='lm')


ggplot(data=orientationData, aes(x=dirChange, y=rTH_GH, colour=Condition)) + geom_point() + geom_smooth(method='lm')

##############################################################################


meanrGH <- aggregate(orientationData$rTH_GH, list( orientationData$Subject, orientationData$Condition, orientationData$hoopNum), FUN=mean)

colnames(meanrGH) <- c('Subject', 'Condition', 'hoopNum', 'rTH_GH')

gazeThrust <- ggplot(data=meanrGH, aes(x=Condition, y=rTH_GH, colour=Condition)) + stat_summary(fun.y=mean, geom = "point", size=3)+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + ylim(-1,1)  +
  ggtitle('Average cross-correlation coefficient - Gaze/Thrust angles') + theme(legend.position = "none")#+ geom_point()
gazeThrust

gazeThrustDen <- ggplot(data=orientationData, aes(x=rTH_GH, colour=Condition)) + geom_density() + coord_flip()  + ggtitle('Density - xCorr Gaze/Thrust angles') 
gazeThrustDen


#########################



meanrGH <- aggregate(orientationData$lagTH_GH, list( orientationData$Subject, orientationData$Condition, orientationData$hoopNum), FUN=mean)

colnames(meanrGH) <- c('Subject', 'Condition', 'hoopNum', 'lagTH_GH')

gazeThrust <- ggplot(data=meanrGH, aes(x=Condition, y=lagTH_GH/60, colour=Condition)) + stat_summary(fun.y=mean, geom = "point", size=3)+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + ylim(-1,1)  +
  ggtitle('Average cross-correlation coefficient - Gaze/Thrust angles') + theme(legend.position = "none")#+ geom_point()
gazeThrust

gazeThrustDen <- ggplot(data=orientationData, aes(x=lagTH_GH/60, colour=Condition)) + geom_density() + coord_flip()  + ggtitle('Density - xCorr Gaze/Thrust angles') 
gazeThrustDen


##########################


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



##############################################################################


meanrGH <- aggregate(orientationData$rTH_CH, list( orientationData$Subject, orientationData$Condition, orientationData$hoopNum), FUN=mean)

colnames(meanrGH) <- c('Subject', 'Condition', 'hoopNum', 'rTH_CH')

gazeThrust <- ggplot(data=meanrGH, aes(x=Condition, y=rTH_CH, colour=Condition)) + stat_summary(fun.y=mean, geom = "point", size=3)+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + ylim(-1,1)  +
  ggtitle('Average cross-correlation coefficient - Gaze/Thrust angles') + theme(legend.position = "none")#+ geom_point()
gazeThrust

gazeThrustDen <- ggplot(data=orientationData, aes(x=rTH_CH, colour=Condition)) + geom_density() + coord_flip()  + ggtitle('Density - xCorr Gaze/Thrust angles') 
gazeThrustDen



##############################################################################




meanrGH <- aggregate(orientationData$rGH_GHp, list( orientationData$Subject, orientationData$Condition, orientationData$hoopNum), FUN=mean)

colnames(meanrGH) <- c('Subject', 'Condition', 'hoopNum', 'rGH_GHp')

gazeThrust <- ggplot(data=meanrGH, aes(x=Condition, y=rGH_GHp, colour=Condition)) + stat_summary(fun.y=mean, geom = "point", size=3)+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + ylim(-1,1)  +
  ggtitle('Average cross-correlation coefficient - Gaze/Thrust angles') + theme(legend.position = "none")#+ geom_point()
gazeThrust

gazeThrustDen <- ggplot(data=orientationData, aes(x=rGH_GHp, colour=Condition)) + geom_density() + coord_flip()  + ggtitle('Density - xCorr Gaze/Thrust angles') 
gazeThrustDen



