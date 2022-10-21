library(ggplot2)

library(effectsize)
library('lme4')
library(lmerTest)
library(nlme)
library(gridExtra)
orientationData <- read.csv('droneOrientationDataset10Frames.txt', sep=',')
orientationData <- orientationData[orientationData$numberCollisions<1,]

eq <- function(x,y) {
  m <- lm(y ~ x)
  as.character(
    as.expression(
      substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2,
                 list(a = format(coef(m)[1], digits = 4),
                      b = format(coef(m)[2], digits = 4),
                      r2 = format(summary(m)$r.squared, digits = 3)))
    )
  )
}
## Include time to complete lap as a measure of skill

noPathOnly <- orientationData#[orientationData$LAF==0,]

#noCollisions <- noPathOnly[noPathOnly$numberCollisions<10,]
#noPathOnly <- noPathOnly[noPathOnly$block <5,]

noNaNData <- na.omit(noPathOnly)




noNaNData$relativeHoopOrientY <- (noNaNData$currHoopOrientY-noNaNData$nextHoopOrientY)*180/pi
noNaNData$droneOrientRelativeToHoop <- (noNaNData$currHoopOrientY*180/pi) - (noNaNData$droneOrientYatHoop)
noNaNData$droneOrientRelativeToNextHoop <- noNaNData$nextHoopOrientY - (noNaNData$droneOrientYatHoop*pi/180)

#ggplot(data=noNaNData, aes(x=currHoopOrientY*180/pi, y=droneOrientYatHoop )) + geom_point()


vAngVdrone <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=cameraRelToHoop0, color=Condition))+ geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + ggtitle('Angular Offset between hoops vs drone yaw relative to hoop') + ylab('Drone Yaw Relative to hoop (deg.)') + xlab('Angular Offset (deg.)') +  theme(legend.position = c(0.8, 0.9))+ scale_color_manual(values = c("green", "blue"))+theme(text = element_text(size=18)) + geom_smooth(method='lm')

vAngVdrone


rateAngle <- ggplot(noNaNData, aes(x = VisualAngleBetweenHoops, y=cameraRelToHoop)) +
    geom_density_2d() + ggtitle('Visual Angle predicts drone yaw relative to hoop') + geom_smooth(method='lm') #+ xlim(-40,40)
rateAngle

grid.arrange(vAngVdrone, rateAngle, nrow=1)


rHoopVdrone <- ggplot(data=noNaNData, aes(x=relativeHoopOrientY, y=cameraRelToHoop, color=Condition))+ geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + ggtitle('Relative orientation of hoops vs drone yaw relative to hoop') + geom_smooth(method='lm')+ ylab('Drone Yaw Relative to hoop (deg.)') + xlab('Relative Hoop Orientation (deg.)')+ theme(legend.position = "none")+ scale_color_manual(values = c("green", "blue"))+theme(text = element_text(size=18))#+ geom_point()
rHoopVdrone

droneOrientM1 <- lmer(cameraRelToHoop ~ (1|Subject/Condition) + relativeHoopOrientY * VisualAngleBetweenHoops, data=noNaNData)

#droneOrientM1 <- lm(droneOrientYatHoop ~ relativeHoopOrientY * VisualAngleBetweenHoops, data=noNaNData)

anova(droneOrientM1)
summary(droneOrientM1)
confint(droneOrientM1)


droneOrientM2 <- lmer(cameraRelToHoop ~ (1|Subject/Condition) +VisualAngleBetweenHoops, data=noNaNData)

anova(droneOrientM2)

droneOrientM3 <- lmer(cameraRelToHoop ~ (1|Subject/Condition) + relativeHoopOrientY, data=noNaNData)

anova(droneOrientM3)

anova(droneOrientM1, droneOrientM2, droneOrientM3)


F_to_eta2(6.496, 1, 3491)
F_to_eta2(873.15, 1, 3493)

F_to_eta2(9.28, 1, 3494)



vAngVapproach <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=ApproachAngleY, color=Condition))+ geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + ggtitle('Angular Offset between hoops vs drone approach angle at hoop') + geom_smooth(method='lm') + ylab('Approach Angle (deg.)') + xlab('Angular Offset (deg.)')+ theme(legend.position = "none")+ scale_color_manual(values = c("green", "blue"))+theme(text = element_text(size=18))#+ geom_point()
vAngVapproach

rHoopVapproach <- ggplot(data=noNaNData, aes(x=relativeHoopOrientY, y=ApproachAngleY, color=Condition))+ geom_point(alpha=1, size=2, position = position_dodge(width=2.5)) + ggtitle('Relative orientation of hoops vs drone approach angle at hoop') + geom_smooth(method='lm')+ ylab('Approach Angle (deg.)') + xlab('Relative Hoop Orientation (deg.)')+ theme(legend.position = "none")+ scale_color_manual(values = c("green", "blue"))+theme(text = element_text(size=18))#+ geom_point()
rHoopVapproach


droneApproachM1 <- lmer(ApproachAngleY ~ (1|Subject/Condition) + relativeHoopOrientY * VisualAngleBetweenHoops, data=noNaNData)


