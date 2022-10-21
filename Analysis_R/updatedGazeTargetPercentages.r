library('ggplot2')
library('lme4')
library(lmerTest)
library(nlme)
library(gridExtra)
library(Hmisc)
library(tidyverse)
library(effectsize)
gazeTargetData <- read.csv('gazeObjectDatasetCloseTrees_final.txt', sep=',')
pointSize=3



gazeTargetDataPath <- gazeTargetData[ gazeTargetData$condition != "HoopOnly", ]
gazeTargetDataPath$condition[gazeTargetDataPath$condition=="HoopOnly"] = NaN
pathAndTerrain <- ggplot(data=gazeTargetDataPath, aes(x =condition, y=percToTerrain4deg, color=condition)) +  stat_summary(fun.y=mean,
                                                                                       geom = "point", size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1) + ylab('% frames') + 
  xlab('Condition')+theme(text = element_text(size=18)) + ylim(0,1) + ggtitle('Percentage of frames with gaze on path or terrain within 4 degrees of path center')+ scale_color_manual(values = c("blue", "red"))
pathAndTerrain

gazeTargetDataPath <- gazeTargetData[ gazeTargetData$condition != "HoopOnly", ]
ggplot(data=gazeTargetDataPath, aes(x=abs(meanDistanceToPathGazeTerrain), color=condition)) + geom_density()











meanPath <- aggregate(gazeTargetData$path, list(gazeTargetData$subject, gazeTargetData$condition), FUN=mean)
colnames(meanPath) <- c('Subject','Condition','Path')
meanPathForComparison <- meanPath[ meanPath$Condition == "PathOnly" | meanPath$Condition == "PathAndHoops", ]
colnames(meanPathForComparison) <- c('Subject','Condition','Path')
mPath<-lmer(Path ~ Condition + (1|Subject), data=meanPathForComparison)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)

pVpath <- anova(mPath)[6][["Pr(>F)"]]


anova(mPath)

F_to_eta2(14.93, 1, 5)


meanPath <- aggregate(gazeTargetData$path, list(gazeTargetData$subject, gazeTargetData$condition), FUN=mean)
colnames(meanPath) <- c('Subject','Condition','Path')
meanPathForComparison <- meanPath
colnames(meanPathForComparison) <- c('Subject','Condition','Path')


gazePath <- ggplot(meanPathForComparison, aes(x=Condition, y=Path, colour=Condition))+  stat_summary(fun.y=mean,
                                                                                        geom = "point", size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Proportion of gaze') + xlab('Condition')+ ggtitle('Proportion of gaze to path by condition') + 
  ylim(-0.1,1)+theme(text = element_text(size=18))+ geom_text(aes(x=0.8,y=1, label=paste("p < ", "0.05", sep = "")), size=5, color="Black")+ scale_color_manual(values = c("darkgreen", "blue", "red")) +
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,
               vjust = -2.5)+ theme(legend.position = "none")
gazePath

meanPath <- aggregate(gazeTargetData$path, list(gazeTargetData$subject, gazeTargetData$condition, gazeTargetData$b), FUN=mean)
colnames(meanPath) <- c('Subject','Condition', 'Block','Path')
meanPathForComparison <- meanPath

