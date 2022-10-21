library('ggplot2')
library('lme4')
library(lmerTest)
library(gridExtra)
library(Hmisc)
library(tidyverse)
gazeTargetData <- read.csv('gazeObjectDataset.txt', sep=',')


meanPath <- aggregate(gazeTargetData$path, list(gazeTargetData$subject, gazeTargetData$condition, gazeTargetData$b), FUN=mean)

colnames(meanPath) <- c('Subject','Condition', 'Block','Path')
mPath<-lmer(Path ~ Condition + (1|Subject), data=meanPath)# aov(avgSpdAdjustedForScaling~Condition, data=meanSpeed)
pVpath <- anova(mPath)[6][["Pr(>F)"]]

gazePath <- ggplot(meanPath, aes(x=Condition, y=Path, colour=Condition))+  stat_summary(fun.y=mean,
                                                                                        geom = "point", size=pointSize)+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1)+ ylab('Proportion of gaze') + xlab('Condition')+ ggtitle('Proportion of gaze to path by condition') + 
  ylim(0,1)+theme(text = element_text(size=18))+ geom_text(aes(x=0.8,y=1, label=paste("P < ", "0.05", sep = "")), size=5, color="Black")
gazePath


gazePathBlock <- ggplot(meanPath, aes(x=Block, y=Path, colour=Condition)) +  stat_summary(fun.y=mean,
                                                                                          geom = "point", size=pointSize, position=position_dodge(0.2))+ 
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position=position_dodge(0.2))+ ylab('Proportion of gaze') + xlab('Condition')+ ggtitle('Proportion of gaze to path by condition') + 
  ylim(0,1)+theme(text = element_text(size=18))
gazePathBlock
  #geom_errorbar(stat="summary", fun.data="mean_se", fun.args = list(mult = 1.96)) + ylim(0,1)


ggplot(path_means_se, aes(x=condition, y=mean_path)) + geom_bar(stat="identity") + 
  geom_errorbar(aes(ymin=lower_limit, ymax=upper_limit)) + ylim(0,1)


ggplot(gazeTargetData, aes(x=condition, y=path)) + geom_point(stat="summary", fun.y="mean") + 
  geom_errorbar(stat="summary", fun.data="mean_se", fun.args = list(mult = 1.96)) + ylim(0,1)


pointSize = 4
gazePath<- ggplot(data=gazeTargetData, aes(y=path, x=condition, colour=condition)) + geom_boxplot()+ ylim(0,1) + ggtitle('Proportion Gaze to Path')
  
  #stat_summary(fun.y=mean, geom = "point", size=pointSize) + 
  #stat_summary(fun.data = mean_cl_normal, geom = "errorbar") + ylim(0,1) + ggtitle('Proportion Gaze to Path')#+ geom_point()



gazePath<- ggplot(data=gazeTargetData, aes(y=path, x=condition, colour=condition)) + stat_summary(fun.y=mean, geom = "point", size=pointSize) + 
  stat_summary(fun.data = mean_se, geom = "errorbar") + ylim(0,1) + ggtitle('Proportion Gaze to Path')

gazePath

pathModel <- aov(path ~ condition, data=gazeTargetData)

summary(pathModel)


pathModel2 <- lmer(path ~ condition + (1|subject), data=gazeTargetData)
anova(pathModel2)

####################################################

gazeTerrain <- ggplot(data=gazeTargetData, aes(y=terrain, x=condition, colour=condition)) + geom_boxplot() + ylim(0,1)# stat_summary(fun.y=mean,
                                                                                     

meanTerrain <- aggregate(gazeTargetData$terrain, list(gazeTargetData$subject, gazeTargetData$condition, gazeTargetData$b), FUN=mean)

colnames(meanTerrain) <- c('Subject','Condition', 'Block','terrain')
gazeTerrain <- ggplot(data=meanTerrain, aes(y=terrain, x=Condition, colour=Condition)) + geom_point(stat="summary", fun.y="mean") + stat_summary(fun.data="mean_cl_normal") + ylim(0,1)
                 
#geom = "point", size=pointSize) + stat_summary(fun.data="mean_cl_normal") + ylim(0,1) + ggtitle('Proportion Gaze to Terrain')#+ geom_point()
gazeTerrain


