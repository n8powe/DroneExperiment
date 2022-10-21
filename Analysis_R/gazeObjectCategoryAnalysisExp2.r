library('ggplot2')
library('lme4')
library(lmerTest)
library(nlme)
library(gridExtra)
library(Hmisc)
library(tidyverse)
library(effectsize)
library(data.table)
library(dplyr)
gazeTargetData <- read.csv('gazeObjectDatasetExperiment2.txt', sep=',')
pointSize=3



gazeTargetData$condition<- recode(gazeTargetData$condition, PathOnly = 'Sparse Trees', 
                                  DenseTrees = 'Dense Trees')

ggplot(data=gazeTargetData, aes(x=percToTerrain4deg, color=condition)) + geom_density(size=2) + ylab('P') + 
  xlab('Visual Angle between gaze point on terrain and nearest point on center of path')+theme(text = element_text(size=18)) + ggtitle('Density of frames with gaze on path or terrain within 4 degrees of path center')




ggplot(data=gazeTargetData, aes(x=condition, y=percToTerrain4deg, color=condition)) + stat_summary(fun.y=mean,geom = "point", size=4) + 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.15, position="dodge") + xlab('Condition') + ylim(0,1) +
  ylab('Proportion')+theme(text = element_text(size=18)) + ggtitle('Average proportion of time spent with gaze on path or terrain within 4 deg.')








pfD <- setDT(gazeTargetData)
# subj-specific pace
pfD[ , subj_col := mean(path), by = .(subject)]
# general mean across conditions
pfD[ , overall_col := mean(path)]
# pace controlled for subjective pace
pfD[ , col_within := path - subj_col + overall_col]
# sanity check
pfD[ , check := mean(col_within), by = .(subject)]




meanPath <- pfD#aggregate(gazeTargetData$path, list(gazeTargetData$subject, gazeTargetData$condition), FUN=mean)
#colnames(meanPath) <- c('Subject','Condition','Path')
#meanPathForComparison <- meanPath[ meanPath$Condition == "PathOnly" | meanPath$Condition == "PathAndHoops", ]
#colnames(meanPath) <- c('Subject','Condition','Path')
mPath<-lmer(path ~ condition + (1|subject), data=meanPath)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
mPath2 <- lme(path ~ condition, random= ~1|subject/condition, data=meanPath)
pVpath <- anova(mPath)[6][["Pr(>F)"]]


anova(mPath2)

F_to_eta2(1.52, 1, 2)

levels(pfD$condition)[levels(pfD$condition)=="PathOnly"] <- "Sparse Trees"
gazePath <- ggplot(meanPath, aes(x=condition, y=path, colour=condition))+  stat_summary(fun.y=mean,
                                                                                                     geom = "point", size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Proportion of gaze') + xlab('Condition')+ ggtitle('Proportion of gaze to path by condition') + 
  ylim(-0.1,1)+theme(text = element_text(size=18))+ geom_text(aes(x=0.8,y=1, label=paste("p = ", "0.323", sep = "")), size=5, color="Black")+ scale_color_manual(values = c("blue", "red"))+
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,
               vjust = -1.9)+ theme(legend.position = "none")
gazePath

#meanPath <- aggregate(gazeTargetData$path, list(gazeTargetData$subject, gazeTargetData$condition, gazeTargetData$b), FUN=mean)
#colnames(meanPath) <- c('Subject','Condition', 'Block','Path')
#meanPathForComparison <- meanPath[ meanPath$Condition == "PathOnly" | meanPath$Condition == "PathAndHoops", ]

