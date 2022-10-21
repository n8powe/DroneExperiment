library('ggplot2')

library('lme4')
library(lmerTest)
library(gridExtra)
library(Hmisc)
library(tidyverse)
library(sjmisc)



gazeTargetDataFull <- read.csv('timeSeriesHoopSegmentAngles_allSubjects_grad.txt', sep=',')
gazeTargetDataFull <- gazeTargetDataFull[gazeTargetDataFull$collisions==0,]

gazeTargetData <- gazeTargetDataFull[gazeTargetDataFull$velX>0.001 | gazeTargetDataFull$velY>0.001  | gazeTargetDataFull$velZ>0.001  ,]

#gazeTargetData$rateCameraHeading[abs(gazeTargetData$rateCameraHeading)>1] = NaN

#gazeTargetData$rateCameraHeading <- (gazeTargetData$rateCameraHeading)/60

gazeTargetData$rateCameraHeading[abs(gazeTargetData$rateCameraHeading)>100] = NaN

ggplot(data=gazeTargetData, aes(x=Cond, y=cameraHeading)) +  stat_summary(fun.y=mean,geom = "point", size=3)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) 

ggplot(gazeTargetData, aes(x = cameraHeading, fill = Cond)) + 
  geom_histogram(alpha = 0.5, position = "identity")


pathOnlyData <- gazeTargetData[ gazeTargetData$Cond == "PathOnly", ]
hoopOnlyData <- gazeTargetData[ gazeTargetData$Cond == "HoopOnly", ]
pathAndHoopData <- gazeTargetData[ gazeTargetData$Cond == "PathAndHoops", ]

meanPathOnly <- mean(pathOnlyData$cameraHeading)
meanHoopOnly <- mean(hoopOnlyData$cameraHeading)
meanPathAndHoops <- mean(pathAndHoopData$cameraHeading)

sdmeanPathOnly <- sd(pathOnlyData$cameraHeading)
sdmeanHoopOnly <- sd(hoopOnlyData$cameraHeading)
sdmeanPathAndHoops <- sd(pathAndHoopData$cameraHeading)


absmeanPathOnly <- mean(abs(pathOnlyData$cameraHeading))
absmeanHoopOnly <- mean(abs(hoopOnlyData$cameraHeading))
absmeanPathAndHoops <- mean(abs(pathAndHoopData$cameraHeading))

sdmeanPathOnly <- mean(sd(abs(pathOnlyData$cameraHeading)))
sdmeanHoopOnly <- mean(sd(abs(hoopOnlyData$cameraHeading)))
sdmeanPathAndHoops <- mean(sd(abs(pathAndHoopData$cameraHeading)))


ratemeanPathOnly <- mean(pathOnlyData$rateCameraHeading, na.rm = TRUE)
ratemeanHoopOnly <- mean(hoopOnlyData$rateCameraHeading, na.rm = TRUE)
ratemeanPathAndHoops <- mean(pathAndHoopData$rateCameraHeading, na.rm = TRUE)

sdratemeanPathOnly <- sd(pathOnlyData$rateCameraHeading, na.rm = TRUE)
sdratemeanHoopOnly <- sd(hoopOnlyData$rateCameraHeading, na.rm = TRUE)
sdratemeanPathAndHoops <- sd(pathAndHoopData$rateCameraHeading, na.rm = TRUE)



pplot <- ggplot(pathOnlyData, aes(x = cameraHeading, fill = Cond)) + 
  geom_density(alpha = 0.9, position = "identity", binwidth=2)+ theme(legend.position = "none") + ggtitle('Path Only') +
  xlab('Angle between camera & heading (deg)')+theme(text = element_text(size=18))+ 
  geom_vline(aes(xintercept=meanPathOnly), color="blue", size=1) +geom_vline(aes(xintercept=meanPathOnly+sdmeanPathOnly), color="blue", linetype = "dashed", size=1) +geom_vline(aes(xintercept=meanPathOnly-sdmeanPathOnly), color="blue", linetype = "dashed", size=1) 

