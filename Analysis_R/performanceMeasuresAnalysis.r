


library('ggplot2')
library('lme4')
library(nlme)
library(lmerTest)
library(gridExtra)
library(tidyverse)
library(ggpubr)
library(rstatix)
library(multcomp)
library(effectsize)
library(lsmeans)

library(data.table)
perfMeasureData <- read.csv('performanceMeasuresDataset.txt', sep=',')

#perfMeasureData <- perfMeasureData[perfMeasureData$Condition!="PathOnly",]

#perfMeasureData$PathDeviation[perfMeasureData$Condition=="HoopOnly"] <- NaN

perfMeasureData$propTimeCollisions <- perfMeasureData$noCollisions

pointSize <- 3




# set up a datatable
df <- setDT(perfMeasureData)
# subj-specific pace
df[ , subj_speed := mean(avgSpdAdjustedForScaling), by = .(Subject)]
# general mean across conditions
df[ , overall_speed := mean(avgSpdAdjustedForScaling)]
# pace controlled for subjective pace
df[ , speed_within := avgSpdAdjustedForScaling - subj_speed + overall_speed]
# sanity check
df[ , check := mean(speed_within), by = .(Subject)]
df$Condition <- factor(df$Condition)
fontSize = 15
###### Speed - condition
meanSpeed <- aggregate(perfMeasureData$avgSpdAdjustedForScaling, list(perfMeasureData$Subject, perfMeasureData$Condition, perfMeasureData$block), FUN=mean)

mean(perfMeasureData$avgSpdAdjustedForScaling)

colnames(meanSpeed) <- c('Subject','Condition', 'Block','avgSpdAdjustedForScaling')


mSpeed <-lmer(avgSpdAdjustedForScaling ~ Condition + (1|Subject), data=df)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
lsmeans(mSpeed, pairwise~Condition)
#mSpeed2 <- lme(avgSpdAdjustedForScaling ~ Condition, random= ~1|Subject/Condition, data=meanSpeed) # Give roughly the same thing. lmer gives adjusted degrees of freedom
pVspeed <- anova(mSpeed)[6][["Pr(>F)"]]
pVspeed
anova(mSpeed)

F_to_eta2(15.422, 2, 168.01)

#mSpeed <-lme(avgSpdAdjustedForScaling ~ Condition, random = ~1|Subject, data=meanSpeed)
#anova(mSpeed)


avgSpeed <- ggplot(data=df, aes(y=speed_within, x=Condition, colour=Condition)) +  stat_summary(fun.y=mean,
                                                                                                      geom = "point", size=3) + stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position="dodge")+
  ylim(0,18) + ggtitle('Average Speed') + 
  ylab('Speed (m/s)') + xlab('Condition')+theme(text = element_text(size=fontSize)) + geom_text(aes(x=0.8,y=18, label=paste("p = ", round(pVspeed, digits=3), sep = "")), size=5, color="Black")+ 
  scale_color_manual(values = c("darkgreen", "blue", "red")) + stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,vjust = -1.2)+theme(axis.title.x = element_blank())+ theme(legend.position = "none")

avgSpeed


#meanSpeedBlock <- aggregate(perfMeasureData$avgSpdAdjustedForScaling, list(perfMeasureData$Subject, perfMeasureData$Condition, perfMeasureData$block), FUN=mean)

#colnames(meanSpeed) <- c('Subject','Condition', 'Block','avgSpdAdjustedF
meanSpeed <- aggregate(perfMeasureData$avgSpdAdjustedForScaling, list(perfMeasureData$Subject, perfMeasureData$Condition, perfMeasureData$block), FUN=mean)

colnames(meanSpeed) <- c('Subject','Condition', 'Block','avgSpdAdjustedForScaling')


avgSpeedBlock <- ggplot(data=df, aes(y=avgSpdAdjustedForScaling, x=block, colour=Condition)) + stat_summary(fun.y=mean,
                                                                                                                  geom = "point", size=3, position=position_dodge(0.2)) + 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.15, position=position_dodge(0.2)) + ylim(0,18) + ggtitle('Average speed per lap by block') + 
  ylab('Speed (m/s)') + xlab('Block')+theme(text = element_text(size=18)) + theme(legend.position = "none")+ scale_color_manual(values = c("green", "blue", "red")) + geom_rect(aes(xmin=4.5, xmax=5.5, ymin=0, ymax=18), fill="blue", alpha=0.001, size=1.5) + geom_text(aes(x=5, y=2.1, label="Test Block"), size=7)#+ geom_point()

avgSpeedBlock



###############



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

F_to_eta2(2.99, 2, 168.01)

# Report the F statistic, P value, 

mean(perfMeasureData$PathDeviation)


avgPathDeviation <- ggplot(data=pfD, aes(y=dev_within, x=Condition, colour=Condition)) + stat_summary(fun.y=mean,geom = "point", size=pointSize)+ 
                    stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + 
                    ylim(0,2)+ ggtitle('Average path deviation') + 
                    ylab('Path Dev. (m)') + xlab('Condition')+ theme(text = element_text(size=fontSize)) + 
                    geom_text(aes(x=1,y=2, label=paste("p = ", round(pVpath, digits=3), sep = "")), size=5, color="Black")+ 
                    scale_color_manual(values = c("darkgreen", "blue", "red"))+ stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,vjust = -1.5)+theme(axis.title.x = element_blank())+ theme(legend.position = "none")
