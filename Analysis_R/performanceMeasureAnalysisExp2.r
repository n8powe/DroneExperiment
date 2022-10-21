
library('ggplot2')
library('lme4')
library(nlme)
library(lmerTest)
library(gridExtra)
library(tidyverse)
library(ggpubr)
library(rstatix)

library(effectsize)

library(data.table)
perfMeasureData <- read.csv('performanceMeasuresDatasetExperiment2.txt', sep=',')


perfMeasureData$propTimeCollisions <- perfMeasureData$noCollisions

pointSize <- 3


levels(perfMeasureData$Condition)[levels(perfMeasureData$Condition)=="PathOnly"] <- "Sparse Trees"

perfMeasureData$Condition<- recode(perfMeasureData$Condition, PathOnly = 'Sparse Trees', 
                                  DenseTrees = 'Dense Trees')


gazeTimeToPointOnPath <- ggplot(data=perfMeasureData, aes(x=Condition, y=timeToGazePoint, color=Condition))  + 
  stat_summary(fun.y=mean,geom = "point", size=4) + 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position="dodge") + ylim(0,1) + ylab("Time to gaze point on path (Sec.)") +theme(text = element_text(size=18)) + ggtitle('Time to pass gaze points on path')
gazeTimeToPointOnPath

#mTimeToGazePoint <-lmer(timeToGazePoint ~ (1|Subject/Condition) + Condition , data=perfMeasureData)
#mDistanceGaze <-lmer(avgGazeDistance ~ Condition + (1|Subject), data=perfMeasureData)


mTimeToGazePoint <- lme(timeToGazePoint ~ Condition, random= ~1|Subject/Condition, data=perfMeasureData)
mDistanceGaze <- lme(avgGazeDistance ~ Condition, random= ~1|Subject/Condition, data=perfMeasureData)


anova(mTimeToGazePoint)
F_to_eta2(0.251, 1, 2)

anova(mDistanceGaze)
F_to_eta2(0.060, 1, 2)

gazeDistanceToPointOnPath <- ggplot(data=perfMeasureData, aes(x=Condition, y=avgGazeDistance, color=Condition))  + 
  stat_summary(fun.y=mean,geom = "point", size=4) + 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position="dodge") + ylim(0,15) + ylab("Gaze Distance on path (m)") +theme(text = element_text(size=18)) + ggtitle('Distance to gaze points on path')
gazeDistanceToPointOnPath



gazeDistanceToPointOnPathAtPass <- ggplot(data=perfMeasureData, aes(x=Condition, y=meanDistanceToPointAtPass, color=Condition))  + 
  stat_summary(fun.y=mean,geom = "point", size=3) + 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position="dodge") + ylim(0,15) + ylab("Distance (m)") +theme(text = element_text(size=18)) + ggtitle("Distance to gaze point on path at pass")
gazeDistanceToPointOnPathAtPass


grid.arrange(gazeDistanceToPointOnPath, gazeTimeToPointOnPath)








# set up a datatable
data <- setDT(perfMeasureData)
# subj-specific pace
data[ , subj_speed := mean(avgSpdAdjustedForScaling), by = .(Subject)]
# general mean across conditions
data[ , overall_speed := mean(avgSpdAdjustedForScaling)]
# pace controlled for subjective pace
data[ , speed_within := avgSpdAdjustedForScaling - subj_speed + overall_speed]
# sanity check
data[ , check := mean(speed_within), by = .(Subject)]


###### Speed - condition
meanSpeed <- aggregate(perfMeasureData$avgSpdAdjustedForScaling, list(perfMeasureData$Subject, perfMeasureData$Condition, perfMeasureData$block), FUN=mean)

colnames(meanSpeed) <- c('Subject','Condition', 'Block','avgSpdAdjustedForScaling')

mSpeed <-lmer(avgSpdAdjustedForScaling ~ Condition + (1|Subject), data=data)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
#mSpeed2 <- lme(avgSpdAdjustedForScaling ~ Condition, random= ~1|Subject/Condition, data=meanSpeed) # Give roughly the same thing. lmer gives adjusted degrees of freedom
pVspeed <- anova(mSpeed)[6][["Pr(>F)"]]
pVspeed
anova(mSpeed)

