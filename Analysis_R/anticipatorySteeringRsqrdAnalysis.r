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

errorBarWidth <- 0.02

noNaNData$relativeHoopOrientY <- (noNaNData$currHoopOrientY-noNaNData$nextHoopOrientY)*180/pi
noNaNData$droneOrientRelativeToHoop <- (noNaNData$currHoopOrientY*180/pi) - (noNaNData$droneOrientYatHoop)
noNaNData$droneOrientRelativeToNextHoop <- noNaNData$nextHoopOrientY - (noNaNData$droneOrientYatHoop*pi/180)

###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################

#Baseline model
headingModel1 <- lmer(data = noNaNData, ApproachAngleY0 ~ (1|Subject) )
summary(headingModel1)
#Covariate model
headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle+ AngularOffsetToNatNm1)
summary(headingModelCovariates)

#Offset  model
headingModelOffset <- update(headingModelCovariates, .~. +VisualAngleBetweenHoops)
#Orient model
headingModelOrient <- update(headingModelCovariates, .~. + relativeHoopOrientY)

m0 <- summary(headingModelOffset)
approachNm1_0 <- m0$coefficients[2]
offset_0 <- m0$coefficients[4]
r2 <- r2beta(model=headingModelOffset,partial=TRUE, method='nsj')
r2_0 <- r2$Rsq[3]
upperCI0offset <- r2$upper.CL[3]
lowerCI0offset <- r2$lower.CL[3] 

r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_0_orient <- r2$Rsq[5]
upperCI0orient <- r2$upper.CL[5]
lowerCI0orient <- r2$lower.CL[5]


headingModel1 <- lmer(data = noNaNData, ApproachAngleY25 ~ (1|Subject) )
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


headingModel1 <- lmer(data = noNaNData, ApproachAngleY50 ~ (1|Subject) )
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
r2_50_orient <- r2$Rsq[4]
upperCI50orient <- r2$upper.CL[4]
lowerCI50orient <- r2$lower.CL[4]
#+AngularOffsetToNatNm1 + prevHoopVisualAngle




headingModel1 <- lmer(data = noNaNData, ApproachAngleY75 ~ (1|Subject))
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


headingModel1 <- lmer(data = noNaNData, ApproachAngleY100 ~ (1|Subject) )
summary(headingModel1)

headingModelCovariates <- update(headingModel1, .~. + ApproachToNatNm1 + prevHoopVisualAngle + AngularOffsetToNatNm1)
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

coefficientType <- c("Angular Offset", "Angular Offset", "Angular Offset", "Angular Offset", "Angular Offset", 
                     "Rel. Hoop Orientation","Rel. Hoop Orientation", "Rel. Hoop Orientation", "Rel. Hoop Orientation", "Rel. Hoop Orientation")

propSegment <- c(0,0.25,0.50,0.75,1.00, 0,0.25,0.50,0.75,1.00)

upperCI <- c(upperCI0offset, upperCI25offset, upperCI50offset, upperCI75offset, upperCI100offset,
             upperCI0orient, upperCI25orient, upperCI50orient, upperCI75orient, upperCI100orient)
lowerCI <- c(lowerCI0offset, lowerCI25offset, lowerCI50offset, lowerCI75offset, lowerCI100offset,
             lowerCI0orient, lowerCI25orient, lowerCI50orient, lowerCI75orient, lowerCI100orient)

coefDF <- data.frame(rsqrd=modelrquared, Coefficient=coefficientType, propSegment=propSegment, upperCI=upperCI, lowerCI=lowerCI)

approachGraph <- ggplot(data=coefDF, aes(x=propSegment, y=rsqrd, color=Coefficient)) + geom_point(size=2) + geom_line() +
  geom_errorbar(aes(ymin=lowerCI, ymax=upperCI), width=errorBarWidth) +
  ylab("Partial R-Squared") + xlab("Proportion of segment") + ggtitle("Predicting Approach Angle at Hoop N")+ ylim(0,0.3)


approachGraph



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
lowerCI100offset <- r2$lower.CL[3] 
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_100_orient <- r2$Rsq[5]
upperCI100orient <- r2$upper.CL[5]
lowerCI100orient <- r2$lower.CL[5]

