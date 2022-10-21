library('ggplot2')
library('lme4')
library(lmerTest)
library(nlme)
library(gridExtra)
library(Hmisc)
library(tidyverse)
gazeTargetData <- read.csv('timeSeriesHoopSegmentAngles.txt', sep=',')
pointSize=3

gazeTargetData$hoopNumber[gazeTargetData$hoopNumber>42] <- gazeTargetData$hoopNumber - 42

#gazeTargetData$GazeThrust <- gazeTargetData$gazeHeadingAngle - abs(gazeTargetData$thrustHeadingAngle)

hpN <- 39

meanHoops <- aggregate(gazeTargetData$gazeHoopAngle, list(gazeTargetData$hoopNumber, gazeTargetData$timeSequence), FUN=mean)

colnames(meanHoops) <- c('hoopNumber', 'timeSequence','gazeHeadingAngle')


meanHoopsSub <- meanHoops[meanHoops$hoopNumber==hpN,]




meanThrust <- aggregate(gazeTargetData$gazeNextHoopAngle, list(gazeTargetData$hoopNumber, gazeTargetData$timeSequence), FUN=mean)

colnames(meanThrust) <- c('hoopNumber', 'timeSequence','thrustHeadingAngle')


meanThrustsSub <- meanThrust[meanThrust$hoopNumber==hpN,]


ggplot() + geom_smooth(aes(x=timeSequence, y=gazeHeadingAngle), data=meanHoopsSub) + geom_smooth(aes(x=timeSequence, y=thrustHeadingAngle, color='red'), data=meanThrustsSub) + geom_vline(xintercept=100)






meanHoops <- aggregate(gazeTargetData$gazeHoopAngle, list(gazeTargetData$timeSequence), FUN=mean)

colnames(meanHoops) <- c('timeSequence','gazeHeadingAngle')

#meanHoopsSub <- meanHoops[meanHoops$hoopNumber==hpN,]




meanThrust <- aggregate(gazeTargetData$gazeNextHoopAngle, list(gazeTargetData$timeSequence), FUN=mean)

colnames(meanThrust) <- c('timeSequence','thrustHeadingAngle')


#meanThrustsSub <- meanThrust[meanThrust$hoopNumber==hpN,]


ggplot() + geom_smooth(aes(x=timeSequence, y=gazeHeadingAngle), data=meanHoops) + geom_smooth(aes(x=timeSequence, y=thrustHeadingAngle, color='red'), data=meanThrust) + geom_vline(xintercept=100)