F_to_eta2(4.026, 1, 2)

#mSpeed <-lme(avgSpdAdjustedForScaling ~ Condition, random = ~1|Subject, data=meanSpeed)
#anova(mSpeed)


avgSpeed <- ggplot(data=data, aes(y=speed_within, x=Condition, color=Condition)) +  stat_summary(fun.y=mean, geom = "point", size=3) + stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position="dodge")+
  ylim(0,22) + ggtitle('Average speed per lap by condition') + 
  ylab('Speed (m/s)') + xlab('Condition')+theme(text = element_text(size=18)) + 
  geom_text(aes(x=0.8,y=22, label=paste("p = ", round(pVspeed, digits=3), sep = "")), size=5, color="Black")+ 
  scale_color_manual(values = c("blue", "red")) + scale_x_discrete(labels=c("Dense Trees" = "Dense Trees", "PathOnly" = "Sparse Trees"))

avgSpeed


#meanSpeedBlock <- aggregate(perfMeasureData$avgSpdAdjustedForScaling, list(perfMeasureData$Subject, perfMeasureData$Condition, perfMeasureData$block), FUN=mean)

#colnames(meanSpeed) <- c('Subject','Condition', 'Block','avgSpdAdjustedF
meanSpeed <- aggregate(perfMeasureData$avgSpdAdjustedForScaling, list(perfMeasureData$Subject, perfMeasureData$Condition, perfMeasureData$block), FUN=mean)

colnames(meanSpeed) <- c('Subject','Condition', 'Block','avgSpdAdjustedForScaling')


avgSpeedBlock <- ggplot(data=data, aes(y=speed_within, x=block, colour=Condition)) + stat_summary(fun.y=mean,
                                                                                                              geom = "point", size=3, position=position_dodge(0.2)) + 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.15, position=position_dodge(0.2)) + ylim(0,22) + ggtitle('Average speed per lap by block') + 
  ylab('Speed (m/s)') + xlab('Block')+theme(text = element_text(size=18)) + theme(legend.position = "none")+ scale_color_manual(values = c("blue", "red")) + geom_rect(aes(xmin=4.5, xmax=5.5, ymin=0, ymax=22), fill="blue", alpha=0.001, size=1.5) + geom_text(aes(x=5, y=2.25, label="Test Block"), size=7)#+ geom_point()

avgSpeedBlock



###############


perfMeasureData <- read.csv('performanceMeasuresDatasetExperiment2.txt', sep=',')

levels(perfMeasureData$Condition)[levels(perfMeasureData$Condition)=="PathOnly"] <- "Sparse Trees"


perfMeasureData$Condition<- recode(perfMeasureData$Condition, PathOnly = 'Sparse Trees', 
                                   DenseTrees = 'Dense Trees')


pfD <- setDT(perfMeasureData)
# subj-specific pace
pfD[ , subj_dev := mean(PathDeviation), by = .(Subject)]
# general mean across conditions
pfD[ , overall_dev := mean(PathDeviation)]
# pace controlled for subjective pace
pfD[ , dev_within := PathDeviation - subj_dev + overall_dev]
# sanity check
pfD[ , check := mean(dev_within), by = .(Subject)]


meanDeviation <- aggregate(perfMeasureData$PathDeviation, list(perfMeasureData$Subject, perfMeasureData$Condition), FUN=mean)

colnames(meanDeviation) <- c('Subject','Condition','PathDeviation')

mPath <-lmer(PathDeviation ~ Condition + (1|Subject), data=pfD)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
pVpath <- anova(mPath)[6][["Pr(>F)"]]
anova(mPath)

summary(aov(PathDeviation ~ Condition, data=pfD))

F_to_eta2(1.90, 1, 2)

# Report the F statistic, P value, 




