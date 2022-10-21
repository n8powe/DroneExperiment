library('ggplot2')
library('lme4')
library(lmerTest)
library(gridExtra)
library(Hmisc)
library(tidyverse)
gazeTrajectoryData <- read.csv('droneGazeTrajectoryDataset.txt', sep=',')
gazeTrajectoryData <- na.omit(gazeTrajectoryData)

levels(gazeTrajectoryData$Condition)[levels(gazeTrajectoryData$Condition)=="/HoopOnly/"] <- "Hoop Only"
levels(gazeTrajectoryData$Condition)[levels(gazeTrajectoryData$Condition)=="/PathAndHoops/"] <- "Path and Hoops"


subject_list <- unique(gazeTrajectoryData$Subject)
Condition_list <- unique(gazeTrajectoryData$Condition)

numSubject <-  6
numCond <- 2
numBlocks <- 5


Subject <- rep(0, numSubject*numCond*numBlocks)
Condition <- rep(0, numSubject*numCond*numBlocks)
Block <- rep(0, numSubject*numCond*numBlocks)
one <- rep(0, numSubject*numCond*numBlocks)
two <- rep(0, numSubject*numCond*numBlocks)
three <- rep(0, numSubject*numCond*numBlocks)
four <- rep(0, numSubject*numCond*numBlocks)
trajectoryCountDF <- data.frame(Subject=Subject, Condition=Condition, Block=Block, One=one, Two=two, Three=three, Four=four)

movingStraightThroughHoopAndLookingThroughHoopALL <- 0 
notMovingThroughHoopAndLookingAtHoopALL <- 0
movingStraightThroughHoopNotLookingThroughHoopALL <- 0
notMovingThroughHoopAndNotLookingThroughHoopALL <- 0

Ind <- 1

for (sb in subject_list) {


  subData <- gazeTrajectoryData[gazeTrajectoryData$Subject==sb, ]
  
  for (Cond in Condition_list) {
  
    condData <- subData[subData$Condition==Cond,]
  
    for (block in 1:numBlocks) {
    
      blockData <- condData[condData$Block==block,]
      
      numRows <- length(blockData$GazeThroughGate)
      numRows
      
      movingStraightThroughHoopAndLookingThroughHoop <- 0 
      notMovingThroughHoopAndLookingAtHoop <- 0
      movingStraightThroughHoopNotLookingThroughHoop <- 0
      notMovingThroughHoopAndNotLookingThroughHoop <- 0
      
      movingThroughHoopGazeTargets <- c()
      
      hoopEdgesWhileMovingThroughHoop <- 0
      
      
      blockData$GazeThroughGate <- as.character(blockData$GazeThroughGate)
      
      for (i in 1:numRows){
        
        currStraight <- blockData$StraightPathBool[i]
        currHeadingTarget <- blockData$HeadingTarget[i]
        currGazeHoop <- as.character(blockData$GazeThroughGate[i])
        
        currGazeTarget <- blockData$GazeTarget[i]
        
        headingTargetParsed <- str_split(currHeadingTarget, ' ')
        
        
        if (headingTargetParsed[[1]][1] == 'RoundGate') {
          headingThroughHoop = T
        } else {
          headingThroughHoop = F
        }
        
        
        if (is.null(currGazeHoop) | currGazeHoop=='' | currGazeHoop=="NULL") {
          lookingAtHoop = F
        } else if (!is.null(currGazeHoop) | currGazeHoop!='' | currGazeHoop!="NULL") {
          lookingAtHoop = T
        }
        
        
        
        if ( (currStraight & headingThroughHoop) & lookingAtHoop  ) {
          movingStraightThroughHoopAndLookingThroughHoop <- movingStraightThroughHoopAndLookingThroughHoop + 1
          movingStraightThroughHoopAndLookingThroughHoopALL <- movingStraightThroughHoopAndLookingThroughHoopALL +1 
        } else if ( (currStraight & headingThroughHoop) & !lookingAtHoop) {
          movingStraightThroughHoopNotLookingThroughHoop <- movingStraightThroughHoopNotLookingThroughHoop + 1
          movingStraightThroughHoopNotLookingThroughHoopALL <- movingStraightThroughHoopNotLookingThroughHoopALL +1
          movingThroughHoopGazeTargets[i] <- as.character(currGazeTarget)
          
          GazeTargetParsed <- str_split(as.character(currGazeTarget), ' ')
          
          if (GazeTargetParsed[[1]][1] == 'RoundGate'){
            hoopEdgesWhileMovingThroughHoop <- hoopEdgesWhileMovingThroughHoop + 1
          }
          
          
          #print ('MovingStraightAndNotLooking')
        } else if ( (!currStraight | !headingThroughHoop) &  lookingAtHoop) {
          notMovingThroughHoopAndLookingAtHoop <- notMovingThroughHoopAndLookingAtHoop + 1
          notMovingThroughHoopAndLookingAtHoopALL <- notMovingThroughHoopAndLookingAtHoopALL + 1
        } else if((!currStraight | !headingThroughHoop) & !lookingAtHoop){
          notMovingThroughHoopAndNotLookingThroughHoop <- notMovingThroughHoopAndNotLookingThroughHoop + 1
          notMovingThroughHoopAndNotLookingThroughHoopALL <- notMovingThroughHoopAndNotLookingThroughHoopALL + 1
          #print ('notMovingStraightAndNotLooking')
        }
      }
      
      trajectoryCountDF$Subject[Ind] <- sb
      trajectoryCountDF$Condition[Ind] <- Cond
      trajectoryCountDF$Block[Ind] <- block
      trajectoryCountDF$One[Ind] <- movingStraightThroughHoopAndLookingThroughHoop/numRows
      trajectoryCountDF$Two[Ind] <-  movingStraightThroughHoopNotLookingThroughHoop/numRows
      trajectoryCountDF$Three[Ind] <- notMovingThroughHoopAndLookingAtHoop/numRows
      trajectoryCountDF$Four[Ind] <- notMovingThroughHoopAndNotLookingThroughHoop/numRows
      
      
      Ind <- Ind + 1
      
    }
    
    
  }
  
  
  movingStraightThroughHoopAndLookingThroughHoop
  
  movingStraightThroughHoopNotLookingThroughHoop
  
  notMovingThroughHoopAndLookingAtHoop
  
  notMovingThroughHoopAndNotLookingThroughHoop
  
  
}


