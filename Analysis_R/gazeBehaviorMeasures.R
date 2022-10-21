library(ggplot2)

library('lme4')
library(lmerTest)

library(gridExtra)
orientationData <- read.csv('droneOrientationDataset10Frames.txt', sep=',')

orientationData <- orientationData[orientationData$Condition != "PathOnly",]

orientationData$hoopNum[orientationData$hoopNum>42] <- orientationData$hoopNum[orientationData$hoopNum>42]-42
##### Make it so that the NaNs are only taken out of the relevant rows to preserve data. 
#noNaNData <- na.omit(orientationData)
gazeTimeToNextHoop<- ggplot(orientationData, aes(x=hoopNum, y=timeAfterPreviousHoopFirstGazeNextHoop/60, colour=hoopNum))+  stat_summary(fun.y=mean,
                                                                                                                                            geom = "point", na.rm=TRUE, size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Time (s)') + xlab('Hoop')+ ggtitle('First eye movement to hoop N+1 relative to N') + 
  theme(text = element_text(size=18))+ #scale_color_manual(values = c("darkgreen", "blue"))+
  #stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,vjust = -1.9)+ 
  theme(legend.position = "none") +geom_hline(aes(yintercept=0), linetype = "dashed", size=1)
gazeTimeToNextHoop
#################################################################
#distanceToHoopCondition <- ggplot(data=noNaNData, aes(y=distanceToHoopFirstGaze/5, x=Condition)) + geom_boxplot()+ stat_summary(fun.data="mean_cl_normal") + ylab('Distance') + xlab('Condition') + ggtitle('Distance To Hoop First Eye movemnt (Condition)')#+ geom_point()

#distanceToHoopSubject <- ggplot(data=noNaNData, aes(y=distanceToHoopFirstGaze/5, x=Subject)) + geom_boxplot()+ stat_summary(fun.data="mean_cl_normal") + ylab('Distance') + xlab('Subject')+ ggtitle('Distance To Hoop First Eye movemnt (Subject)')


pointSize <- 3






meanDistanceToHoop <- aggregate(orientationData$distanceToHoopFirstGaze, list(orientationData$Subject, orientationData$Condition), FUN=mean, na.rm=TRUE, na.action=NULL)


colnames(meanDistanceToHoop) <- c('Subject','Condition','distanceToHoopFirstGaze')

meanDistanceToHoop$distanceToHoopFirstGaze[meanDistanceToHoop$Condition == 'PathOnly'] = NaN

mDistance<-lmer(distanceToHoopFirstGaze ~ Condition + (1|Subject), data=meanDistanceToHoop)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
pVdistance <- anova(mDistance)[6][["Pr(>F)"]]

anova(mDistance)

F_to_eta2(0.09, 1, 5)

mean(orientationData$distanceToHoopFirstGaze)

gazeDistance<- ggplot(meanDistanceToHoop, aes(x=Condition, y=distanceToHoopFirstGaze/5, colour=Condition))+  stat_summary(fun.y=mean,
                                                                                        geom = "point", na.rm=TRUE, size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Distance (m)') + xlab('Condition')+ ggtitle('Distance to hoop at first eye movement') + 
  ylim(-1,50)+theme(text = element_text(size=18))+ geom_text(aes(x=0.6,y=50,  label=paste("p = ", round(pVdistance, digits=3), sep = "")), size=5, color="Black")+ scale_color_manual(values = c("darkgreen", "blue"))+
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,
               vjust = -1.9)+ theme(legend.position = "none")
gazeDistance



meanDistanceToHoop <- aggregate(orientationData$distanceToHoopFirstGaze, list(orientationData$Subject, orientationData$Condition, orientationData$block), FUN=mean, na.rm=TRUE, na.action=NULL)


colnames(meanDistanceToHoop) <- c('Subject','Condition', 'Block','distanceToHoopFirstGaze')

meanDistanceToHoop$distanceToHoopFirstGaze[meanDistanceToHoop$Condition == 'PathOnly'] = NaN



gazeDistanceBlock <- ggplot(meanDistanceToHoop, aes(x=Block, y=distanceToHoopFirstGaze/5, colour=Condition)) +  stat_summary(fun.y=mean,
                                                                                          geom = "point", na.rm=TRUE, size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Distance (m)') + xlab('Block')+ ggtitle('Distance to hoop at first eye movement') + 
  ylim(-1,50)+theme(text = element_text(size=18))+ theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen", "blue"))
gazeDistanceBlock




#grid.arrange(gazeDistance, gazeDistanceBlock)






#############################################################################
#timeBeforeHoopCondition <- ggplot(data=noNaNData, aes(y=timeBeforeReachingHoopFirstGaze, x=Condition)) + geom_boxplot()+ stat_summary(fun.data="mean_cl_normal") + ylab('Time')+ xlab('Condition')+ ggtitle('Time To Hoop First Eye movemnt (Condition)')#+ geom_point()

#timeBeforeHoopSubject <- ggplot(data=noNaNData, aes(y=timeBeforeReachingHoopFirstGaze, x=Subject)) + geom_boxplot()+ stat_summary(fun.data="mean_cl_normal") + ylab('Time') + xlab('Subject')+ ggtitle('Time To Hoop First Eye movemnt (Subject)')

#LAFCondition <- ggplot(data=noNaNData, aes(x=factor(LAF))) + geom_bar(stat="count", position = "dodge") + ylim(0,1) + ylab('Count')+ xlab('Condition')+ theme(legend.position = "none")#+ geom_point()
#LAFSubject <- ggplot(data=noNaNData, aes(x=factor(LAF))) + geom_bar(stat="count", position = "dodge")+ ylim(0,1) + ylab('Count') + xlab('Subject')+ theme(legend.position = "none")#+ geom_point()



meanTimeToHoop <- aggregate(orientationData$timeBeforeReachingHoopFirstGaze, list(orientationData$Subject, orientationData$Condition), FUN=mean, na.rm=TRUE, na.action=NULL)


colnames(meanTimeToHoop) <- c('Subject','Condition','timeBeforeReachingHoopFirstGaze')

meanTimeToHoop$timeBeforeReachingHoopFirstGaze[meanTimeToHoop$Condition == 'PathOnly'] = NaN

mTime<-lmer(timeBeforeReachingHoopFirstGaze ~ Condition + (1|Subject), data=meanTimeToHoop)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
pVtime <- anova(mTime)[6][["Pr(>F)"]]

anova(mTime)

F_to_eta2(0.16, 1, 5)

gazeTime<- ggplot(meanTimeToHoop, aes(x=Condition, y=timeBeforeReachingHoopFirstGaze, colour=Condition))+  stat_summary(fun.y=mean,
                                                                                                                        geom = "point", na.rm=TRUE, size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Time (s)') + xlab('Condition')+ ggtitle('Time of first eye movement before reaching hoop') + 
  ylim(-3,1)+theme(text = element_text(size=18))+ geom_text(aes(x=0.6,y=1,  label=paste("p = ", round(pVtime, digits=3), sep = "")), size=5, color="Black")+ scale_color_manual(values = c("darkgreen", "blue"))+
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,
               vjust = -1.9)+ theme(legend.position = "none")
gazeTime



meanTimeToHoop <- aggregate(orientationData$timeBeforeReachingHoopFirstGaze, list(orientationData$Subject, orientationData$Condition, orientationData$block), FUN=mean, na.rm=TRUE, na.action=NULL)


colnames(meanTimeToHoop) <- c('Subject','Condition', 'Block','timeBeforeReachingHoopFirstGaze')

meanTimeToHoop$timeBeforeReachingHoopFirstGaze[meanTimeToHoop$Condition == 'PathOnly'] = NaN


gazeTimeBlock <- ggplot(meanTimeToHoop, aes(x=Block, y=timeBeforeReachingHoopFirstGaze, colour=Condition)) +  stat_summary(fun.y=mean,
                                                                                                                           geom = "point", na.rm=TRUE, size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Time (s)') + xlab('Block')+ ggtitle('Time of first eye movement before reaching hoop') + 
  ylim(-3,1) + theme(text = element_text(size=18))+ theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen", "blue"))
gazeTimeBlock



#############################################################################
#timeAfterPreviousCondition <- ggplot(data=noNaNData, aes(y=timeAfterPreviousHoopFirstGazeNextHoop/60, x=Condition)) + geom_boxplot()+ stat_summary(fun.data="mean_cl_normal") + ylab('Time')+ xlab('Condition')+ ggtitle('Gaze to next hoop after passing through previous (Condition)')#+ geom_point()


#timeAfterPreviousSubject <- ggplot(data=noNaNData, aes(y=timeAfterPreviousHoopFirstGazeNextHoop/60, x=Subject)) +geom_boxplot()+ stat_summary(fun.data="mean_cl_normal") + ylab('Time') + xlab('Subject')+ ggtitle('Gaze to next hoop after passing through previous (Subject)')


#avgSpeed <- ggplot(data=noNaNData, aes(y=timeAfterPreviousHoopFirstGazeNextHoop/60, x=distanceToHoopFirstGaze/5, colour=Condition)) + stat_summary(fun.y=mean, geom = "point")#+ geom_point()
#avgSpeed


orientationData <- read.csv('droneOrientationDataset10Frames.txt', sep=',')

meanTimeToNextHoop <- aggregate(orientationData$timeAfterPreviousHoopFirstGazeNextHoop, list(orientationData$Subject, orientationData$Condition), FUN=mean, na.rm=TRUE, na.action=NULL)


colnames(meanTimeToNextHoop) <- c('Subject','Condition','timeAfterPreviousHoopFirstGazeNextHoop')

meanTimeToNextHoop$timeAfterPreviousHoopFirstGazeNextHoop[meanTimeToNextHoop$Condition == 'PathOnly'] = NaN

mTimeNextHoop<-lmer(timeAfterPreviousHoopFirstGazeNextHoop ~ Condition + (1|Subject), data=meanTimeToNextHoop)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
pVtimeNextH<- anova(mTimeNextHoop)[6][["Pr(>F)"]]

anova(mTimeNextHoop)

F_to_eta2(0.002, 1, 5)


gazeTimeToNextHoop<- ggplot(meanTimeToNextHoop, aes(x=Subject, y=timeAfterPreviousHoopFirstGazeNextHoop/60, colour=Subject))+  stat_summary(fun.y=mean,
                                                                                                                        geom = "point", na.rm=TRUE, size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Time (s)') + xlab('Condition')+ ggtitle('First eye movement to hoop N+1 relative to N') + 
  theme(text = element_text(size=18))+ geom_text(aes(x=0.6,y=1,  label=paste("p = ", round(12, digits=3), sep = "")), size=5, color="Black")+ ylim(-3,1)+ #scale_color_manual(values = c("darkgreen", "blue"))+
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,
               vjust = -1.9)+ theme(legend.position = "none") +geom_hline(aes(yintercept=0), linetype = "dashed", size=1)
gazeTimeToNextHoop




meanTimeToNextHoop <- aggregate(orientationData$timeAfterPreviousHoopFirstGazeNextHoop, list(orientationData$Subject, orientationData$Condition, orientationData$block), FUN=mean, na.rm=TRUE, na.action=NULL)


colnames(meanTimeToNextHoop) <- c('Subject','Condition', 'Block','timeAfterPreviousHoopFirstGazeNextHoop')

meanTimeToNextHoop$timeAfterPreviousHoopFirstGazeNextHoop[meanTimeToNextHoop$Condition == 'PathOnly'] = NaN


gazeTimeToNextHoopBlock <- ggplot(meanTimeToNextHoop, aes(x=Block, y=timeAfterPreviousHoopFirstGazeNextHoop/60, colour=Condition)) +  stat_summary(fun.y=mean,
                                                                                                                           geom = "point", na.rm=TRUE, size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Time (s)') + xlab('Block')+ ggtitle('Timing of first eye movement to next hoop relative to nearest') + 
  theme(text = element_text(size=18))+ theme(legend.position = "none") + ylim(-3,1)+ scale_color_manual(values = c("darkgreen", "blue"))
gazeTimeToNextHoopBlock














grid.arrange(gazeDistance, 
             gazeTime, 
             gazeTimeToNextHoop,   nrow=3)
































ggplot(data=noNaNData, aes(y=distanceToHoopFirstGaze, x=timeBetweenHoops, colour=Subject)) + stat_summary(fun.y=mean, geom = "point")+ stat_summary(fun.data="mean_cl_normal")


ggplot(data=noNaNData, aes(y=timeBetweenHoops/60, x=Subject, colour=Subject)) + stat_summary(fun.y=mean, geom = "point")+ stat_summary(fun.data="mean_cl_normal")





ggplot(data=noNaNData, aes(x=timeBetweenHoops/60, y=timeAfterPreviousHoopFirstGazeNextHoop/60, colour=Subject)) + stat_summary(fun.y=mean, geom = "point")+ stat_summary(fun.data="mean_cl_normal")




ggplot(data=noNaNData, aes(x=factor(LAF), colour=Subject)) + geom_bar(stat="count", position = "dodge") + ylab('Count') + xlab('Gaze before reaching previous hoop (yes/no)') + ggtitle('First eye movement to hoop before reaching previous hoop')


ggplot(data=noNaNData, aes(x=factor(LAFthroughHoop), colour=Subject)) + geom_bar(stat="count", position = "dodge")


noNaNData$LAFnotThoughHoop <- noNaNData$LAF - noNaNData$LAFthroughHoop

ggplot(data=noNaNData, aes(x=factor(LAFnotThoughHoop), colour=Subject)) + geom_bar(stat="count", position = "dodge")


length(noNaNData$LAF)



