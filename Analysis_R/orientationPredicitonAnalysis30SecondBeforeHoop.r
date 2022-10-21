library(ggplot2)

library(effectsize)
library('lme4')
library(lmerTest)
library(nlme)
library(gridExtra)
orientationData <- read.csv('droneOrientationDataset30FramesBeforePassingThroughHoop.txt', sep=',')
orientationData <- orientationData[orientationData$numberCollisions<5,]
R <- 'R'
L <- 'L'
S <- 'S'

hoopDirection <- c(R,L,S,L,S,R,R,R,R,R,L,L,L,S,S,R,R,L,R,R,R,R,R,L,L,L,S,S,L,L,R,R,R,R,S,L,L,R,R,R,R,S)

## Include time to complete lap as a measure of skill

noPathOnly <- orientationData[orientationData$Condition=="HoopOnly" | orientationData$Condition=="PathAndHoops",]

noCollisions <- noPathOnly[noPathOnly$numberCollisions<10,]


noNaNData <- na.omit(noPathOnly)


avgSpeed <- ggplot(data=orientationData, aes(y=rHHp_GHp, x=absVisualAngleBetweenHoops, colour=Condition)) + geom_point() # stat_summary(fun.y=mean, geom = "point")#+ geom_point()
avgSpeed

avgSpeed <- ggplot(data=orientationData, aes(y=abs(lagGT), x=Condition, colour=Condition)) + stat_summary(fun.y=mean, geom = "point")#+ geom_point()
avgSpeed

avgSpeed <- ggplot(data=orientationData, aes(y=rCT, x=Condition, colour=Condition)) + stat_summary(fun.y=mean, geom = "point")#+ geom_point()
avgSpeed

avgSpeed <- ggplot(data=orientationData, aes(y=lagCT, x=Condition, colour=Condition)) + geom_point()#stat_summary(fun.y=mean, geom = "point")#+ geom_point()
avgSpeed



approach<- ggplot(data=noNaNData, aes(y=ApproachAngleY, x=VisualAngleBetweenHoops, colour=Condition)) + geom_point() + geom_smooth(method='lm')#+ geom_point()
approach


noNaNData$relativeHoopOrientY <- noNaNData$currHoopOrientY-noNaNData$nextHoopOrientY
noNaNData$droneOrientRelativeToHoop <- noNaNData$currHoopOrientY - (noNaNData$droneOrientYatHoop*pi/180)
noNaNData$droneOrientRelativeToNextHoop <- noNaNData$nextHoopOrientY - (noNaNData$droneOrientYatHoop*pi/180)




m1 <- lmer(lagGH ~ VisualAngleBetweenHoops*relativeHoopOrientY + (1|Subject:Condition), data=noNaNData)
summary(m1)
anova(m1)

m2 <- lmer(rGH ~ VisualAngleBetweenHoops*relativeHoopOrientY + (1|Subject:Condition), data=noNaNData)
summary(m2)
anova(m2)


ggplot(data=noNaNData, aes(x=nextHoopOrientY, y=lagGT, colour=distanceToNextHoop)) + geom_point()



orientationPredictionDF <- na.omit(data.frame(orientationData$Subject, orientationData$Condition, orientationData$block, orientationData$lap, orientationData$droneOrientYatHoop, orientationData$VisualAngleBetweenHoops, orientationData$currHoopOrientY, orientationData$nextHoopOrientY))
orientationPredictionDF$relativeHoopOrientY <- orientationPredictionDF$orientationData.currHoopOrientY  - orientationPredictionDF$orientationData.nextHoopOrientY


vAngVdrone <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=droneOrientYatHoop))+ geom_point() + ggtitle('Visual angle between hoops vs drone orient at hoop') + geom_smooth(method='lm')#+ geom_point()
vAngVdrone

rHoopVdrone <- ggplot(data=noNaNData, aes(x=relativeHoopOrientY, y=droneOrientYatHoop))+ geom_point() + ggtitle('Relative orientation of hoops vs drone orient at hoop') + geom_smooth(method='lm')#+ geom_point()
rHoopVdrone