#colnames(meanPath) <- c('Subject','Condition', 'Block','Path')
gazePathBlock <- ggplot(meanPath, aes(x=b, y=col_within, colour=condition)) +  stat_summary(fun.y=mean,
                                                                                                       geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Proportion of gaze') + xlab('Block')+ ggtitle('Proportion of gaze to path by block') + 
  ylim(-0.1,1)+theme(text = element_text(size=18))+ theme(legend.position = "none")+ scale_color_manual(values = c("blue", "red"))
gazePathBlock
#geom_errorbar(stat="summary", fun.d




#############################################################################################################


##############################################################################################################

gazeTargetData <- read.csv('gazeObjectDatasetExperiment2.txt', sep=',')
gazeTargetData$condition<- recode(gazeTargetData$condition, PathOnly = 'Sparse Trees', 
                                  DenseTrees = 'Dense Trees')
pfD2 <- setDT(gazeTargetData)
# subj-specific pace
pfD2[ , subj_col := mean(trees), by = .(subject)]
# general mean across conditions
pfD2[ , overall_col := mean(trees)]
# pace controlled for subjective pace
pfD2[ , col_within := trees - subj_col + overall_col]
# sanity check
pfD2[ , check := mean(col_within), by = .(subject)]
levels(pfD2$condition)[levels(pfD2$condition)=="PathOnly"] <- "Sparse Trees"
meanTrees <- pfD2#aggregate(gazeTargetData$trees, list(gazeTargetData$subject, gazeTargetData$condition), FUN=mean)

#colnames(meanTrees) <- c('Subject','Condition','Trees')
mTrees<-lmer(trees ~ condition + (1|subject), data=meanTrees)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
#mTrees2 <- lme(trees ~ condition, random= ~1|subject/condition, data=meanTrees)
mTrees2 <- lme(trees ~ condition, random= ~1|subject/condition, data=meanTrees)
pVtrees <- anova(mTrees2)[6][["Pr(>F)"]]

anova(mTrees2)

F_to_eta2(15.75, 1, 2)


gazeTrees <- ggplot(meanTrees, aes(x=condition, y=trees, colour=condition))+  stat_summary(fun.y=mean,
                                                                                           geom = "point", size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Proportion of gaze') + xlab('Condition')+ ggtitle('Proportion of gaze to trees by condition') + 
  ylim(-0.2,1)+theme(text = element_text(size=18))+ geom_text(aes(x=0.8,y=1,  label=paste("p = ", "0.058", sep = "")), size=5, color="Black")+ scale_color_manual(values = c("blue", "red"))+
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,
               vjust = -1.9)+ theme(legend.position = "none")
gazeTrees


#meanTrees <- aggregate(gazeTargetData$trees, list(gazeTargetData$subject, gazeTargetData$condition, gazeTargetData$b), FUN=mean)

#colnames(meanTrees) <- c('Subject','Condition', 'Block','Trees')

gazeTreesBlock <- ggplot(meanTrees, aes(x=b, y=col_within, colour=condition)) +  stat_summary(fun.y=mean,
                                                                                             geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Proportion of gaze') + xlab('Block')+ ggtitle('Proportion of gaze to nearby trees by block') + 
  ylim(-0.2,1)+theme(text = element_text(size=18))+ theme(legend.position = "none")+ scale_color_manual(values = c("blue", "red"))
gazeTreesBlock
#geom_errorbar(stat="summary", fun.d




##############################################################################################################
gazeTargetData <- read.csv('gazeObjectDatasetExperiment2.txt', sep=',')
gazeTargetData$condition<- recode(gazeTargetData$condition, PathOnly = 'Sparse Trees', 
                                  DenseTrees = 'Dense Trees')
pfD3 <- setDT(gazeTargetData)
# subj-specific pace
pfD3[ , subj_col := mean(terrain), by = .(subject)]
# general mean across conditions
pfD3[ , overall_col := mean(terrain)]
# pace controlled for subjective pace
pfD3[ , col_within := terrain - subj_col + overall_col]
# sanity check
pfD3[ , check := mean(col_within), by = .(subject)]


levels(pfD3$condition)[levels(pfD3$condition)=="PathOnly"] <- "Sparse Trees"
meanTerrain <- pfD3 #aggregate(gazeTargetData$terrain, list(gazeTargetData$subject, gazeTargetData$condition), FUN=mean)

#colnames(meanTerrain) <- c('Subject','Condition','Terrain')
mTerrain <- lmer(terrain ~ condition + (1|subject/condition), data=meanTerrain)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
#mTerrain2 <- lme(terrain ~ condition, random= ~1|subject/condition, data=meanTerrain)
mTerrain2 <- lme(terrain ~ condition, random= ~1|subject/condition, data=meanTerrain)
pVterrain <- anova(mTerrain2)[6][["Pr(>F)"]]

anova(mTerrain2)

F_to_eta2(8.875, 1, 2)


gazeTerrain <- ggplot(meanTerrain, aes(x=condition, y=terrain, colour=condition))+  stat_summary(fun.y=mean,
                                                                                                 geom = "point", size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Proportion of gaze') + xlab('Condition')+ ggtitle('Proportion of gaze to terrain by condition') + 
  ylim(0,1)+theme(text = element_text(size=18))+ geom_text(aes(x=0.8,y=1,  label=paste("p = ", "0.097", sep = "")), size=5, color="Black")+ scale_color_manual(values = c("blue", "red"))+
  stat_summary(aes(label=round(..y..,2)), fun.y=mean, geom="text", size=6,
               vjust = -1.9)+ theme(legend.position = "none")
gazeTerrain

#meanTerrain <- aggregate(gazeTargetData$terrain, list(gazeTargetData$subject, gazeTargetData$condition, gazeTargetData$b), FUN=mean)

#colnames(meanTerrain) <- c('Subject','Condition', 'Block','Terrain')
gazeTerrainBlock <- ggplot(meanTerrain, aes(x=b, y=col_within, colour=condition)) +  stat_summary(fun.y=mean,
                                                                                                   geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Proportion of gaze') + xlab('Block')+ ggtitle('Proportion of gaze to terrain by block') + 
  ylim(0,1)+theme(text = element_text(size=18))+ theme(legend.position = "none")+ scale_color_manual(values = c("blue", "red"))
gazeTerrainBlock
#geom_errorbar(stat="summary", fun.d




##############################################################################################################



grid.arrange(gazePath,
             gazeTerrain,
             gazeTrees, nrow=3)
