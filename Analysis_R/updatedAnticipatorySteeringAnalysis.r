library(ggplot2)

library(effectsize)
library('lme4')
library(lmerTest)
library(nlme)
library(gridExtra)
library(r2glmm)
orientationData <- read.csv('droneOrientationDataset10Frames.txt', sep=',')
orientationData <- orientationData[orientationData$numberCollisions<1,]
orientationData <- orientationData[orientationData$block<5,]
orientationData <- orientationData[orientationData$somethingWeirdWithApproach==0,]

orientationData$block <- factor(orientationData$block)
orientationData$Condition <- factor(orientationData$Condition)
orientationData$Subject <- factor(orientationData$Subject)
#noPathOnly <- orientationData[orientationData$Condition!="PathAndHoops",]#[orientationData$LAF==0,]
#orientationData <- orientationData[abs(orientationData$ApproachAngleY0)<90,]
#noCollisions <- noPathOnly[noPathOnly$numberCollisions<10,]
#noPathOnly <- noPathOnly[noPathOnly$block <5,]
levels(orientationData$Condition)
noNaNData <- orientationData#na.omit(noPathOnly)


noNaNData$relativeHoopOrientY <- (noNaNData$currHoopOrientY-noNaNData$nextHoopOrientY)*180/pi
noNaNData$droneOrientRelativeToHoop <- (noNaNData$currHoopOrientY*180/pi) - (noNaNData$droneOrientYatHoop)
noNaNData$droneOrientRelativeToNextHoop <- noNaNData$nextHoopOrientY - (noNaNData$droneOrientYatHoop*pi/180)

#noNaNData$ApproachToNatNm1
#noNaNData$AngularOffsetToNatNm1
#noNaNData$thrustNextHoop
#noNaNData$thrustRelativeToHoopN
#noNaNData$ApproachAngleY0


################################################################### At Hoop
headingModel1 <- lmer(data = noNaNData, ApproachAngleY0 ~ (1|Subject) + (1|block)  + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle + VisualAngleBetweenHoops + relativeHoopOrientY)
anova(headingModel1)

headingModel2 <- lmer(data = noNaNData, ApproachAngleY0 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle + relativeHoopOrientY)
anova(headingModel2)

headingModel3 <- lmer(data = noNaNData, ApproachAngleY0 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle + VisualAngleBetweenHoops)
anova(headingModel3)

headingModel4 <- lmer(data = noNaNData, ApproachAngleY0 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops + relativeHoopOrientY + VisualAngleBetweenHoops * relativeHoopOrientY )
anova(headingModel4)
################################################################### 5 Frames before hoop
headingModel1 <- lmer(data = noNaNData, ApproachAngleY5 ~ (1|Subject)+ (1|block)  + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops + relativeHoopOrientY)
anova(headingModel1)

headingModel2 <- lmer(data = noNaNData, ApproachAngleY5 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle + relativeHoopOrientY)
anova(headingModel2)

headingModel3 <- lmer(data = noNaNData, ApproachAngleY5 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops)
anova(headingModel3)

headingModel4 <- lmer(data = noNaNData, ApproachAngleY5 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops + relativeHoopOrientY + VisualAngleBetweenHoops * relativeHoopOrientY )
anova(headingModel4)
################################################################### 15 Frames before hoop
headingModel1 <- lmer(data = noNaNData, ApproachAngleY15 ~ (1|Subject)+ (1|block)  + ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle + VisualAngleBetweenHoops + relativeHoopOrientY)
anova(headingModel1)

headingModel2 <- lmer(data = noNaNData, ApproachAngleY15 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle + relativeHoopOrientY)
anova(headingModel2)

headingModel3 <- lmer(data = noNaNData, ApproachAngleY15 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle + VisualAngleBetweenHoops)
anova(headingModel3)

headingModel4 <- lmer(data = noNaNData, ApproachAngleY15 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle+ VisualAngleBetweenHoops + relativeHoopOrientY + VisualAngleBetweenHoops * relativeHoopOrientY )
anova(headingModel4)
################################################################### 30 frames before hoop
headingModel1 <- lmer(data = noNaNData, ApproachAngleY30 ~ (1|Subject)+ (1|block)  + ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle + VisualAngleBetweenHoops + relativeHoopOrientY)
anova(headingModel1)

