library('ggplot2')

library('lme4')
library(lmerTest)
library(gridExtra)
library(Hmisc)
library(tidyverse)
library(sjmisc)


gazeTargetData <- read.csv('timeSeriesHoopSegmentAngles_allSubjects.txt', sep=',')

#gazeTargetData <- gazeTargetData[gazeTargetData$Sub=="Experiment1/P_210930142529_100",]

gazeTargetData$throughHoopBool <- 0 #lapply(as.character(gazeTargetData$throughHoopData), FUN=is_empty)
gazeTargetData$atHoopBool <- 0

numRows <- length(gazeTargetData$throughHoopData)

maxTime = max(gazeTargetData$timeSequence)
countTimes <- rep(0, maxTime)
hoopCollisionData <- rep(0, 84)


for (j in 1:84) {
  currHoopData <- gazeTargetData[gazeTargetData$hoopNumber==j,]
  
  currHoopData$currCollisionDataConverted <- (!as.character(currHoopData$currCollisionData)=="")*1
  hoopCollisionData[j] <- sum(currHoopData$currCollisionDataConverted)
}

nonZeroCollisionIndices <- ((hoopCollisionData==0)*1)*1:84
nonZeroCollisionIndices <- nonZeroCollisionIndices[nonZeroCollisionIndices!=0]
gazeTargetDataCollisionsRemoved <- gazeTargetData #subset(gazeTargetData, hoopNumber %in% nonZeroCollisionIndices)
#gazeTargetDataCollisionsRemoved$throughHoopBool <- 0 #lapply(as.character(gazeTargetData$throughHoopData), FUN=is_empty)
#gazeTargetDataCollisionsRemoved$atHoopBool <- 0


#gazeTargetDataCollisionsRemoved <- gazeTargetData
numRows <- length(gazeTargetDataCollisionsRemoved$throughHoopData)

maxTime = max(gazeTargetDataCollisionsRemoved$timeSequence)
countTimes <- rep(0, maxTime)
throughHoopCountTimes <- rep(0, maxTime)


for (i in 1:numRows){
  
  currGazeHoop <- as.character(gazeTargetDataCollisionsRemoved$throughHoopData[i])
  
  
  currGazeTarget <- gazeTargetDataCollisionsRemoved$gazeTarget[i]
  GazeTargetParsed <- str_split(as.character(currGazeTarget), ' ')
  if (GazeTargetParsed[[1]][1] == 'RoundGate'){
    gazeTargetDataCollisionsRemoved$atHoopBool[i] <- 1
  }
  
  
  countTimes[gazeTargetDataCollisionsRemoved$timeSequence[i]] <- countTimes[gazeTargetDataCollisionsRemoved$timeSequence[i]] + 1
  #print (countTimes)
  
  if (is.null(currGazeHoop) | currGazeHoop=='' | currGazeHoop=="NULL") {
    lookingAtHoop = F
  } else if (!is.null(currGazeHoop) | currGazeHoop!='' | currGazeHoop!="NULL") {
    gazeTargetDataCollisionsRemoved$throughHoopBool[i] <- 1
    throughHoopCountTimes[gazeTargetDataCollisionsRemoved$timeSequence[i]] <-  throughHoopCountTimes[gazeTargetDataCollisionsRemoved$timeSequence[i]] + 1
  }
  
}

scaleFUN <- function(x) sprintf("%.2f", x)

gazeTargetDataCollisionsRemoved$timeSequenceBool <- 1


dd <- aggregate(cbind(gazeTargetDataCollisionsRemoved$throughHoopData, gazeTargetDataCollisionsRemoved$timeSequenceBool), by=list(gazeTargetDataCollisionsRemoved$timeSequence, gazeTargetDataCollisionsRemoved$Sub), FUN=sum)
colnames(dd) <- c('time','Subject', 'throughHoop', 'timeCounts')
#dd$timeCounts <- countTimes
dd$ratioTime <- dd$throughHoop/dd$timeCounts


ddAll <- aggregate(cbind(gazeTargetDataCollisionsRemoved$throughHoopData, gazeTargetDataCollisionsRemoved$timeSequenceBool), by=list(gazeTargetDataCollisionsRemoved$timeSequence), FUN=sum)
colnames(ddAll) <- c('time', 'throughHoop', 'timeCounts')
#dd$timeCounts <- countTimes
ddAll$ratioTime <- ddAll$throughHoop/ddAll$timeCounts