avgPathDeviation

mPathDev <- aov(PathDeviation~Condition*Subject, data=perfMeasureData)
summary(mPathDev)

mMixedPathDev <- lmer(PathDeviation ~ Condition + 1|Subject + 1|Subject:Condition, data=perfMeasureData)
summary(mMixedPathDev)
anova(mMixedPathDev)


meanDeviation <- aggregate(perfMeasureData$PathDeviation, list(perfMeasureData$Subject, perfMeasureData$Condition, perfMeasureData$block), FUN=mean)

colnames(meanDeviation) <- c('Subject','Condition', 'Block','PathDeviation')



avgPathDeviationBlock <- ggplot(data=pfD, aes(y=PathDeviation, x=block, colour=Condition)) + stat_summary(fun.y=mean,
                                                                                                                   geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Path Dev. (m)') + xlab('Block') + ylim(0,2)+ ggtitle('Average path deviation by block') +theme(text = element_text(size=18)) +
   geom_rect(aes(xmin=4.5, xmax=5.5, ymin=0, ymax=2), fill="black", alpha=0.001, size=1.5) + theme(legend.position = "none")+ scale_color_manual(values = c("green", "blue", "red")) #+ geom_point()

avgPathDeviationBlock

###############################################


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
lsmeans(mTime, pairwise~Condition)
#mTime <- aov(timeToCompleteLap ~ Condition, data=meanTime)
#summary(mTime)
pVtime <- anova(mTime)[6][["Pr(>F)"]]
pVtime

mean(perfMeasureData$timeToCompleteLap)
anova(mTime)

F_to_eta2(11.05, 2, 168.01)


avgLapTime <- ggplot(data=pfD, aes(y=time_within, x=Condition, colour=Condition)) + stat_summary(fun.y=mean,geom = "point", size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + 
   ylim(0,150)+ ggtitle('Average Lap Time')+ ylab('Time (s)') + 
  xlab('Condition')+theme(text = element_text(size=fontSize))+ 
  geom_text(aes(x=0.8,y=150, label=paste("p = ", round(pVtime, digits=3), sep = "")), size=5, color="Black")+ 
  scale_color_manual(values = c("darkgreen", "blue", "red"))+ stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,vjust = -1.5)+theme(axis.title.x = element_blank())+ theme(legend.position = "none")
avgLapTime

mTime <- aov(timeToCompleteLap~Condition, data=perfMeasureData)
summary(mTime)


meanTime <- aggregate(perfMeasureData$timeToCompleteLap, list(perfMeasureData$Subject, perfMeasureData$Condition, perfMeasureData$block), FUN=mean)

colnames(meanTime) <- c('Subject','Condition', 'Block','timeToCompleteLap')


avgLapTimeBlock <- ggplot(data=pfD, aes(y=timeToCompleteLap, x=block, colour=Condition)) + stat_summary(fun.y=mean,
                                                                                                            geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Time (s)') + xlab('Block') + ylim(0,150)+ ggtitle('Average time to complete lap by block')+theme(text = element_text(size=18)) +
   geom_rect(aes(xmin=4.5, xmax=5.5, ymin=0, ymax=150), fill="black", alpha=0.001, size=1.5) + theme(legend.position = "none")+ scale_color_manual(values = c("green", "blue", "red")) #+ geom_point()

avgLapTimeBlock

#######################################################################


hoopsPerfData <- perfMeasureData
hoopsPerfData$propHoopsCompleted[hoopsPerfData$Condition=="PathOnly"] <- NaN
pfD <- setDT(hoopsPerfData)
# subj-specific pace
pfD[ , subj_hoops := mean(propHoopsCompleted), by = .(Subject)]
# general mean across conditions
pfD[ , overall_hoops := mean(propHoopsCompleted)]
# pace controlled for subjective pace
pfD[ , hoops_within := propHoopsCompleted - subj_hoops + overall_hoops]
# sanity check
pfD[ , check := mean(hoops_within), by = .(Subject)]


meanHoops <- aggregate(perfMeasureData$propHoopsCompleted, list(perfMeasureData$Subject, perfMeasureData$Condition), FUN=mean)

colnames(meanHoops) <- c('Subject','Condition','propHoopsCompleted')

meanHoopsForComparison <- pfD[ pfD$Condition != "PathOnly", ]

colnames(meanHoopsForComparison) <- c('Subject','Condition','propHoopsCompleted')

mHoops <-lmer(propHoopsCompleted ~ Condition + (1|Subject), data=pfD, na.rm=TRUE)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
pVhoops <- anova(mHoops)[6][["Pr(>F)"]]


anova(mHoops)

F_to_eta2(4.09, 1, 113)

hoopsPerfData <- perfMeasureData
hoopsPerfData$propHoopsCompleted[hoopsPerfData$Condition=="PathOnly"] <- 0
pfD <- setDT(hoopsPerfData)
# subj-specific pace
pfD[ , subj_hoops := mean(propHoopsCompleted), by = .(Subject)]
# general mean across conditions
pfD[ , overall_hoops := mean(propHoopsCompleted)]
# pace controlled for subjective pace
pfD[ , hoops_within := propHoopsCompleted - subj_hoops + overall_hoops]
# sanity check
pfD[ , check := mean(hoops_within), by = .(Subject)]


avgHoopsCompleted <- ggplot(data=pfD, aes(y=hoops_within, x=Condition, colour=Condition)) + stat_summary(fun.y=mean, geom = "point", size=pointSize)+
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Prop. Hoops Completed') +
  xlab('Condition') + ggtitle('Prop.hoops completed')+theme(text = element_text(size=fontSize))+ 
  geom_text(aes(x=1,y=1.1, label=paste("p = ", round(pVhoops, digits=3), sep = "")), size=5, color="Black")+ 
  scale_color_manual(values = c("darkgreen", "blue", "red"))+ stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,vjust = -1.3) +theme(axis.title.x = element_blank())+ theme(legend.position = "none")
avgHoopsCompleted


meanHoops <- aggregate(perfMeasureData$propHoopsCompleted, list(perfMeasureData$Subject, perfMeasureData$Condition, perfMeasureData$block), FUN=mean)

colnames(meanHoops) <- c('Subject','Condition', 'Block','propHoopsCompleted')

meanHoopsForComparison <- meanHoops[ meanHoops$Condition == "HoopOnly" | meanHoops$Condition == "PathAndHoops", ]




avgHoopsCompletedBlock <- ggplot(data=pfD, aes(y=propHoopsCompleted, x=block, colour=Condition)) + stat_summary(fun.y=mean,
                                                                                                                     geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ylim(0,1.1)+ ylab('Prop. Hoops Completed') + xlab('Block') + ggtitle('Proportion of hoops completed by block')+theme(text = element_text(size=18)) + 
   geom_rect(aes(xmin=4.5, xmax=5.5, ymin=0, ymax=1.1), fill="black", alpha=0.001, size=1.5)  + theme(legend.position = "none")+ scale_color_manual(values = c("green", "blue", "red"))#+ geom_point()

avgHoopsCompletedBlock






#######################################





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

mCollisions <-lmer(propTimeCollisions ~ (1|Subject) + Condition , data=pfD)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
pVcollisions <- anova(mCollisions)[6][["Pr(>F)"]]

anova(mCollisions)

F_to_eta2(1.11, 2, 173)



avgCollisionPropOfTime <- ggplot(data=pfD, aes(y=col_within, x=Condition, colour=Condition)) + stat_summary(fun.y=mean,geom = "point", size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ 
  ylab('Count') + xlab('Condition')+ ggtitle('Average collisions') +
  theme(text = element_text(size=fontSize))+ 
  geom_text(aes(x=1,y=20, label=paste("P = ", round(pVcollisions, digits=3), sep = "")), size=5, color="Black")+ 
  scale_color_manual(values = c("darkgreen", "blue", "red"))+ stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,vjust = -2.5)+ theme(legend.position = "none") + ylim(0,20)+theme(axis.title.x = element_blank())
avgCollisionPropOfTime

mCollisions <- aov(propTimeCollisions~Condition, data=perfMeasureData)
summary(mCollisions)


meanCollisions <- aggregate(perfMeasureData$propTimeCollisions, list(perfMeasureData$Subject, perfMeasureData$Condition, perfMeasureData$block), FUN=mean)

colnames(meanCollisions) <- c('Subject','Condition', 'Block','propTimeCollisions')




avgCollisionPropOfTimeBlock <- ggplot(data=pfD, aes(y=propTimeCollisions, x=block, colour=Condition)) + stat_summary(fun.y=mean,
                                                                                                                               geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Count') + xlab('Block')+ ggtitle('Number of collisions by block') +theme(text = element_text(size=18)) +
   geom_rect(aes(xmin=4.5, xmax=5.5, ymin=-0.05, ymax=40), alpha=0.001, size=1.5) + theme(legend.position = "none")+ scale_color_manual(values = c("green", "blue", "red"))#+ geom_point()

avgCollisionPropOfTimeBlock






grid.arrange(avgSpeed,
             avgLapTime,
             avgHoopsCompleted, nrow=3)










avgLapTime <- ggplot(data=perfMeasureData, aes(y=timeToCompleteLap, x=Subject, colour=Condition)) + stat_summary(fun.y=mean,
                                                                                                                   geom = "point", size=pointSize)+ stat_summary(fun.data="mean_cl_normal")+ ggtitle('Average Time to complete lap') #+ geom_point()
avgLapTime


avgLapTime <- ggplot(data=perfMeasureData, aes(y=timeToCompleteLap, x=Subject, colour=Condition)) + geom_point() + ggtitle('Average Time to complete lap')#+ geom_point()
avgLapTime