headingModel2 <- lmer(data = noNaNData, ApproachAngleY30 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle + relativeHoopOrientY)
anova(headingModel2)

headingModel3 <- lmer(data = noNaNData, ApproachAngleY30 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops)
anova(headingModel3)

headingModel4 <- lmer(data = noNaNData, ApproachAngleY30 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops + relativeHoopOrientY + VisualAngleBetweenHoops * relativeHoopOrientY )
anova(headingModel4)
################################################################### 60 frames before hoop
headingModel1 <- lmer(data = noNaNData, ApproachAngleY60 ~ (1|Subject)+ (1|block)  + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops + relativeHoopOrientY)
anova(headingModel1)

headingModel2 <- lmer(data = noNaNData, ApproachAngleY60 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle + relativeHoopOrientY)
anova(headingModel2)

headingModel3 <- lmer(data = noNaNData, ApproachAngleY60 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops)
anova(headingModel3)

headingModel4 <- lmer(data = noNaNData, ApproachAngleY60 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + VisualAngleBetweenHoops + relativeHoopOrientY + VisualAngleBetweenHoops * relativeHoopOrientY )
anova(headingModel4)
#####################################################################

####################################################################### 0 frames before hoop
thrustModel1 <- lmer(data = noNaNData, thrustRelativeToHoopN ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops + relativeHoopOrientY)
anova(thrustModel1)

thrustModel2 <- lmer(data = noNaNData, thrustRelativeToHoopN ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle + relativeHoopOrientY)
anova(thrustModel2)

thrustModel3 <- lmer(data = noNaNData, thrustRelativeToHoopN ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle + VisualAngleBetweenHoops)
anova(thrustModel3)

thrustModel4 <- lmer(data = noNaNData, thrustRelativeToHoopN ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle+ VisualAngleBetweenHoops + relativeHoopOrientY + VisualAngleBetweenHoops * relativeHoopOrientY )
anova(thrustModel4)
############################################################### 5 frames before hoop
thrustModel1 <- lmer(data = noNaNData, thrustRelativeToHoopN5 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle + VisualAngleBetweenHoops + relativeHoopOrientY)
anova(thrustModel1)

thrustModel2 <- lmer(data = noNaNData, thrustRelativeToHoopN5 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle + relativeHoopOrientY)
anova(thrustModel2)

thrustModel3 <- lmer(data = noNaNData, thrustRelativeToHoopN5 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops)
anova(thrustModel3)

thrustModel4 <- lmer(data = noNaNData, thrustRelativeToHoopN5 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle + VisualAngleBetweenHoops + relativeHoopOrientY + VisualAngleBetweenHoops * relativeHoopOrientY )
anova(thrustModel4)
############################################################### 15 frames before hoop
thrustModel1 <- lmer(data = noNaNData, thrustRelativeToHoopN15 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle + VisualAngleBetweenHoops + relativeHoopOrientY)
anova(thrustModel1)

thrustModel2 <- lmer(data = noNaNData, thrustRelativeToHoopN15 ~ (1|Subject) + (1|block)+ ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle + relativeHoopOrientY)
anova(thrustModel2)

thrustModel3 <- lmer(data = noNaNData, thrustRelativeToHoopN15 ~ (1|Subject) + (1|block)+ ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops)
anova(thrustModel3)

thrustModel4 <- lmer(data = noNaNData, thrustRelativeToHoopN15 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops + relativeHoopOrientY + VisualAngleBetweenHoops * relativeHoopOrientY )
anova(thrustModel4)
############################################################### 30 frames before hoop
thrustModel1 <- lmer(data = noNaNData, thrustRelativeToHoopN30 ~ (1|Subject)+ (1|block) + ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle + VisualAngleBetweenHoops + relativeHoopOrientY)
anova(thrustModel1)

thrustModel2 <- lmer(data = noNaNData, thrustRelativeToHoopN30 ~ (1|Subject) + (1|block)+ ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle + relativeHoopOrientY)
anova(thrustModel2)

thrustModel3 <- lmer(data = noNaNData, thrustRelativeToHoopN30 ~ (1|Subject) + (1|block)+ ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle + VisualAngleBetweenHoops)
anova(thrustModel3)