hplot <- ggplot(hoopOnlyData, aes(x = cameraHeading, fill = Cond)) + 
  geom_density(alpha = 0.9, position = "identity", binwidth=2)+ theme(legend.position = "none")+ ggtitle('Hoop Only')+ 
  xlab('Angle between camera & heading (deg)')+theme(text = element_text(size=18))+ 
  geom_vline(aes(xintercept=meanHoopOnly), color="blue", size=1) + geom_vline(aes(xintercept=meanHoopOnly+sdmeanHoopOnly), color="blue", linetype = "dashed", size=1) + geom_vline(aes(xintercept=meanHoopOnly-sdmeanHoopOnly), color="blue", linetype = "dashed", size=1)

phplot <- ggplot(pathAndHoopData, aes(x = cameraHeading, fill = Cond)) + 
  geom_density(alpha = 0.9, position = "identity", binwidth=2) + theme(legend.position = "none")+ ggtitle('Path and Hoops')+ 
  xlab('Angle between camera & heading (deg)')+theme(text = element_text(size=18))+ 
  geom_vline(aes(xintercept=meanPathAndHoops), color="blue", size=1) + geom_vline(aes(xintercept=meanPathAndHoops+sdmeanPathAndHoops), color="blue", linetype = "dashed", size=1) + geom_vline(aes(xintercept=meanPathAndHoops-sdmeanPathAndHoops), color="blue", linetype = "dashed", size=1)




ratepplot <- ggplot(pathOnlyData, aes(x = rateCameraHeading, fill = Cond))+ xlim(-100,100) + 
  geom_density(alpha = 0.9, position = "identity", binwidth=2)+ theme(legend.position = "none") + ggtitle('Path Only') + 
  xlab('Change in Angle between camera & heading (deg/s)')+theme(text = element_text(size=18))+ 
  geom_vline(aes(xintercept=ratemeanPathOnly), color="blue", size=1) +  geom_vline(aes(xintercept=ratemeanPathOnly+sdratemeanPathOnly), color="blue", linetype = "dashed", size=1) + geom_vline(aes(xintercept=ratemeanPathOnly-sdratemeanPathOnly), color="blue", linetype = "dashed", size=1) 

ratehplot <- ggplot(hoopOnlyData, aes(x = rateCameraHeading, fill = Cond)) + xlim(-100,100) +
  geom_density(alpha = 0.9, position = "identity", binwidth=2)+ theme(legend.position = "none")+ ggtitle('Hoop Only')+ 
  xlab('Change in Angle between camera & heading (deg/s)')+theme(text = element_text(size=18))+ 
  geom_vline(aes(xintercept=ratemeanHoopOnly), color="blue", size=1) + geom_vline(aes(xintercept=ratemeanHoopOnly+sdratemeanHoopOnly), color="blue", linetype = "dashed", size=1) + geom_vline(aes(xintercept=ratemeanHoopOnly-sdratemeanHoopOnly), color="blue", linetype = "dashed", size=1)

ratephplot <- ggplot(pathAndHoopData, aes(x = rateCameraHeading, fill = Cond)) + xlim(-100,100) +
  geom_density(alpha = 0.9, position = "identity", binwidth=2) + theme(legend.position = "none")+ ggtitle('Path and Hoops')+ 
  xlab('Change in Angle between camera & heading (deg/s)')+theme(text = element_text(size=18))+ 
  geom_vline(aes(xintercept=ratemeanPathAndHoops), color="blue", size=1) + geom_vline(aes(xintercept=ratemeanPathAndHoops+sdratemeanPathAndHoops), color="blue", linetype = "dashed", size=1) + geom_vline(aes(xintercept=ratemeanPathAndHoops-sdratemeanPathAndHoops), color="blue", linetype = "dashed", size=1)


grid.arrange(pplot, hplot, phplot,
             ratepplot, ratehplot, ratephplot, nrow=2)


#rateAngle <- ggplot(gazeTargetData, aes(x = thrustHeadingAngle, y=cameraHeading, color=rateCameraHeading)) +
#  geom_point(na.rm=TRUE, size=1) + ggtitle('Angle Vs Change in Angle') #+ geom_smooth(method='lm') #+ xlim(-40,40)
#rateAngle  
  




