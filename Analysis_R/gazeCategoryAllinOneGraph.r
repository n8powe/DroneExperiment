library('ggplot2')
library('lme4')
library(lmerTest)
library(nlme)
library(gridExtra)
library(Hmisc)
library(tidyverse)
library(effectsize)
library(data.table)
gazeTargetData <- read.csv('gazeObjectDatasetCloseTrees_finalLast.txt', sep=',')
colnames(gazeTargetData)[5] <- "hoopCenter"
colnames(gazeTargetData)[4] <- "hoopEdges"

gazeTargetData$hoopCenter[gazeTargetData$condition=="PathOnly"] <- 0



gazeTargetData$percToTerrain4deg
longDF <- melt(setDT(gazeTargetData), id.vars = c("subject", "condition", "b", "meanDistanceToPathGazeTerrain", "percToTerrain4deg"), variable.name = "ObjectCategory", value="Proportion")



longDF <- longDF[longDF$condition=="PathOnly", ]

ggplot(data=longDF, aes(x=condition, y=Proportion, color=ObjectCategory, fill=ObjectCategory)) +  
  stat_summary(fun.y=mean,geom = "bar", size=1, width=0.23, position = position_dodge(width = 0.42))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position = position_dodge(width = 0.42), color="black") + ylim(0,1)+
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=4.0,vjust = -4.5,  position = position_dodge(width = 0.43))+
  xlab("Condition") + ylab("Proportion of time")  +theme(text = element_text(size=18))
  #geom_text(aes(x=1.3,y=1), label="Proportion of time gazing at object type", size=8, color="Black")

gazeTargetData <- read.csv('gazeObjectDatasetCloseTrees_finalLast.txt', sep=',')
gazeTargetData <- gazeTargetData[gazeTargetData$condition=="PathOnly",]
#levels(gazeTargetData$condition) <- c("Dense Trees", "Sparse Trees")
ggplot(data=gazeTargetData, aes(x=condition, y=percToTerrain4deg, fill=condition)) +  
  stat_summary(fun.y=mean,geom = "bar", size=0.5, width=0.53)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, color="black") + ylim(0,1) + 
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=5.0,vjust = -2.5)+
  ylab("Prop. Time")+theme(text = element_text(size=18)) + xlab("Condition")+ theme(legend.position = "none")







gazeTargetData <- read.csv('gazeAnglesToPathCenterExp1_oldgazetargets.txt', sep=',')

levels(gazeTargetData$Condition)


gazeTargetData <- gazeTargetData[gazeTargetData$Condition=="/PathOnly/",]
#levels(gazeTargetData$condition) <- c("Dense Trees", "Sparse Trees")
ggplot(data=gazeTargetData, aes(x=Condition, y=Distance, fill=Object)) +  
  stat_summary(fun.y=mean,geom = "bar", size=0.5, width=0.43,  position = position_dodge(width = 0.45))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, color="black",  position = position_dodge(width = 0.45)) + 
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=5.0,vjust = -1.5)+
  ylab("Distance(m)")+theme(text = element_text(size=18)) + xlab("Condition") + ylim(0,10)

ggplot(gazeTargetData, aes(x = Distance, color = Subject)) +
  geom_density(size=1)  +theme(text = element_text(size=18))+ xlab("Distance(m)")+
  xlim(0, 20)+ theme(legend.position = "none") + geom_vline(aes(xintercept=median(gazeTargetData$Distance)), linetype='dashed', size=1) +
  geom_text(aes(x=median(gazeTargetData$Distance)+2,y=0.6, label=paste(round(median(gazeTargetData$Distance), digits=2), "m", sep="")), size=5, color="Black")