thrustModel4 <- lmer(data = noNaNData, thrustRelativeToHoopN30 ~ (1|Subject) + (1|block)+ ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle + VisualAngleBetweenHoops + relativeHoopOrientY + VisualAngleBetweenHoops * relativeHoopOrientY )
anova(thrustModel4)
############################################################### 60 frames before hoop
thrustModel1 <- lmer(data = noNaNData, thrustRelativeToHoopN60 ~ (1|Subject) + (1|block)+ ApproachToNatNm1 + AngularOffsetToNatNm1+ prevHoopVisualAngle + VisualAngleBetweenHoops + relativeHoopOrientY)
anova(thrustModel1)

thrustModel2 <- lmer(data = noNaNData, thrustRelativeToHoopN60 ~ (1|Subject) + (1|block)+ ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle + relativeHoopOrientY)
anova(thrustModel2)

thrustModel3 <- lmer(data = noNaNData, thrustRelativeToHoopN60 ~ (1|Subject) + (1|block)+ ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops)
anova(thrustModel3)

thrustModel4 <- lmer(data = noNaNData, thrustRelativeToHoopN60 ~ (1|Subject) + (1|block)+ ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle+ VisualAngleBetweenHoops + relativeHoopOrientY + VisualAngleBetweenHoops * relativeHoopOrientY )
anova(thrustModel4)
################################################################



rHoopHeading0 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=ApproachAngleY0, color=Condition))+ 
  geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + 
  ggtitle('Angular Offset of hoops vs approach angle') + geom_smooth(method='lm')+ 
  ylab('Approach angle hoop N (deg.)') + xlab('Angular Offset Hoop N to N+1 (deg.)')+ 
  theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen","blue"))+theme(text = element_text(size=18))#+ geom_point()
rHoopHeading0

rHoopHeading5 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=ApproachAngleY25, color=Condition))+ 
  geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + 
  ggtitle('Relative orientation of hoops vs drone yaw relative to hoop') + geom_smooth(method='lm')+ 
  ylab('Thrust Angle relative to hoop N (deg.)') + xlab('Angular Offset Hoop N to N+1 (deg.)')+ 
  theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen","blue"))+theme(text = element_text(size=18))#+ geom_point()
rHoopHeading5

rHoopHeading15 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=ApproachAngleY50, color=Condition))+ 
  geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + 
  ggtitle('Relative orientation of hoops vs drone yaw relative to hoop') + geom_smooth(method='lm')+ 
  ylab('Thrust Angle relative to hoop N (deg.)') + xlab('Angular Offset Hoop N to N+1 (deg.)')+ 
  theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen","blue"))+theme(text = element_text(size=18))#+ geom_point()
rHoopHeading15

rHoopHeading30 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=ApproachAngleY75, color=Condition))+ 
  geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + 
  ggtitle('Relative orientation of hoops vs drone yaw relative to hoop') + geom_smooth(method='lm')+ 
  ylab('Thrust Angle relative to hoop N (deg.)') + xlab('Angular Offset Hoop N to N+1 (deg.)')+ 
  theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen","blue"))+theme(text = element_text(size=18))#+ geom_point()
rHoopHeading30

rHoopHeading60 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=ApproachAngleY100, color=Condition))+ 
  geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + 
  ggtitle('Relative orientation of hoops vs drone yaw relative to hoop') + geom_smooth(method='lm')+ 
  ylab('Thrust Angle relative to hoop N (deg.)') + xlab('Angular Offset Hoop N to N+1 (deg.)')+ 
  theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen","blue"))+theme(text = element_text(size=18))#+ geom_point()
rHoopHeading60





rHoopThrust0 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=thrustRelativeToHoopN, color=Condition))+ 
  geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + 
  ggtitle('Angular Offset of hoops vs Angle between thrust and hoop N') + geom_smooth(method='lm')+ 
  ylab('Thrust Angle relative to hoop N (deg.)') + xlab('Angular Offset Hoop N to N+1 (deg.)')+ 
  theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen","blue"))+theme(text = element_text(size=18))#+ geom_point()
rHoopThrust0

rHoopThrust5 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=thrustRelativeToHoopN5, color=Condition))+ 
  geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + 
  ggtitle('Relative orientation of hoops vs drone yaw relative to hoop') + geom_smooth(method='lm')+ 
  ylab('Thrust Angle relative to hoop N (deg.)') + xlab('Angular Offset Hoop N to N+1 (deg.)')+ 
  theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen","blue"))+theme(text = element_text(size=18))#+ geom_point()
