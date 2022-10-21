library('ggplot2')
library('lme4')
library(lmerTest)
library(gridExtra)
library(Hmisc)
library(tidyverse)
library(zoo)

tsData <- read.csv('timeSeriesHoopSegmentAngles.txt',sep=',')

tsData <- na.omit(tsData)

df <- data.frame(time=tsData$timeSequence, gaze=tsData$gazeHeadingAngle, thrust = tsData$thrustHeadingAngle)

require(plyr)
func <- function(xx)
{
  return(data.frame(COR = cor(xx$thrustHeadingAngle, xx$gazeHeadingAngle)))
}

globalCorr <- ddply(tsData, .(hoopNumber), func)

ggplot(data=globalCorr, aes(x=hoopNumber, y=COR)) + geom_point()








conv <- function(x)
{
  return(convolve())
}


rollingCorr <- rollapply(df, width=15, function(x) cor(x[,2],x[,3]), by.column=F, fill=NA)


tsData$rollingCorr <- rollingCorr

plot(tsData$timeSequence, tsData$rollingCorr)


ggplot(data=tsData, aes(x=timeSequence, y=rollingCorr)) + geom_smooth()