anova(droneApproachM1)
summary(droneApproachM1)
confint(droneApproachM1)

droneApproachM2 <- lmer(ApproachAngleY ~ (1|Subject/Condition)+  VisualAngleBetweenHoops, data=noNaNData)

anova(droneApproachM2)

droneApproachM3 <- lmer(ApproachAngleY ~ (1|Subject/Condition) + relativeHoopOrientY , data=noNaNData)

anova(droneApproachM3)
anova(droneApproachM1, droneApproachM2, droneApproachM3)

F_to_eta2(4.78, 1, 3571.6)
F_to_eta2(816.12, 1, 3571.9)
F_to_eta2(4.83, 1, 3572.9)

#What to report = (parameter name | beta | lower-95 | upper-95 | random effect (SD))


grid.arrange(rHoopVdrone, vAngVdrone, 
             rHoopVapproach, vAngVapproach, nrow=2)


r0 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=cameraRelToHoop0, color=Condition)) + geom_point() + geom_smooth(method='lm')
r5 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=cameraRelToHoop5, color=Condition)) + geom_point() + geom_smooth(method='lm')
r15 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=cameraRelToHoop15, color=Condition)) + geom_point() + geom_smooth(method='lm')
r30 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=cameraRelToHoop30, color=Condition)) + geom_point() + geom_smooth(method='lm')
r60 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=cameraRelToHoop60, color=Condition)) + geom_point() + geom_smooth(method='lm')


t0 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=thrustHoopDiff0, color=Condition)) + geom_point() + geom_smooth(method='lm')
t5 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=thrustHoopDiff5, color=Condition)) + geom_point() + geom_smooth(method='lm')
t15 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=thrustHoopDiff15, color=Condition)) + geom_point() + geom_smooth(method='lm')
t30 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=thrustHoopDiff30, color=Condition)) + geom_point() + geom_smooth(method='lm')
t60 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=thrustHoopDiff60, color=Condition)) + geom_point() + geom_smooth(method='lm')


tall <- ggplot(data=noNaNData) + geom_density(aes(x=abs(thrustHoopDiff0)))+ 
  geom_density(aes(x=abs(thrustHoopDiff5)), color="blue")+ 
  geom_density(aes(x=abs(thrustHoopDiff15)), color="red")+
  geom_density(aes(x=abs(thrustHoopDiff30)), color="green")+
   geom_density(aes(x=abs(thrustHoopDiff60)), color="cyan")


p0 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=ApproachAngleY0, color=Condition)) + geom_point() + geom_smooth(method='lm')
p5 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=ApproachAngleY5, color=Condition)) + geom_point() + geom_smooth(method='lm')
p15 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=ApproachAngleY15, color=Condition)) + geom_point() + geom_smooth(method='lm')
p30 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=ApproachAngleY30, color=Condition)) + geom_point() + geom_smooth(method='lm')
p60 <- ggplot(data=noNaNData, aes(x=VisualAngleBetweenHoops, y=ApproachAngleY60, color=Condition)) + geom_point() + geom_smooth(method='lm')

droneApproach0 <- lmer(ApproachAngleY0 ~ (1|Subject)+  VisualAngleBetweenHoops, data=noNaNData)
s0 <- summary(droneApproach0)
c0 <- s0$coefficients[2]

droneApproach5 <- lmer(ApproachAngleY5 ~ (1|Subject)+  VisualAngleBetweenHoops, data=noNaNData)
s5 <- summary(droneApproach5)
c5 <- s5$coefficients[2]

droneApproach15 <- lmer(ApproachAngleY15 ~ (1|Subject)+  VisualAngleBetweenHoops, data=noNaNData)
s15 <- summary(droneApproach15)
c15 <- s15$coefficients[2]

droneApproach30 <- lmer(ApproachAngleY30 ~ (1|Subject)+  VisualAngleBetweenHoops, data=noNaNData)
s30 <- summary(droneApproach30)
c30 <- s30$coefficients[2]

droneApproach60 <- lmer(ApproachAngleY60 ~ (1|Subject)+  VisualAngleBetweenHoops, data=noNaNData)
s60 <- summary(droneApproach60)
c60 <- s60$coefficients[2]


plot(c(0, 5, 15, 30, 60), c(c0, c5, c15, c30, c60))


grid.arrange(p0, p5, p15, p30, p60, nrow=1)

grid.arrange(r0, r5, r15, r30, r60,
             p0, p5, p15, p30, p60,
             t0, t5, t15, t30, t60, nrow=3)
noNaNData$timeAfterPreviousHoopFirstGazeNextHoop