rHoopThrust5

rHoopThrust15 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=thrustRelativeToHoopN15, color=Condition))+ 
  geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + 
  ggtitle('Relative orientation of hoops vs drone yaw relative to hoop') + geom_smooth(method='lm')+ 
  ylab('Thrust Angle relative to hoop N (deg.)') + xlab('Angular Offset Hoop N to N+1 (deg.)')+ 
  theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen","blue"))+theme(text = element_text(size=18))#+ geom_point()
rHoopThrust15

rHoopThrust30 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=thrustRelativeToHoopN30, color=Condition))+ 
  geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + 
  ggtitle('Relative orientation of hoops vs drone yaw relative to hoop') + geom_smooth(method='lm')+ 
  ylab('Thrust Angle relative to hoop N (deg.)') + xlab('Angular Offset Hoop N to N+1 (deg.)')+ 
  theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen","blue"))+theme(text = element_text(size=18))#+ geom_point()
rHoopThrust30

rHoopThrust60 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=thrustRelativeToHoopN60, color=Condition))+ 
  geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + 
  ggtitle('Relative orientation of hoops vs drone yaw relative to hoop') + geom_smooth(method='lm')+ 
  ylab('Thrust Angle relative to hoop N (deg.)') + xlab('Angular Offset Hoop N to N+1 (deg.)')+ 
  theme(legend.position = "none")+ scale_color_manual(values = c("darkgreen","blue"))+theme(text = element_text(size=18))#+ geom_point()
rHoopThrust60





grid.arrange(rHoopHeading0, rHoopThrust0,
             rHoopHeading5, rHoopThrust5,
             rHoopHeading15, rHoopThrust15,
             rHoopHeading30, rHoopThrust30,
             rHoopHeading60, rHoopThrust60, nrow=5)


###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################


###############################################################################################################
headingModelHoopOrient <- update(headingModelCovariates, .~. +relativeHoopOrientY)
anova(headingModelHoopOrient)

headingModelBothPredictors <- update(headingModelCovariates, .~. + relativeHoopOrientY + VisualAngleBetweenHoops)
anova(headingModelBothPredictors)

headingModelInteraction <- update(headingModelBothPredictors, .~. + relativeHoopOrientY : VisualAngleBetweenHoops)
anova(headingModelInteraction)

anova( headingModelCovariates, headingModelOffset, headingModelHoopOrient, headingModelBothPredictors, headingModelInteraction)









summary(lm(data=noNaNData, ApproachAngleY0 ~ ApproachToNatNm1 + VisualAngleBetweenHoops ) )


ggplot(data=noNaNData, aes(x=ApproachAngleY0, y = ApproachToNatNm1)) + geom_point() + geom_smooth(method='lm')









ndf <- na.omit(noNaNData)

summary(lmer(ApproachAngleY0 ~ (1|hoopNum) + (1|block) + (1|Subject) + 
             AngularOffsetToNatNm1 + ApproachToNatNm1 + prevHoopVisualAngle + timeBetweenHoops +
             VisualAngleBetweenHoops + relativeHoopOrientY + VisualAngleBetweenHoops : relativeHoopOrientY, data=noNaNData), type="I") 


summary(lm(cameraRotationRateALL ~ 1 + hoopNum + Subject + block + 
           ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle + timeBetweenHoops +
           relativeHoopOrientY + VisualAngleBetweenHoops , data=noNaNData)) 




ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y = cameraRelToHoop0, color=Subject)) + geom_point() + geom_smooth(method='lm')






noNaNDatahoopNum <- factor(noNaNDatahoopNum)

thrustModel1 <- lmer(data = noNaNData, cameraRotationRateALL ~ (1|Subject) +(1|hoopNum) )
summary(thrustModel1)


thrustModelCovariates <- update(thrustModel1, .~. + ApproachToNatNm1 + AngularOffsetToNatNm1 + prevHoopVisualAngle + timeBetweenHoops + hoopNum)
summary(thrustModelCovariates)


thrustModelOffset <- update(thrustModelCovariates, .~. + VisualAngleBetweenHoops)

anova(thrustModelOffset, type="I")