terrain_means_se <- gazeTargetData %>% 
  group_by(condition) %>% # Group the data by manufacturer
  summarize(mean_terrain=mean(terrain), # Create variable with mean of cty per group
            sd_terrain=sd( terrain), # Create variable with sd of cty per group
            N_terrain=n(), # Create new variable N of cty per group
            se=sd_terrain/sqrt(N_terrain), # Create variable with se of cty per group
            upper_limit=mean_terrain+(1.96*(sqrt((mean_terrain*(1-mean_terrain))/N_terrain))), # Upper limit
            lower_limit=mean_terrain-(1.96*(sqrt((mean_terrain*(1-mean_terrain))/N_terrain))) # Lower limit
  ) 

ggplot(terrain_means_se, aes(x=condition, y=mean_terrain)) + geom_bar(stat="identity") + 
  geom_errorbar(aes(ymin=lower_limit, ymax=upper_limit)) + ylim(0,1)


########################################################
gazeHoops <- ggplot(data=gazeTargetData, aes(y=hoops, x=condition, colour=condition)) + geom_boxplot() + ylim(0,1)# stat_summary(fun.y=mean,
                                                                                                      #geom = "point", size=pointSize) + stat_summary(fun.data="mean_cl_normal") + ylim(0,1) + ggtitle('Proportion Gaze to Hoop Edges')#+ geom_point()

meanHoops <- aggregate(gazeTargetData$hoops, list(gazeTargetData$subject, gazeTargetData$condition, gazeTargetData$b), FUN=mean)

colnames(meanHoops) <- c('Subject','condition', 'Block','hoops')
gazeHoops <- ggplot(data=meanHoops, aes(y=hoops, x=condition, colour=condition)) +geom_point(stat="summary", fun.y="mean") + stat_summary(fun.data="mean_cl_normal") + ylim(0,1)
gazeHoops
#pointSize = 4
#gazeTargets <- ggplot(data=gazeTargetData, aes(y=noCollisions, x=condition, colour=condition)) + stat_summary(fun.y=mean,
                                                                                                    #  geom = "point", size=pointSize) + stat_summary(fun.data="mean_cl_normal") + ylim(0,100) + ggtitle('Proportion Gaze to Path')#+ geom_point()



gazeThroughHoops <- ggplot(data=gazeTargetData, aes(y=throughpercentages, x=condition, colour=condition)) + geom_boxplot() + ylim(0,1)#+ stat_summary(fun.y=mean,
                                                                                                      #geom = "point", size=pointSize) + stat_summary(fun.data="mean_cl_normal") + ylim(0,1) + ggtitle('Proportion Gaze through Hoops')#+ geom_point()

meanthroughpercentages <- aggregate(gazeTargetData$throughpercentages, list(gazeTargetData$subject, gazeTargetData$condition, gazeTargetData$b), FUN=mean)

colnames(meanthroughpercentages) <- c('Subject','condition', 'Block','throughpercentages')

gazeThroughHoops <- ggplot(data=meanthroughpercentages, aes(y=throughpercentages, x=condition, colour=condition)) +geom_point(stat="summary", fun.y="mean") + stat_summary(fun.data="mean_cl_normal") + ylim(0,1)
gazeThroughHoops

gazeTrees <- ggplot(data=gazeTargetData, aes(y=trees, x=condition, colour=condition)) + geom_boxplot() + ylim(0,1)#+ stat_summary(fun.y=mean,
                                                                                                     #geom = "point", size=pointSize) + stat_summary(fun.data="mean_cl_normal") + ylim(0,1) + ggtitle('Proportion Gaze to Trees')#+ geom_point()

meanTrees <- aggregate(gazeTargetData$trees, list(gazeTargetData$subject, gazeTargetData$condition, gazeTargetData$b), FUN=mean)

colnames(meanTrees) <- c('Subject','condition', 'Block','trees')

gazeTrees<- ggplot(data=meanTrees, aes(y=trees, x=condition, colour=condition)) +geom_point(stat="summary", fun.y="mean") + stat_summary(fun.data="mean_cl_normal") + ylim(0,1)
gazeTrees

grid.arrange(gazeHoops,gazePath, gazeTerrain, gazeThroughHoops, gazeTrees, nrow=2)