grid.arrange(vAngVdrone, rHoopVdrone, nrow=1)

droneOrientM1 <- lmer(droneOrientYatHoop ~ (1|Subject/Condition) + relativeHoopOrientY * VisualAngleBetweenHoops, data=noNaNData)

#droneOrientM1 <- lm(droneOrientYatHoop ~ relativeHoopOrientY * VisualAngleBetweenHoops, data=noNaNData)

anova(droneOrientM1)

droneOrientM2 <- lmer(droneOrientYatHoop ~ (1|Subject/Condition) +VisualAngleBetweenHoops, data=noNaNData)

anova(droneOrientM2)

droneOrientM3 <- lmer(droneOrientYatHoop ~ (1|Subject) + relativeHoopOrientY, data=noNaNData)

anova(droneOrientM3)

anova(droneOrientM1, droneOrientM2, droneOrientM3)


F_to_eta2(40.75, 1, 4145)
F_to_eta2(67.89, 1, 4145)


approachPredictionDF <- na.omit(data.frame(orientationData$Subject, orientationData$Condition, orientationData$block, orientationData$lap, orientationData$ApproachAngleY, orientationData$VisualAngleBetweenHoops, orientationData$currHoopOrientY, orientationData$nextHoopOrientY))
approachPredictionDF$relativeHoopOrientY <- approachPredictionDF$orientationData.currHoopOrientY-approachPredictionDF$orientationData.nextHoopOrientY



vAngVapproach <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=ApproachAngleY))+ geom_point() + ggtitle('Visual angle between hoops vs drone approach angle at hoop') + geom_smooth(method='lm') + ylab('Approach Angle (deg.)') + xlab('Visual Angle Between Hoops (deg.)')#+ geom_point()
vAngVapproach

rHoopVapproach <- ggplot(data=noNaNData, aes(x=relativeHoopOrientY, y=ApproachAngleY))+ geom_point() + ggtitle('Relative orientation of hoops vs drone approach angle at hoop') + geom_smooth(method='lm')#+ geom_point()
rHoopVapproach

grid.arrange(vAngVapproach, rHoopVapproach, nrow=1)

droneApproachM1 <- lmer(ApproachAngleY ~ (1|Subject:Condition) + relativeHoopOrientY * VisualAngleBetweenHoops, data=noNaNData)

droneApproachM1 <- lm(ApproachAngleY ~ relativeHoopOrientY * VisualAngleBetweenHoops, data=noNaNData)

anova(droneApproachM1)

droneApproachM2 <- lmer(ApproachAngleY ~ (1|Subject:block:Condition)+  VisualAngleBetweenHoops, data=noNaNData)

anova(droneApproachM2)

droneApproachM3 <- lmer(ApproachAngleY ~ (1|Subject:block:Condition) + relativeHoopOrientY , data=noNaNData)

anova(droneApproachM3)
anova(droneApproachM1, droneApproachM2, droneApproachM3)

F_to_eta2(3.54, 1, 4145)
F_to_eta2(872.83, 1, 4145)
F_to_eta2(6.78, 1, 4145)

ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=relativeHoopOrientY))+ geom_point() + ggtitle('Visual angle between hoops vs drone orient at hoop') + geom_smooth(method='lm')#








grid.arrange(rHoopVdrone, vAngVdrone, 
             rHoopVapproach, vAngVapproach, nrow=2)












droneApproachM1 <- lmer(gazeThrustAtHoop ~ (1|Subject:Condition) + VisualAngleBetweenHoops, data=noNaNData)

droneApproachM1 <- lm(ApproachAngleY ~ relativeHoopOrientY * VisualAngleBetweenHoops, data=noNaNData)

anova(droneApproachM1)

droneApproachM2 <- lmer(pathCurvature ~ (1|Subject:Condition) +  VisualAngleBetweenHoops, data=noNaNData)

anova(droneApproachM2)

droneApproachM3 <- lmer(pathCurvature ~ (1|Subject:Condition) + relativeHoopOrientY , data=noNaNData)

anova(droneApproachM3)