thrustModelHoopOrient <- update(thrustModelCovariates, .~. + relativeHoopOrientY)
anova(thrustModelHoopOrient, type="I")


thrustModelBothPredictors <- update(thrustModelCovariates, .~. + relativeHoopOrientY + VisualAngleBetweenHoops)
anova(thrustModelBothPredictors, type="I")


thrustModelInteraction <- update(thrustModelBothPredictors, .~. + relativeHoopOrientY : VisualAngleBetweenHoops)
anova(thrustModelInteraction, type="I")


anova( thrustModelCovariates, thrustModelBothPredictors, thrustModelInteraction)

anova( thrustModelCovariates, thrustModelHoopOrient, thrustModelInteraction)

anova( thrustModelCovariates, thrustModelOffset, thrustModelInteraction)


ggplot(data=noNaNData, aes(x=ApproachToNatNm1, y = thrustRelativeToHoopN, color=Condition)) + geom_point() + geom_smooth(method='lm')








###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################

headingModel1 <- lmer(data = noNaNData, ApproachAngleY0 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle+ AngularOffsetToNatNm1)
summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. +VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelOffset, .~. + relativeHoopOrientY)
m0 <- summary(headingModelOffset)
approachNm1_0 <- m0$coefficients[2]
offset_0 <- m0$coefficients[4]
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_0 <- r2$Rsq[3]
r2_0_orient <- r2$Rsq[4]
upperCI0offset <- r2$upper.CL[3]
lowerCI0offset <- r2$lower.CL[3] 
upperCI0orient <- r2$upper.CL[4]
lowerCI0orient <- r2$lower.CL[4]


headingModel1 <- lmer(data = noNaNData, ApproachAngleY25 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle+ AngularOffsetToNatNm1)
summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. +VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelOffset, .~. + relativeHoopOrientY)
m25 <- summary(headingModelOffset)
approachNm1_25 <- m25$coefficients[2]
offset_25 <- m25$coefficients[4]
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_25 <- r2$Rsq[3]
r2_25_orient <- r2$Rsq[4]

upperCI25offset <- r2$upper.CL[3]
lowerCI25offset <- r2$lower.CL[3] 
upperCI25orient <- r2$upper.CL[4]
lowerCI25orient <- r2$lower.CL[4]


headingModel1 <- lmer(data = noNaNData, ApproachAngleY50 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle+AngularOffsetToNatNm1)
summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. +VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelOffset, .~. + relativeHoopOrientY)
m50 <- summary(headingModelOffset)
approachNm1_50 <- m50$coefficients[2]
offset_50 <- m50$coefficients[4]
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_50 <- r2$Rsq[3]
r2_50_orient <- r2$Rsq[4]
upperCI50offset <- r2$upper.CL[3]
lowerCI50offset <- r2$lower.CL[3] 
upperCI50orient <- r2$upper.CL[4]
lowerCI50orient <- r2$lower.CL[4]
#+AngularOffsetToNatNm1 + prevHoopVisualAngle




headingModel1 <- lmer(data = noNaNData, ApproachAngleY75 ~ (1|Subject))
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle+AngularOffsetToNatNm1)

summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. +VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelOffset, .~. + relativeHoopOrientY)
m75 <- summary(headingModelOffset)
approachNm1_75 <- m75$coefficients[2]
offset_75 <- m75$coefficients[4]
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_75 <- r2$Rsq[3]
r2_75_orient <- r2$Rsq[4]
upperCI75offset <- r2$upper.CL[3]
lowerCI75offset <- r2$lower.CL[3] 
upperCI75orient <- r2$upper.CL[4]
lowerCI75orient <- r2$lower.CL[4]


headingModel1 <- lmer(data = noNaNData, ApproachAngleY100 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle + AngularOffsetToNatNm1)
summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. + VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelOffset, .~. + relativeHoopOrientY)

m100 <- summary(headingModelOffset)
approachNm1_100 <- m100$coefficients[2]
offset_100 <- m100$coefficients[4]
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_100 <- r2$Rsq[3]
r2_100_orient <- r2$Rsq[4]
upperCI100offset <- r2$upper.CL[3]
lowerCI100offset <- r2$lower.CL[3] 
upperCI100orient <- r2$upper.CL[4]
lowerCI100orient <- r2$lower.CL[4]

