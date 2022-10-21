
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


gazeDistanceData <- read.csv('avgGazeDistancesData.txt', sep=',')


# set up a datatable
data <- setDT(gazeDistanceData)
# subj-specific pace
data[ , subj_distance := mean(avgDistances), by = .(Subject)]
# general mean across conditions
data[ , overall_distance := mean(avgDistances)]
# pace controlled for subjective pace
data[ , distance_within := avgDistances - subj_distance + overall_distance]
# sanity check
data[ , check := mean(distance_within), by = .(Subject)]


mGazeDistance <- lme(distance_within ~ Condition, random= ~1|Subject/Condition, data=data)
#pVgazeDistance <- anova(mGazeDistance)[6][["Pr(>F)"]]




anova(mGazeDistance)

F_to_eta2(43.0026, 2, 10)


avgGazeDistance <- ggplot(data=data, aes(y=distance_within, x=Condition, colour=Condition)) +  stat_summary(fun.y=mean,
                                                                                                  geom = "point", size=3) + stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.1, position="dodge")+
    ggtitle('Average Gaze Distance speed per lap by condition') + ylim(0,9)+
  ylab('Distance (m)') + xlab('Condition')+theme(text = element_text(size=18)) + geom_text(aes(x=0.8,y=9, label=paste("P < ", 0.001, sep = "")), size=5, color="Black")

avgGazeDistance