numFramesALL <- movingStraightThroughHoopAndLookingThroughHoopALL + notMovingThroughHoopAndLookingAtHoopALL +movingStraightThroughHoopNotLookingThroughHoopALL + notMovingThroughHoopAndNotLookingThroughHoopALL

movingStraightThroughHoopAndLookingThroughHoopALL/numFramesALL
notMovingThroughHoopAndLookingAtHoopALL/numFramesALL
movingStraightThroughHoopNotLookingThroughHoopALL/numFramesALL 
notMovingThroughHoopAndNotLookingThroughHoopALL/numFramesALL 


levels(trajectoryCountDF$Condition)[levels(trajectoryCountDF$Condition)=="/HoopOnly/"] <- "Hoop Only"
levels(trajectoryCountDF$Condition)[levels(trajectoryCountDF$Condition)=="/PathAndHoops/"] <- "Path and Hoops"

onePlot <- ggplot(data=trajectoryCountDF, aes(x=Condition, y=One, color=Subject)) +  
  stat_summary(fun.y=mean, geom = "point", size=4, position=position_dodge(width = .3)) +theme(text = element_text(size=18))+
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.3, position="dodge") + ylim(0,1)+ ylab('Prop. frames') + ggtitle('Heading and gaze through hoop center')+ theme(legend.position = "none")



twoPlot <- ggplot(data=trajectoryCountDF, aes(x=Condition, y=Two, color=Subject)) +  
  stat_summary(fun.y=mean, geom = "point", size=4, position=position_dodge(width = .3)) +theme(text = element_text(size=18))+
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.3, position="dodge")+ ylim(0,1)+ ylab('Prop. frames')  + ggtitle('Heading aligned through hoop center but not gaze')+ theme(legend.position = "none")



threePlot <- ggplot(data=trajectoryCountDF, aes(x=Condition, y=Three, color=Subject)) +  
  stat_summary(fun.y=mean, geom = "point", size=4, position=position_dodge(width = .3)) +theme(text = element_text(size=18))+
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.3, position="dodge")+ ylim(0,1)+ ylab('Prop. frames') + ggtitle('Gaze aligned through hoop center but not heading')+ theme(legend.position = "none")



fourPlot <- ggplot(data=trajectoryCountDF, aes(x=Condition, y=Four, color=Subject)) +  
  stat_summary(fun.y=mean, geom = "point", size=4, position=position_dodge(width = .3))+theme(text = element_text(size=18)) + 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.3, position="dodge")+ ylim(0,1) + ylab('Prop. frames') + ggtitle('Neither heading nor gaze through hoop center')+ theme(legend.position = "none")





grid.arrange(onePlot, twoPlot,
             threePlot, fourPlot, nrow=2)




hoopEdgesWhileMovingThroughHoop/movingStraightThroughHoopNotLookingThroughHoop


countsThroughHoopGaze <- table(movingThroughHoopGazeTargets)


movingStraightThroughHoopAndLookingThroughHoop


movingStraightThroughHoopNotLookingThroughHoop


notMovingThroughHoopAndLookingAtHoop

notMovingThroughHoopAndNotLookingThroughHoop






numRows
movingStraightThroughHoopAndLookingThroughHoop + movingStraightThroughHoopNotLookingThroughHoop + notMovingThroughHoopAndLookingAtHoop + notMovingThroughHoopAndNotLookingThroughHoop

counts <- c(movingStraightThroughHoopAndLookingThroughHoop, movingStraightThroughHoopNotLookingThroughHoop, notMovingThroughHoopAndLookingAtHoop, notMovingThroughHoopAndNotLookingThroughHoop)
squareNames <- factor(c('MovingStraightThroughHoopLookingAtHoop','MovingStraightThroughHoopNotLookingAtHoop','NotMovingThroughHoopLookingAtHoop','NotMovingThroughHoopNotLookingAtHoop'))

ggplot(aes(x=squareNames, y=counts)) + geom_bar()
plot(squareNames, counts)