modelrquared <- c(r2_0, r2_25, r2_50, r2_75, r2_100, 
                  r2_0_orient, r2_25_orient, r2_50_orient, r2_75_orient, r2_100_orient)

coefficientType <- c("AngularOffsetNandNp1", "AngularOffsetNandNp1", "AngularOffsetNandNp1", "AngularOffsetNandNp1", "AngularOffsetNandNp1", 
                     "relHoopOrient","relHoopOrient", "relHoopOrient","relHoopOrient","relHoopOrient")

propSegment <- c(0,25,50,75,100, 0,25,50,75,100)

upperCI <- c(upperCI0offset, upperCI25offset, upperCI50offset, upperCI75offset, upperCI100offset,
             upperCI0orient, upperCI25orient, upperCI50orient, upperCI75orient, upperCI100orient)
lowerCI <- c(lowerCI0offset, lowerCI25offset, lowerCI50offset, lowerCI75offset, lowerCI100offset,
             lowerCI0orient, lowerCI25orient, lowerCI50orient, lowerCI75orient, lowerCI100orient)

coefDF <- data.frame(rsqrd=modelrquared, typeCoef=coefficientType, propSegment=propSegment, upperCI=upperCI, lowerCI=lowerCI)

approachGraph <- ggplot(data=coefDF, aes(x=propSegment, y=rsqrd, color=typeCoef)) + geom_point(size=2) + geom_line() +
  geom_errorbar(aes(ymin=lowerCI, ymax=upperCI), width=.2) +
  ylab("Partial R-Squared") + xlab("Proportion of segment") + ggtitle("Predicting Approach Angle at Hoop N")+ ylim(0,0.3)






###############################################################################################################
###############################################################################################################
###############################################################################################################


headingModel1 <- lmer(data = noNaNData, cameraRelToHoop0 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle+ AngularOffsetToNatNm1)
summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. +VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelCovariates, .~. + relativeHoopOrientY)
m0 <- summary(headingModelOffset)
approachNm1_0 <- m0$coefficients[2]
offset_0 <- m0$coefficients[4]
r2 <- r2beta(model=headingModelOffset,partial=TRUE, method='nsj')
r2_0 <- r2$Rsq[3]
upperCI0offset <- r2$upper.CL[3]
lowerCI0offset <- r2$lower.CL[3] 
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_0_orient <- r2$Rsq[4]

upperCI0orient <- r2$upper.CL[4]
lowerCI0orient <- r2$lower.CL[4]


headingModel1 <- lmer(data = noNaNData, cameraRelToHoop25 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle+ AngularOffsetToNatNm1)
summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. +VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelCovariates, .~. + relativeHoopOrientY)
m25 <- summary(headingModelOffset)
approachNm1_25 <- m25$coefficients[2]
offset_25 <- m25$coefficients[4]
r2 <- r2beta(model=headingModelOffset,partial=TRUE, method='nsj')
r2_25 <- r2$Rsq[3]
upperCI25offset <- r2$upper.CL[3]
lowerCI25offset <- r2$lower.CL[3] 
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_25_orient <- r2$Rsq[4]
upperCI25orient <- r2$upper.CL[4]
lowerCI25orient <- r2$lower.CL[4]



headingModel1 <- lmer(data = noNaNData, cameraRelToHoop50 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle+AngularOffsetToNatNm1)
summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. +VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelCovariates, .~. + relativeHoopOrientY)
m50 <- summary(headingModelOffset)
approachNm1_50 <- m50$coefficients[2]
offset_50 <- m50$coefficients[4]
r2 <- r2beta(model=headingModelOffset,partial=TRUE, method='nsj')
r2_50 <- r2$Rsq[3]
upperCI50offset <- r2$upper.CL[3]
lowerCI50offset <- r2$lower.CL[3] 
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_50_orient <- r2$Rsq[5]
upperCI50orient <- r2$upper.CL[5]
lowerCI50orient <- r2$lower.CL[5]
#+AngularOffsetToNatNm1 + prevHoopVisualAngle




headingModel1 <- lmer(data = noNaNData, cameraRelToHoop75 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle+AngularOffsetToNatNm1)

summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. +VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelCovariates, .~. + relativeHoopOrientY)
m75 <- summary(headingModelOffset)
approachNm1_75 <- m75$coefficients[2]
offset_75 <- m75$coefficients[4]
r2 <- r2beta(model=headingModelOffset,partial=TRUE, method='nsj')
r2_75 <- r2$Rsq[3]
upperCI75offset <- r2$upper.CL[3]
lowerCI75offset <- r2$lower.CL[3] 
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_75_orient <- r2$Rsq[5]
upperCI75orient <- r2$upper.CL[5]
lowerCI75orient <- r2$lower.CL[5]


headingModel1 <- lmer(data = noNaNData, cameraRelToHoop100 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1+ prevHoopVisualAngle + AngularOffsetToNatNm1)
summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. + VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelCovariates, .~. + relativeHoopOrientY)

m100 <- summary(headingModelOffset)
approachNm1_100 <- m100$coefficients[2]
offset_100 <- m100$coefficients[4]
r2 <- r2beta(model=headingModelOffset,partial=TRUE, method='nsj')
r2_100 <- r2$Rsq[3]
upperCI100offset <- r2$upper.CL[3]
lowerCI200offset <- r2$lower.CL[3] 
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_100_orient <- r2$Rsq[5]
upperCI100orient <- r2$upper.CL[5]
lowerCI100orient <- r2$lower.CL[5]

modelrquared <- c(r2_0, r2_25, r2_50, r2_75, r2_100, 
                  r2_0_orient, r2_25_orient, r2_50_orient, r2_75_orient, r2_100_orient)

coefficientType <- c("AngularOffsetNandNp1", "AngularOffsetNandNp1", "AngularOffsetNandNp1", "AngularOffsetNandNp1", "AngularOffsetNandNp1", 
                     "relHoopOrient","relHoopOrient", "relHoopOrient","relHoopOrient","relHoopOrient")

propSegment <- c(0,25,50,75,100, 0,25,50,75,100)


upperCI <- c(upperCI0offset, upperCI25offset, upperCI50offset, upperCI75offset, upperCI100offset,
             upperCI0orient, upperCI25orient, upperCI50orient, upperCI75orient, upperCI100orient)
lowerCI <- c(lowerCI0offset, lowerCI25offset, lowerCI50offset, lowerCI75offset, lowerCI100offset,
             lowerCI0orient, lowerCI25orient, lowerCI50orient, lowerCI75orient, lowerCI100orient)

coefDF <- data.frame(rsqrd=modelrquared, typeCoef=coefficientType, propSegment=propSegment, upperCI=upperCI, lowerCI=lowerCI)

cameraGraph <- ggplot(data=coefDF, aes(x=propSegment, y=rsqrd, color=typeCoef)) + geom_point(size=2) + geom_line() +
  geom_errorbar(aes(ymin=lowerCI, ymax=upperCI), width=.2) +
  ylab("Partial R-Squared") + xlab("Proportion of segment") + ggtitle("Predicting Relative Camera Angle at Hoop N")+ ylim(0,0.3)







###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################



headingModel1 <- lmer(data = noNaNData, thrustRelativeToHoopN0 ~ (1|Subject))
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle+ AngularOffsetToNatNm1)
summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. +VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelCovariates, .~. + relativeHoopOrientY)
m0 <- summary(headingModelOffset)
approachNm1_0 <- m0$coefficients[2]
offset_0 <- m0$coefficients[4]
r2 <- r2beta(model=headingModelOffset,partial=TRUE, method='nsj')
r2_0 <- r2$Rsq[3]
upperCI0offset <- r2$upper.CL[3]
lowerCI0offset <- r2$lower.CL[3] 
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_0_orient <- r2$Rsq[4]

upperCI0orient <- r2$upper.CL[4]
lowerCI0orient <- r2$lower.CL[4]


headingModel1 <- lmer(data = noNaNData, thrustRelativeToHoopN25 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle+ AngularOffsetToNatNm1)
summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. +VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelCovariates, .~. + relativeHoopOrientY)
m25 <- summary(headingModelOffset)
approachNm1_25 <- m25$coefficients[2]
offset_25 <- m25$coefficients[4]
r2 <- r2beta(model=headingModelOffset,partial=TRUE, method='nsj')
r2_25 <- r2$Rsq[3]
upperCI25offset <- r2$upper.CL[3]
lowerCI25offset <- r2$lower.CL[3] 
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_25_orient <- r2$Rsq[4]
upperCI25orient <- r2$upper.CL[4]
lowerCI25orient <- r2$lower.CL[4]