d0 <- ggplot(data=noNaNData, aes(x=hoopThrust0, y=nextHoopThrust0, color=Condition)) + geom_density_2d()+ theme(legend.position = "none") + ggtitle('Angle Between Thrust and Hoop N/N+1 (0 Frames)') + xlab("Thrust and Hoop N (Deg.)") + ylab("Thrust and Hoop N+1 (Deg.)") + ylim(-90, 50) + xlim(-120,120)
d5 <- ggplot(data=noNaNData, aes(x=hoopThrust5, y=nextHoopThrust5, color=Condition)) + geom_density_2d()+ theme(legend.position = "none") + ggtitle('Angle Between Thrust and Hoop N/N+1 (-5 Frames)') + xlab("Thrust and Hoop N (Deg.)") + ylab("Thrust and Hoop N+1 (Deg.)")+ ylim(-90, 50) + xlim(-120,120)
d15 <- ggplot(data=noNaNData, aes(x=hoopThrust15, y=nextHoopThrust15, color=Condition)) + geom_density_2d()+ theme(legend.position = "none")  + ggtitle('Angle Between Thrust and Hoop N/N+1 (-15 Frames)') + xlab("Thrust and Hoop N (Deg.)") + ylab("Thrust and Hoop N+1 (Deg.)")+ ylim(-90, 50) + xlim(-120,120)
d30 <- ggplot(data=noNaNData, aes(x=hoopThrust30, y=nextHoopThrust30, color=Condition)) + geom_density_2d()+ theme(legend.position = "none")  + ggtitle('Angle Between Thrust and Hoop N/N+1 (-30 Frames)') + xlab("Thrust and Hoop N (Deg.)") + ylab("Thrust and Hoop N+1 (Deg.)")+ ylim(-90, 50) + xlim(-120,120)
d60 <- ggplot(data=noNaNData, aes(x=hoopThrust60, y=nextHoopThrust60, color=Condition)) + geom_density_2d()+ theme(legend.position = "none")  + ggtitle('Angle Between Thrust and Hoop N/N+1 (-60 Frames)') + xlab("Thrust and Hoop N (Deg.)") + ylab("Thrust and Hoop N+1 (Deg.)")+ ylim(-90, 50) + xlim(-120,120)

grid.arrange(d0, d5, d15, d30, d60, nrow=1)




meanHoopThrust0 <- mean(noNaNData$hoopThrust0)
meanHoopThrust5 <- mean(noNaNData$hoopThrust5)
meanHoopThrust15 <- mean(noNaNData$hoopThrust15)
meanHoopThrust30 <- mean(noNaNData$hoopThrust30)
meanHoopThrust60 <- mean(noNaNData$hoopThrust60)


meanNextHoopThrust0 <- mean(noNaNData$nextHoopThrust0)
meanNextHoopThrust5 <- mean(noNaNData$nextHoopThrust5)
meanNextHoopThrust15 <- mean(noNaNData$nextHoopThrust15)
meanNextHoopThrust30 <- mean(noNaNData$nextHoopThrust30)
meanNextHoopThrust60 <- mean(noNaNData$nextHoopThrust60)

thrustMeansDF <- data.frame(Frame=c(0,-5,-15,-30,-60), hoopN=c(meanHoopThrust0, meanHoopThrust5, meanHoopThrust15, meanHoopThrust30, meanHoopThrust60), hoopNp1=c(meanNextHoopThrust0, meanNextHoopThrust5, meanNextHoopThrust15, meanNextHoopThrust30, meanNextHoopThrust60))


thrustDF = data.frame(Frame=c(rep(0, nrow(noNaNData)),rep(-5, nrow(noNaNData)), rep(-15, nrow(noNaNData)), rep(-30,nrow(noNaNData)), rep(-60, nrow(noNaNData)), rep(0, nrow(noNaNData)),rep(-5, nrow(noNaNData)), rep(-15, nrow(noNaNData)), rep(-30,nrow(noNaNData)), rep(-60, nrow(noNaNData))), 
                      hoop=c(rep("hoopN", nrow(noNaNData)*5), rep("hoopNp1", nrow(noNaNData)*5)), 
                      angle=c(noNaNData$hoopThrust0, noNaNData$hoopThrust5, noNaNData$hoopThrust15, noNaNData$hoopThrust30, noNaNData$hoopThrust60, noNaNData$nextHoopThrust0, noNaNData$nextHoopThrust5, noNaNData$nextHoopThrust15, noNaNData$nextHoopThrust30, noNaNData$nextHoopThrust60))




ggplot(data=thrustMeansDF) + geom_point(aes(x=Frame, y=abs(hoopN)), color="red", size=3) + geom_line(aes(x=Frame, y=abs(hoopN)), color="red") +
  geom_point(aes(x=Frame, y=abs(hoopNp1)), color="blue", size=3) + geom_line(aes(x=Frame, y=abs(hoopNp1)), color="blue") + 
  ylab('Mean Abs Angle between Thrust and Hoop (Deg.)') 


thrustAnglePlot <- ggplot(thrustDF, aes(x=Frame, y=angle, colour=hoop))+ 
  stat_summary(fun.y=mean, geom = "line", size=1)+ 
  stat_summary(fun.y=mean, geom = "point", size=3)+
  stat_summary(fun.data="mean_cl_normal", geom = "errorbar", width=0.5) + 
  geom_hline(yintercept=0, linetype="dashed")
thrustAnglePlot