hoopCenter <- ggplot() + geom_line(data=dd, aes(x=-time/60, y=ratioTime, color=Subject)) + geom_line(data=ddAll, aes(x=-time/60, y=ratioTime), size=1.2) +
  ylim(0,1) + ggtitle('Through Hoop Gaze Ratio') + xlim(-5,0)+ theme(legend.position = "none")+ xlab("Time (Sec.)") + ylab("Ratio of frames")+theme(text = element_text(size=18))+ scale_y_continuous(labels=scaleFUN)#+ geom_smooth()
hoopCenter



dd2 <- aggregate(cbind(gazeTargetDataCollisionsRemoved$atHoopBool, gazeTargetDataCollisionsRemoved$timeSequenceBool), by=list(gazeTargetDataCollisionsRemoved$timeSequence, gazeTargetDataCollisionsRemoved$Sub), FUN=sum)
colnames(dd2) <- c('time','Subject', 'atHoop', 'timeCounts')

dd2$ratioTime <- dd2$atHoop/dd2$timeCounts


ddAll2 <- aggregate(cbind(gazeTargetDataCollisionsRemoved$atHoopBool, gazeTargetDataCollisionsRemoved$timeSequenceBool), by=list(gazeTargetDataCollisionsRemoved$timeSequence), FUN=sum)
colnames(ddAll2) <- c('time', 'atHoop', 'timeCounts')
#dd$timeCounts <- countTimes
ddAll2$ratioTime <- ddAll2$atHoop/ddAll2$timeCounts



hoopEdge <- ggplot() + geom_line(data=dd2, aes(x=-time/60, y=ratioTime, color=Subject)) + geom_line(data=ddAll2, aes(x=-time/60, y=ratioTime), size=1.2)+
  ylim(0,1)+ ggtitle('Hoop Edge Gaze Ratio')+ xlim(-5,0)+ theme(legend.position = "none")+ xlab("Time (Sec.)") + ylab("Ratio of frames")+theme(text = element_text(size=18))+ scale_y_continuous(labels=scaleFUN)
hoopEdge


grid.arrange(hoopCenter, hoopEdge, nrow=2)


dd2$AllHoopRatio <- dd$ratioTime + dd2$ratioTime
dd2$AllHoopRatio[dd2$AllHoopRatio>1] <- 1
meanTime <- -mean(noNaNData$timeBetweenHoops)/60

ddAlltotal <- aggregate(cbind(dd2$AllHoopRatio), by=list(dd2$time), FUN=mean)
colnames(ddAlltotal) <- c('time', 'timeRatio')

totalHoopPlot <- ggplot() + geom_line(data=dd2, aes(x=-time/60, y=AllHoopRatio, color=Subject)) + geom_line(data=ddAlltotal, aes(x=-time/60, y=timeRatio), size=1.2)+
  xlab("Time (Sec.)") + ylab("Ratio of frames")+ xlim(-5,0)+ theme(legend.position = "none")+ ggtitle('Hoop combined ratio')+theme(text = element_text(size=18))+ scale_y_continuous(labels=scaleFUN)



orientationData <- read.csv('droneOrientationDataset120SecondCrossCorrelations_leaveOut_oldGazeTarget.txt', sep=',')
#orientationData <- orientationData[orientationData$numberCollisions<5,]
noPathOnly <- orientationData[orientationData$Condition=="HoopOnly" | orientationData$Condition=="PathAndHoops",]
noNaNData <- na.omit(noPathOnly)

medianTime <- -median(noNaNData$timeBetweenHoops)/60
meanTime <- -mean(noNaNData$timeBetweenHoops)/60
timeDensPlot <- ggplot(noNaNData, aes(x=-timeBetweenHoops/60)) + geom_density(size=1) + xlim(-5,0) + geom_vline(aes(xintercept=medianTime, color="red"))+ geom_vline(aes(xintercept=meanTime))+ theme(legend.position = "none")+ 
  xlab("Time (Sec.)") + ylab("P")+ ggtitle('Density of hoop segment lengths')+theme(text = element_text(size=18))+ scale_y_continuous(labels=scaleFUN)

grid.arrange(hoopCenter, 
             hoopEdge, 
             totalHoopPlot, 
             timeDensPlot, nrow=4)