headingModel1 <- lmer(data = noNaNData, thrustRelativeToHoopN50 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle+AngularOffsetToNatNm1)
summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. +VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelCovariates, .~. + relativeHoopOrientY)
m50 <- summary(headingModelOffset)
approachNm1_50 <- m50$coefficients[2]
offset_50 <- m50$coefficients[4]
r2 <- r2beta(model=headingModelOffset,partial=TRUE, method='nsj')
r2_50 <- r2$Rsq[3]
upperCI50offset <- r2$upper.CL[3]
lowerCI50offset <- r2$lower.CL[3] 
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_50_orient <- r2$Rsq[5]
upperCI50orient <- r2$upper.CL[5]
lowerCI50orient <- r2$lower.CL[5]
#+AngularOffsetToNatNm1 + prevHoopVisualAngle




headingModel1 <- lmer(data = noNaNData, thrustRelativeToHoopN75 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle + AngularOffsetToNatNm1)

summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. +VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelCovariates, .~. + relativeHoopOrientY)
m75 <- summary(headingModelOffset)
approachNm1_75 <- m75$coefficients[2]
offset_75 <- m75$coefficients[4]
r2 <- r2beta(model=headingModelOffset,partial=TRUE, method='nsj')
r2_75 <- r2$Rsq[3]
upperCI75offset <- r2$upper.CL[3]
lowerCI75offset <- r2$lower.CL[3] 
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_75_orient <- r2$Rsq[5]
upperCI75orient <- r2$upper.CL[5]
lowerCI75orient <- r2$lower.CL[5]


headingModel1 <- lmer(data = noNaNData, thrustRelativeToHoopN100 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1+ prevHoopVisualAngle + AngularOffsetToNatNm1)
summary(headingModelCovariates)

headingModelOffset <- update(headingModelCovariates, .~. + VisualAngleBetweenHoops)
headingModelOrient <- update(headingModelCovariates, .~. + relativeHoopOrientY)

m100 <- summary(headingModelOffset)
approachNm1_100 <- m100$coefficients[2]
offset_100 <- m100$coefficients[4]
r2 <- r2beta(model=headingModelOffset,partial=TRUE, method='nsj')
r2_100 <- r2$Rsq[3]
upperCI100offset <- r2$upper.CL[3]
lowerCI100offset <- r2$lower.CL[3] 
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_100_orient <- r2$Rsq[5]
upperCI100orient <- r2$upper.CL[5]
lowerCI100orient <- r2$lower.CL[5]

modelrquared <- c(r2_0, r2_25, r2_50, r2_75, r2_100, 
                  r2_0_orient, r2_25_orient, r2_50_orient, r2_75_orient, r2_100_orient)

coefficientType <- c("AngularOffsetNandNp1", "AngularOffsetNandNp1", "AngularOffsetNandNp1", "AngularOffsetNandNp1", "AngularOffsetNandNp1", 
                     "relHoopOrient","relHoopOrient", "relHoopOrient","relHoopOrient","relHoopOrient")

propSegment <- c(0,25,50,75,100, 0,25,50,75,100)

upperCI <- c(upperCI0offset, upperCI25offset, upperCI50offset, upperCI75offset, upperCI100offset,
             upperCI0orient, upperCI25orient, upperCI50orient, upperCI75orient, upperCI100orient)
lowerCI <- c(lowerCI0offset, lowerCI25offset, lowerCI50offset, lowerCI75offset, lowerCI100offset,
             lowerCI0orient, lowerCI25orient, lowerCI50orient, lowerCI75orient, lowerCI100orient)

coefDF <- data.frame(rsqrd=modelrquared, typeCoef=coefficientType, propSegment=propSegment, upperCI=upperCI, lowerCI=lowerCI)

thrustGraph <- ggplot(data=coefDF, aes(x=propSegment, y=rsqrd, color=typeCoef)) + geom_point(size=2) + geom_line() +
  geom_errorbar(aes(ymin=lowerCI, ymax=upperCI), width=.2) +
  ylab("Partial R-Squared") + xlab("Proportion of segment") + ggtitle("Predicting Thrust Angle at Hoop N") + ylim(0,0.3)


grid.arrange(approachGraph, cameraGraph, thrustGraph, nrow=3)