colnames(meanPath) <- c('Subject','Condition', 'Block','Path')
gazePathBlock <- ggplot(meanPathForComparison, aes(x=Block, y=Path, colour=Condition)) +  stat_summary(fun.y=mean,
                                                                                          geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Proportion of gaze') + xlab('Block')+ ggtitle('Proportion of gaze to path by block') + 
  ylim(-0.1,1)+theme(text = element_text(size=18))+ theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen", "blue", "red"))
gazePathBlock
#geom_errorbar(stat="summary", fun.d



grid.arrange(gazePath, pathAndTerrain, nrow=2)
##############################################################################################################


meanhoops <- aggregate(gazeTargetData$hoops, list(gazeTargetData$subject, gazeTargetData$condition), FUN=mean)

colnames(meanhoops) <- c('Subject','Condition','Hoops')

meanHoopsForComparison <- meanhoops[ meanhoops$Condition == "HoopOnly" | meanhoops$Condition == "PathAndHoops", ]

colnames(meanHoopsForComparison) <- c('Subject','Condition','Hoops')

mHoops<-lmer(Hoops ~ Condition + (1|Subject), data=meanHoopsForComparison)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
pVhoops <- anova(mHoops)[6][["Pr(>F)"]]


anova(mHoops)

F_to_eta2(1.62, 1, 5)


meanhoops <- aggregate(gazeTargetData$hoops, list(gazeTargetData$subject, gazeTargetData$condition), FUN=mean)

colnames(meanhoops) <- c('Subject','Condition','Hoops')

meanHoopsForComparison <- meanhoops

colnames(meanHoopsForComparison) <- c('Subject','Condition','Hoops')


gazeHoops <- ggplot(meanHoopsForComparison, aes(x=Condition, y=Hoops, colour=Condition))+  stat_summary(fun.y=mean,
                                                                                        geom = "point", size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Proportion of gaze') + xlab('Condition')+ ggtitle('Proportion of gaze to hoop edges by condition') + 
  ylim(0,1)+theme(text = element_text(size=18))+ geom_text(aes(x=0.8,y=1,  label=paste("p = ", round(pVhoops, digits=3), sep = "")), size=5, color="Black")+ scale_color_manual(values = c("darkgreen", "blue", "red"))+
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,
               vjust = -0.9)+ theme(legend.position = "none")
gazeHoops


meanhoops <- aggregate(gazeTargetData$hoops, list(gazeTargetData$subject, gazeTargetData$condition, gazeTargetData$b), FUN=mean)

colnames(meanhoops) <- c('Subject','Condition', 'Block','Hoops')

meanHoopsForComparison <- meanhoops

gazeHoopsBlock <- ggplot(meanHoopsForComparison, aes(x=Block, y=Hoops, colour=Condition)) +  stat_summary(fun.y=mean,
                                                                                          geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Proportion of gaze') + xlab('Block')+ ggtitle('Proportion of gaze to hoop edges by block') + 
  ylim(0,1)+theme(text = element_text(size=18))+ theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen", "blue", "red"))
gazeHoopsBlock
#geom_errorbar(stat="summary", fun.d




##############################################################################################################


meanHoopCenter <- aggregate(gazeTargetData$throughpercentages, list(gazeTargetData$subject, gazeTargetData$condition), FUN=mean)



colnames(meanHoopCenter) <- c('Subject','Condition','throughpercentages')

meanHoopsForComparison <- meanHoopCenter[ meanHoopCenter$Condition == "HoopOnly" | meanHoopCenter$Condition == "PathAndHoops", ]
colnames(meanHoopsForComparison) <- c('Subject','Condition','throughpercentages')
mCenter<-lmer(throughpercentages ~ Condition + (1|Subject), data=meanHoopsForComparison)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
pVCenter <- anova(mCenter)[6][["Pr(>F)"]]

anova(mCenter)

F_to_eta2(0.1332, 1, 5)


meanHoopCenter <- aggregate(gazeTargetData$throughpercentages, list(gazeTargetData$subject, gazeTargetData$condition), FUN=mean)



colnames(meanHoopCenter) <- c('Subject','Condition','throughpercentages')

meanHoopsForComparison <- meanHoopCenter
colnames(meanHoopsForComparison) <- c('Subject','Condition','throughpercentages')

meanHoopsForComparison$throughpercentages[ meanHoopsForComparison$Condition == "PathOnly" ] <- 0
gazeCenter <- ggplot(meanHoopsForComparison, aes(x=Condition, y=throughpercentages, colour=Condition))+  stat_summary(fun.y=mean,
                                                                                        geom = "point", size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Proportion of gaze') + xlab('Condition')+ ggtitle('Proportion of gaze through hoop center by condition') + 
  ylim(0,1)+theme(text = element_text(size=18))+ geom_text(aes(x=0.8,y=1, label=paste("p = ", round(pVCenter, digits=3), sep = "")), size=5, color="Black")+ scale_color_manual(values = c("darkgreen", "blue", "red"))+
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,
               vjust = -1.9)+ theme(legend.position = "none")
gazeCenter

meanHoopCenter <- aggregate(gazeTargetData$throughpercentages, list(gazeTargetData$subject, gazeTargetData$condition, gazeTargetData$b), FUN=mean)
colnames(meanHoopCenter) <- c('Subject','Condition', 'Block','throughpercentages')
meanHoopCenter$throughpercentages[meanHoopCenter$Condition == 'PathOnly'] = 0
meanHoopsForComparison <- meanHoopCenter
colnames(meanHoopsForComparison) <- c('Subject','Condition', 'Block','throughpercentages')

gazeCenterBlock <- ggplot(meanHoopsForComparison, aes(x=Block, y=throughpercentages, colour=Condition)) +  stat_summary(fun.y=mean,
                                                                                          geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Proportion of gaze') + xlab('Block')+ ggtitle('Proportion of gaze through hoop center by block') + 
  ylim(0,1)+theme(text = element_text(size=18))+ theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen", "blue", "red"))
gazeCenterBlock
#geom_errorbar(stat="summary", fun.d




##############################################################################################################


meanTrees <- aggregate(gazeTargetData$trees, list(gazeTargetData$subject, gazeTargetData$condition), FUN=mean)

colnames(meanTrees) <- c('Subject','Condition','Trees')
mTrees<-lmer(Trees ~ Condition + (1|Subject), data=meanTrees)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
mTrees2 <- lme(Trees ~ Condition, random= ~1|Subject, data=meanTrees)
pVtrees <- anova(mTrees)[6][["Pr(>F)"]]

anova(mTrees2)

F_to_eta2(2.15, 2, 10)


gazeTrees <- ggplot(meanTrees, aes(x=Condition, y=Trees, colour=Condition))+  stat_summary(fun.y=mean,
                                                                                        geom = "point", size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Proportion of gaze') + xlab('Condition')+ ggtitle('Proportion of gaze to trees by condition') + 
  ylim(-0.2,1)+theme(text = element_text(size=18))+ geom_text(aes(x=0.8,y=1,  label=paste("p = ", round(pVtrees, digits=3), sep = "")), size=5, color="Black")+ scale_color_manual(values = c("darkgreen", "blue", "red"))+
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,
               vjust = -1.5)+ theme(legend.position = "none")
gazeTrees


meanTrees <- aggregate(gazeTargetData$trees, list(gazeTargetData$subject, gazeTargetData$condition, gazeTargetData$b), FUN=mean)

colnames(meanTrees) <- c('Subject','Condition', 'Block','Trees')

gazeTreesBlock <- ggplot(meanTrees, aes(x=Block, y=Trees, colour=Condition)) +  stat_summary(fun.y=mean,
                                                                                          geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Proportion of gaze') + xlab('Block')+ ggtitle('Proportion of gaze to nearby trees by block') + 
  ylim(-0.2,1)+theme(text = element_text(size=18))+ theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen", "blue", "red"))
gazeTreesBlock
#geom_errorbar(stat="summary", fun.d




##############################################################################################################


meanTerrain <- aggregate(gazeTargetData$terrain, list(gazeTargetData$subject, gazeTargetData$condition), FUN=mean)

colnames(meanTerrain) <- c('Subject','Condition','Terrain')
mTerrain <- lmer(Terrain ~ Condition + (1|Subject), data=meanTerrain)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
mTerrain2 <- lme(Terrain ~ Condition, random= ~1|Subject, data=meanTerrain)
pVterrain <- anova(mTerrain)[6][["Pr(>F)"]]

anova(mTerrain2)

F_to_eta2(0.161, 2, 10)


gazeTerrain <- ggplot(meanTerrain, aes(x=Condition, y=Terrain, colour=Condition))+  stat_summary(fun.y=mean,
                                                                                        geom = "point", size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Proportion of gaze') + xlab('Condition')+ ggtitle('Proportion of gaze to terrain by condition') + 
  ylim(0,1)+theme(text = element_text(size=18))+ geom_text(aes(x=0.8,y=1,  label=paste("p = 0.853", sep = "")), size=5, color="Black")+ scale_color_manual(values = c("darkgreen", "blue", "red"))+
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,
               vjust = -1.9)+ theme(legend.position = "none")
gazeTerrain

meanTerrain <- aggregate(gazeTargetData$terrain, list(gazeTargetData$subject, gazeTargetData$condition, gazeTargetData$b), FUN=mean)

colnames(meanTerrain) <- c('Subject','Condition', 'Block','Terrain')
gazeTerrainBlock <- ggplot(meanTerrain, aes(x=Block, y=Terrain, colour=Condition)) +  stat_summary(fun.y=mean,
                                                                                          geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Proportion of gaze') + xlab('Block')+ ggtitle('Proportion of gaze to terrain by block') + 
  ylim(0,1)+theme(text = element_text(size=18))+ theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen", "blue", "red"))
gazeTerrainBlock
#geom_errorbar(stat="summary", fun.d




##############################################################################################################



grid.arrange(gazePath,
             gazeTerrain,
             gazeTrees,
             gazeHoops,
             gazeCenter, nrow=5)