avgPathDeviation <- ggplot(data=pfD, aes(y=dev_within, x=Condition, colour=Condition)) + stat_summary(fun.y=mean,
                                                                                                      geom = "point", size=pointSize)+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + 
  ylim(0,2)+ ggtitle('Average path deviation by condition') + ylab('Path Dev. (m)') + xlab('Condition')+ theme(text = element_text(size=18)) + geom_text(aes(x=0.8,y=2, label=paste("p < ", "0.001", sep = "")), size=5, color="Black")+ scale_color_manual(values = c("blue", "red"))+ scale_x_discrete(labels=c("Dense Trees" = "Dense Trees", "PathOnly" = "Sparse Trees"))#+ geom_point()
avgPathDeviation

mPathDev <- aov(PathDeviation~Condition*Subject, data=perfMeasureData)
summary(mPathDev)

mMixedPathDev <- lmer(PathDeviation ~ Condition + 1|Subject + 1|Subject:Condition, data=perfMeasureData)
summary(mMixedPathDev)
anova(mMixedPathDev)


meanDeviation <- aggregate(perfMeasureData$PathDeviation, list(perfMeasureData$Subject, perfMeasureData$Condition, perfMeasureData$block), FUN=mean)

colnames(meanDeviation) <- c('Subject','Condition', 'Block','PathDeviation')



avgPathDeviationBlock <- ggplot(data=pfD, aes(y=dev_within, x=block, colour=Condition)) + stat_summary(fun.y=mean,
                                                                                                          geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Path Dev. (m)') + xlab('Block') + ylim(0,2)+ ggtitle('Average path deviation by block') +theme(text = element_text(size=18)) +
  geom_rect(aes(xmin=4.5, xmax=5.5, ymin=0, ymax=2), fill="black", alpha=0.001, size=1.5) + geom_text(aes(x=5, y=0.1, label="Test Block"), size=7)+ theme(legend.position = "none")+ scale_color_manual(values = c("blue", "red")) #+ geom_point()

avgPathDeviationBlock

###############################################

perfMeasureData <- read.csv('performanceMeasuresDatasetExperiment2.txt', sep=',')

levels(perfMeasureData$Condition)[levels(perfMeasureData$Condition)=="PathOnly"] <- "Sparse Trees"




perfMeasureData$Condition<- recode(perfMeasureData$Condition, PathOnly = 'Sparse Trees', 
                                   DenseTrees = 'Dense Trees')

pfD <- setDT(perfMeasureData)
# subj-specific pace
pfD[ , subj_time := mean(timeToCompleteLap), by = .(Subject)]
# general mean across conditions
pfD[ , overall_time := mean(timeToCompleteLap)]
# pace controlled for subjective pace
pfD[ , time_within := timeToCompleteLap - subj_time + overall_time]
# sanity check
pfD[ , check := mean(time_within), by = .(Subject)]

meanTime <- aggregate(perfMeasureData$timeToCompleteLap, list(perfMeasureData$Subject, perfMeasureData$Condition), FUN=mean)

colnames(meanTime) <- c('Subject','Condition','timeToCompleteLap')

mTime <-lmer(timeToCompleteLap ~ Condition + (1|Subject), data=pfD)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)

#mTime <- aov(timeToCompleteLap ~ Condition, data=meanTime)
#summary(mTime)
pVtime <- anova(mTime)[6][["Pr(>F)"]]
pVtime


anova(mTime)

F_to_eta2(2.517, 1, 2)


avgLapTime <- ggplot(data=pfD, aes(y=time_within, x=Condition, colour=Condition)) + stat_summary(fun.y=mean,
                                                                                                 geom = "point", size=pointSize)+ stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + 
  ylim(0,70)+ ggtitle('Average time to complete lap by condition')+ ylab('Time (s)') + xlab('Condition')+theme(text = element_text(size=18))+ geom_text(aes(x=0.8,y=70, label=paste("p = ", round(pVtime, digits=3), sep = "")), size=5, color="Black")+ scale_color_manual(values = c("blue", "red"))#+ geom_point()
avgLapTime

mTime <- aov(timeToCompleteLap~Condition, data=perfMeasureData)
summary(mTime)


meanTime <- aggregate(perfMeasureData$timeToCompleteLap, list(perfMeasureData$Subject, perfMeasureData$Condition, perfMeasureData$block), FUN=mean)