modelrquared <- c(r2_0, r2_25, r2_50, r2_75, r2_100, 
                  r2_0_orient, r2_25_orient, r2_50_orient, r2_75_orient, r2_100_orient)

coefficientType <- c("Angular Offset", "Angular Offset", "Angular Offset", "Angular Offset", "Angular Offset", 
                     "Rel. Hoop Orientation","Rel. Hoop Orientation", "Rel. Hoop Orientation", "Rel. Hoop Orientation", "Rel. Hoop Orientation")

propSegment <- c(0,0.25,0.50,0.75,1.00, 0,0.25,0.50,0.75,1.00)


upperCI <- c(upperCI0offset, upperCI25offset, upperCI50offset, upperCI75offset, upperCI100offset,
             upperCI0orient, upperCI25orient, upperCI50orient, upperCI75orient, upperCI100orient)
lowerCI <- c(lowerCI0offset, lowerCI25offset, lowerCI50offset, lowerCI75offset, lowerCI100offset,
             lowerCI0orient, lowerCI25orient, lowerCI50orient, lowerCI75orient, lowerCI100orient)

coefDF <- data.frame(rsqrd=modelrquared, Coefficient=coefficientType, propSegment=propSegment, upperCI=upperCI, lowerCI=lowerCI)

cameraGraph <- ggplot(data=coefDF, aes(x=propSegment, y=rsqrd, color=Coefficient)) + geom_point(size=2) + geom_line() +
  geom_errorbar(aes(ymin=lowerCI, ymax=upperCI), width=errorBarWidth) +
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
r2_0_orient <- r2$Rsq[5]

upperCI0orient <- r2$upper.CL[5]
lowerCI0orient <- r2$lower.CL[5]


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
r2_25_orient <- r2$Rsq[5]
upperCI25orient <- r2$upper.CL[5]
lowerCI25orient <- r2$lower.CL[5]



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
r2_75 <- r2$Rsq[2]
upperCI75offset <- r2$upper.CL[2]
lowerCI75offset <- r2$lower.CL[2] 
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
r2_100 <- r2$Rsq[2]
upperCI100offset <- r2$upper.CL[2]
lowerCI100offset <- r2$lower.CL[2] 
r2 <- r2beta(model=headingModelOrient,partial=TRUE, method='nsj')
r2_100_orient <- r2$Rsq[5]
upperCI100orient <- r2$upper.CL[5]
lowerCI100orient <- r2$lower.CL[5]

modelrquared <- c(r2_0, r2_25, r2_50, r2_75, r2_100, 
                  r2_0_orient, r2_25_orient, r2_50_orient, r2_75_orient, r2_100_orient)

coefficientType <- c("Angular Offset", "Angular Offset", "Angular Offset", "Angular Offset", "Angular Offset", 
                     "Rel. Hoop Orientation","Rel. Hoop Orientation", "Rel. Hoop Orientation", "Rel. Hoop Orientation", "Rel. Hoop Orientation")

propSegment <- c(0,0.25,0.50,0.75,1.00, 0,0.25,0.50,0.75,1.00)

upperCI <- c(upperCI0offset, upperCI25offset, upperCI50offset, upperCI75offset, upperCI100offset,
             upperCI0orient, upperCI25orient, upperCI50orient, upperCI75orient, upperCI100orient)
lowerCI <- c(lowerCI0offset, lowerCI25offset, lowerCI50offset, lowerCI75offset, lowerCI100offset,
             lowerCI0orient, lowerCI25orient, lowerCI50orient, lowerCI75orient, lowerCI100orient)

coefDF <- data.frame(rsqrd=modelrquared, Coefficient=coefficientType, propSegment=propSegment, upperCI=upperCI, lowerCI=lowerCI)

thrustGraph <- ggplot(data=coefDF, aes(x=propSegment, y=rsqrd, color=Coefficient)) + geom_point(size=2) + geom_line() +
  geom_errorbar(aes(ymin=lowerCI, ymax=upperCI), width=errorBarWidth) +
  ylab("Partial R-Squared") + xlab("Proportion of segment") + ggtitle("Predicting Thrust Angle at Hoop N") + ylim(0,0.3)


grid.arrange(approachGraph, cameraGraph, thrustGraph, nrow=3)