colnames(meanTime) <- c('Subject','Condition', 'Block','timeToCompleteLap')


avgLapTimeBlock <- ggplot(data=pfD, aes(y=time_within, x=block, colour=Condition)) + stat_summary(fun.y=mean,
                                                                                                        geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Time (s)') + xlab('Block') + ylim(0,70)+ ggtitle('Average time to complete lap by block')+theme(text = element_text(size=18)) +
  geom_rect(aes(xmin=4.5, xmax=5.5, ymin=0, ymax=70), fill="black", alpha=0.001, size=1.5) + geom_text(aes(x=5, y=9.3, label="Test Block"), size=7)+ theme(legend.position = "none")+ scale_color_manual(values = c("blue", "red")) #+ geom_point()

avgLapTimeBlock

#######################################################################



perfMeasureData <- read.csv('performanceMeasuresDatasetExperiment2.txt', sep=',')

levels(perfMeasureData$Condition)[levels(perfMeasureData$Condition)=="PathOnly"] <- "Sparse Trees"



perfMeasureData$Condition<- recode(perfMeasureData$Condition, PathOnly = 'Sparse Trees', 
                                   DenseTrees = 'Dense Trees')

perfMeasureData$propTimeCollisions <- perfMeasureData$noCollisions

pfD <- setDT(perfMeasureData)
# subj-specific pace
pfD[ , subj_col := mean(propTimeCollisions), by = .(Subject)]
# general mean across conditions
pfD[ , overall_col := mean(propTimeCollisions)]
# pace controlled for subjective pace
pfD[ , col_within := propTimeCollisions - subj_col + overall_col]
# sanity check
pfD[ , check := mean(col_within), by = .(Subject)]


meanCollisions <- aggregate(perfMeasureData$propTimeCollisions, list(perfMeasureData$Subject, perfMeasureData$Condition), FUN=mean)

colnames(meanCollisions) <- c('Subject','Condition','propTimeCollisions')

mCollisions <-lmer(propTimeCollisions ~ Condition + (1|Subject), data=pfD)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
pVcollisions <- anova(mCollisions)[6][["Pr(>F)"]]

anova(mCollisions)

F_to_eta2(1.639, 1, 2)



avgCollisionPropOfTime <- ggplot(data=pfD, aes(y=col_within, x=Condition, colour=Condition)) + stat_summary(fun.y=mean,
                                                                                                            geom = "point", size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Counts') + xlab('Condition')+ ggtitle('Number of collisions') +theme(text = element_text(size=18))+ geom_text(aes(x=0.8,y=7.9, label=paste("p = ", round(pVcollisions, digits=3), sep = "")), size=5, color="Black")+ scale_color_manual(values = c("blue", "red")) + ylim(-0.5, 8)#+ geom_point()
avgCollisionPropOfTime

mCollisions <- aov(propTimeCollisions~Condition, data=perfMeasureData)
summary(mCollisions)


meanCollisions <- aggregate(perfMeasureData$propTimeCollisions, list(perfMeasureData$Subject, perfMeasureData$Condition, perfMeasureData$block), FUN=mean)

colnames(meanCollisions) <- c('Subject','Condition', 'Block','propTimeCollisions')




avgCollisionPropOfTimeBlock <- ggplot(data=pfD, aes(y=col_within, x=block, colour=Condition)) + stat_summary(fun.y=mean,
                                                                                                                     geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Counts') + xlab('Block')+ ggtitle('Number of collisions') +theme(text = element_text(size=18)) +
  geom_rect(aes(xmin=4.5, xmax=5.5, ymin=-0.5, ymax=7), alpha=0.001, size=1.5) + geom_text(aes(x=5, y=-0.015, label="Test Block"), size=7) + theme(legend.position = "none")+ scale_color_manual(values = c("blue", "red"))+ ylim(-0.5, 8)#+ geom_point()

avgCollisionPropOfTimeBlock






grid.arrange(avgSpeed, avgSpeedBlock,
             avgLapTime, avgLapTimeBlock,
             avgPathDeviation, avgPathDeviationBlock,
             avgCollisionPropOfTime, avgCollisionPropOfTimeBlock, nrow=4)


