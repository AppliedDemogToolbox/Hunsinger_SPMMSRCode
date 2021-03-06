##############################################################################################################################
##EDDIE'S R CODE FOR FITTING THE MODEL MIGRATION SCHEDULE WITH STUDENT PEAK - COMPARISON CODE
##
##FOR MORE INFO, SEE https://raw.githubusercontent.com/AppliedDemogToolbox/Hunsinger_MMSRCode/master/SPMMSRCode.R
##via https://applieddemogtoolbox.github.io/Toolbox/#MMSRCode
##
##EDDIE HUNSINGER, OCTOBER 2018 (UPDATED APRIL 2019)
##http://www.demog.berkeley.edu/~eddieh/
##
##IF YOU WOULD LIKE TO USE, SHARE OR REPRODUCE THIS CODE, BE SURE TO CITE THE SOURCE
##This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. More information: https://creativecommons.org/licenses/by-nc-sa/4.0/? 
##
##INFO AND SOURCES ON THE MODEL
##Wilson, T. (2010). “Model Migration Schedules Incorporating Student Migration Peaks.” Demographic Research, 23(8): 191–222.
##	Available online: https://www.demographic-research.org/volumes/vol23/8/default.htm 
##	Related Excel Workbook by Tom Wilson: http://www.demog.berkeley.edu/~eddieh/toolbox.html#spmms  
##Rogers A & Castro LJ (1981). “Model Migration Schedules.” IIASA Research Report. IIASA, Laxenburg, Austria: RR-81-030
##	Available online: http://pure.iiasa.ac.at/id/eprint/1543/  
##############################################################################################################################


##############################
##INPUTS
##############################

###############
#DATA FROM WILSON (2010)
SPMMSTestingData<-read.table(file="https://github.com/AppliedDemogToolbox/Hunsinger_MMSRCode/raw/master/SPMMSData.csv",header=TRUE,sep=",")
migprob<-(SPMMSTestingData$Migration.probability[1:90])

#SIZE OF migprob (DATA BY AGE) USED
SIZE<-90

#NUMBER OF TRIES - USED FOR FITTING
TRIES<-1000

#PROPORTION TO ITER DISTRIBUTION BOUND SELECTION WITH
BEST<-.015

#CONVERGENCE INDEX
FITTO<-1e-10
###############

###############
##STEP 1 INPUTS
#PROPORTIONALLY ADJUST DATA TO SUM TO 1 - NO PARAMETERS
###############

###############
##STEP 2 INPUTS
#NUMBER OF SMALLEST VALUES TO USE AVERAGE OF AS LEVEL TERM
level<-5
###############

###############
##STEP 3 INPUTS
#MIN AND MAX OF CHILDHOOD AGES TO FIT OVER
childmin<-0
childmax<-16

#HEIGHT OF THE CHILDHOOD CURVE
childparam1tries<-array(runif(TRIES,0,.1))

#RATE OF DESCENT OF THE CHILDHOOD CURVE
childparam2tries<-array(runif(TRIES,0,1))
###############

###############
##STEP 4 INPUTS
#MIN AND MAX OF LABOR FORCE AGES TO FIT OVER
labormin<-17
labormax<-45

#STUDENT AGES TO EXCLUDE - CURRENTLY MUST BE ADJACENT AGES - TO EXCLUDE STUDENT PEAK FROM MODEL CAN SET AS JUST '0'
studentages<-c(18,19) #studentages<-c(0)

#HEIGHT OF THE LABOR FORCE CURVE
labparam1tries<-array(runif(TRIES,.04,.08))

#RATE OF DESCENT OF THE LABOR FORCE CURVE
labparam2tries<-array(runif(TRIES,.06,.10))

#POSITION OF THE LABOR FORCE CURVE ON THE AGE-AXIS
labparam3tries<-array(runif(TRIES,20,23))

#RATE OF ASCENT OF THE LABOR FORCE CURVE
labparam4tries<-array(runif(TRIES,.1,.5))
###############

###############
##STEP 5 INPUTS
#MIN AND MAX OF RETIREMENT AGES TO FIT OVER
retmin<-50
retmax<-75

#HEIGHT OF RETIREMENT CURVE
#TO APPROXIMATELY EXCLUDE RETIREMENT CURVE FROM MODEL CAN SET LOW AS '0' AND HIGH AS '1e-10'
retparam1tries<-array(runif(TRIES,.0,.01)) #retparam1tries<-array(runif(ITER,0,1e-10))

#RATE OF DESCENT OF RETIREMENT CURVE
#TO APPROXIMATELY EXCLUDE RETIREMENT CURVE FROM MODEL CAN SET LOW AS '0' AND HIGH AS '1e-10'
retparam2tries<-array(runif(TRIES,2.5,10)) #retparam2tries<-array(runif(ITER,0,1e-10))

#POSITION OF THE RETIREMENT CURVE ON THE AGE-AXIS
#TO APPROXIMATELY EXCLUDE RETIREMENT CURVE FROM MODEL CAN SET LOW AS '55' AND HIGH AS '55+1e-10'
retparam3tries<-array(runif(TRIES,55,65)) #retparam1tries<-array(runif(ITER,55,55+1e-10))
###############


##############################
##FIT TO THE DATA
##############################

##STEP 1 FIT - PROPORTIONAL TO SUM TO 1
step1<-array(,length(migprob))
for (i in 1:length(migprob)) {step1[i]<-migprob[i]/sum(migprob)}

##STEP 2 FIT - MAKE MEAN AGE AND SET LEVEL TERM BASED ON SELECTED NUMBER OF SMALLEST VALUES
step2<-array(,length(step1))
for (i in 1:length(step2)) {if(step1[i] != 0){step2[i]<-step1[i]}}
step2<-array(mean(sort(step2)[1:level]),length(step2))
ages<-c(0:(length(step1)-1))
meanages<-c(0+1:length(step1))

##STEP 3 FIT - SELECT BEST PERCENT PARAMETER VALUES OF TRIES BASED ON INPUT DISTRIBUTIONS, THEN REPEAT TRIES WITH THE UNIFORM BOUNDS OF BEST PERCENT AND SELECT BEST PARAMETER VALUES 
step3triesfit<-function(childparam1tries,childparam2tries){
step3tries<-array(step1-step2,dim=c(length(step1),TRIES))
for (i in 1:TRIES) {step3tries[1:SIZE,i]<-childparam1tries[i]*exp(-childparam2tries[i]*(meanages[]))}
childresidtries<-array(0,dim=c(length(step1),TRIES))
for (i in 1:TRIES) {for (j in 1:length(meanages)) {if((meanages[j]>=childmin)&(meanages[j]<=childmax)) {childresidtries[j,i]<-(step3tries[j,i]-(step1-step2)[j])^2}}}
sumchildresidtries<-array(,TRIES)
for (i in 1:TRIES) {sumchildresidtries[i]<-sum(childresidtries[,i])}
childparam1tries<-runif(TRIES,min(childparam1tries[match(head(sort(sumchildresidtries),TRIES*BEST),sumchildresidtries)]), max(childparam1tries[match(head(sort(sumchildresidtries),TRIES*BEST),sumchildresidtries)]))
childparam2tries<-runif(TRIES,min(childparam2tries[match(head(sort(sumchildresidtries),TRIES*BEST),sumchildresidtries)]), max(childparam2tries[match(head(sort(sumchildresidtries),TRIES*BEST),sumchildresidtries)]))
childparamtries<-data.frame(sumchildresidtries=sumchildresidtries,childparam1tries=childparam1tries,childparam2tries=childparam2tries)
return(c(step3tries,childparamtries))
}
step3repeatpass<-step3triesfit(childparam1tries,childparam2tries)
ITER<-0
while (abs(max(step3repeatpass$childparam1tries)-min(step3repeatpass$childparam1tries))>FITTO & 
abs(max(step3repeatpass$childparam2tries)-min(step3repeatpass$childparam2tries))>FITTO
)
{step3repeatpass<-step3triesfit(step3repeatpass$childparam1tries,step3repeatpass$childparam2tries)
ITER=ITER+1
}
step3repeatpass$childparam1tries[1]
step3repeatpass$childparam2tries[1]
step3repeatpass$sumchildresidtries[1]
step3best<-array(step1-step2,dim=c(length(step1)))
ITER
step3best[1:SIZE]<-step3repeatpass$childparam1tries[1]*exp(-step3repeatpass$childparam2tries[1]*(meanages[]))
step3<-step2+step3best

##STEP 4 FIT - SELECT BEST PERCENT PARAMETER VALUES OF TRIES BASED ON INPUT DISTRIBUTIONS, THEN REPEAT TRIES WITH THE UNIFORM BOUNDS OF BEST PERCENT UNTIL CONVERGENCE  
step4triesfit<-function(labparam1tries,labparam2tries,labparam3tries,labparam4tries){
step4tries<-array(step1-step2,dim=c(length(step1),TRIES))
for (i in 1:TRIES) {step4tries[1:SIZE,i]<-labparam1tries[i]*exp(-labparam2tries[i]*(meanages[]-labparam3tries[i])-exp(-labparam4tries[i]*(meanages[]-labparam3tries[i])))}
labresidtries<-array(0,dim=c(length(step1),TRIES))
for (i in 1:TRIES) {for (j in 1:length(meanages)) {if((meanages[j]>=labormin)&(meanages[j]<=labormax)&((meanages[j]<min(studentages))|(meanages[j]>max(studentages)))) {labresidtries[j,i]<-(step4tries[j,i]-(step1-step3)[j])^2}}}
sumlabresidtries<-array(,TRIES)
for (i in 1:TRIES) {sumlabresidtries[i]<-sum(labresidtries[,i])}
labparam1tries<-runif(TRIES,min(labparam1tries[match(head(sort(sumlabresidtries),TRIES*BEST),sumlabresidtries)]),max(labparam1tries[match(head(sort(sumlabresidtries),TRIES*BEST),sumlabresidtries)]))
labparam2tries<-runif(TRIES,min(labparam2tries[match(head(sort(sumlabresidtries),TRIES*BEST),sumlabresidtries)]),max(labparam2tries[match(head(sort(sumlabresidtries),TRIES*BEST),sumlabresidtries)]))
labparam3tries<-runif(TRIES,min(labparam3tries[match(head(sort(sumlabresidtries),TRIES*BEST),sumlabresidtries)]),max(labparam3tries[match(head(sort(sumlabresidtries),TRIES*BEST),sumlabresidtries)]))
labparam4tries<-runif(TRIES,min(labparam4tries[match(head(sort(sumlabresidtries),TRIES*BEST),sumlabresidtries)]),max(labparam4tries[match(head(sort(sumlabresidtries),TRIES*BEST),sumlabresidtries)]))
labparamtries<-data.frame(sumlabresidtries=sumlabresidtries,labparam1tries=labparam1tries,labparam2tries=labparam2tries,labparam3tries=labparam3tries,labparam4tries=labparam4tries)
return(c(step4tries,labparamtries))
}
step4repeatpass<-step4triesfit(labparam1tries,labparam2tries,labparam3tries,labparam4tries)
ITER<-0
while (abs(max(step4repeatpass$labparam1tries)-min(step4repeatpass$labparam1tries))>FITTO & 
abs(max(step4repeatpass$labparam2tries)-min(step4repeatpass$labparam2tries))>FITTO &
abs(max(step4repeatpass$labparam3tries)-min(step4repeatpass$labparam3tries))>FITTO &
abs(max(step4repeatpass$labparam4tries)-min(step4repeatpass$labparam4tries))>FITTO
)
{step4repeatpass<-step4triesfit(step4repeatpass$labparam1tries,step4repeatpass$labparam2tries,step4repeatpass$labparam3tries,step4repeatpass$labparam4tries)
ITER=ITER+1
}
step4repeatpass$labparam1tries[1]
step4repeatpass$labparam2tries[1]
step4repeatpass$labparam3tries[1]
step4repeatpass$labparam4tries[1]
step4repeatpass$sumlabresidtries[1]
ITER
step4best<-array(step1-step3,dim=c(length(step1)))
step4best[1:SIZE]<-step4repeatpass$labparam1tries[1]*exp(-step4repeatpass$labparam2tries[1]*(meanages[]-step4repeatpass$labparam3tries[1])-exp(-step4repeatpass$labparam4tries[1]*(meanages[]-step4repeatpass$labparam3tries[1])))
step4<-step3+step4best

##STEP 5 FIT - SELECT BEST PERCENT PARAMETER VALUES OF TRIES BASED ON INPUT DISTRIBUTIONS, THEN REPEAT TRIES WITH THE UNIFORM BOUNDS OF BEST PERCENT UNTIL CONVERGENCE   
step5triesfit<-function(retparam1tries,retparam2tries,retparam3tries){
step5tries<-array(step1-step2,dim=c(length(step1),TRIES))
for (i in 1:TRIES) {step5tries[1:SIZE,i]<-retparam1tries[i]*exp(-((meanages[]-retparam3tries[i])/retparam2tries[i])*((meanages[]-retparam3tries[i])/retparam2tries[i]))}
retresidtries<-array(0,dim=c(length(step1),TRIES))
for (i in 1:TRIES) {for (j in 1:length(meanages)) {if((meanages[j]>=retmin)&(meanages[j]<=retmax)&((meanages[j]<min(studentages))|(meanages[j]>max(studentages)))) {retresidtries[j,i]<-(step5tries[j,i]-(step1-step4)[j])^2}}}
sumretresidtries<-array(,TRIES)
for (i in 1:TRIES) {sumretresidtries[i]<-sum(retresidtries[,i])}
retparam1tries<-runif(TRIES,min(retparam1tries[match(head(sort(sumretresidtries),TRIES*BEST),sumretresidtries)]),max(retparam1tries[match(head(sort(sumretresidtries),TRIES*BEST),sumretresidtries)]))
retparam2tries<-runif(TRIES,min(retparam2tries[match(head(sort(sumretresidtries),TRIES*BEST),sumretresidtries)]),max(retparam2tries[match(head(sort(sumretresidtries),TRIES*BEST),sumretresidtries)]))
retparam3tries<-runif(TRIES,min(retparam3tries[match(head(sort(sumretresidtries),TRIES*BEST),sumretresidtries)]),max(retparam3tries[match(head(sort(sumretresidtries),TRIES*BEST),sumretresidtries)]))
retparamtries<-data.frame(sumretresidtries=sumretresidtries,retparam1tries=retparam1tries,retparam2tries=retparam2tries,retparam3tries=retparam3tries)
return(c(step5tries,retparamtries))
}
step5repeatpass<-step5triesfit(retparam1tries,retparam2tries,retparam3tries)
ITER<-0
while (abs(max(step5repeatpass$retparam1tries)-min(step5repeatpass$retparam1tries))>FITTO & 
abs(max(step5repeatpass$retparam2tries)-min(step5repeatpass$retparam2tries))>FITTO & 
abs(max(step5repeatpass$retparam3tries)-min(step5repeatpass$retparam3tries))>FITTO  
)
{step5repeatpass<-step5triesfit(step5repeatpass$retparam1tries,step5repeatpass$retparam2tries,step5repeatpass$retparam3tries)
ITER=ITER+1
}
step5repeatpass$retparam1tries[1]
step5repeatpass$retparam2tries[1]
step5repeatpass$retparam3tries[1]
step5repeatpass$sumretresidtries[1]
ITER
step5best<-array(step1-step4,dim=c(length(step1)))
step5best[1:SIZE]<-step5repeatpass$retparam1tries[1]*exp(-((meanages[]-step5repeatpass$retparam3tries[1])/step5repeatpass$retparam2tries[1])*((meanages[]-step5repeatpass$retparam3tries[1])/step5repeatpass$retparam2tries[1]))
step5<-step4+step5best

##REVIEW FIT
#SQUARED SUM OF RESIDUALS FOR ENTIRE MODEL
squaredsumoffullmodelresiduals<-sum((step5-step1)^2)


##############################
##PLOT THE DATA
##############################

##PLOT ACCUMULATED FIT
plot(step1,xlab="Age",ylab="Migration Rate (proportional)",ylim=c(-.005,.04),pch=1)
lines(step5,col="black",lwd=3)

##PLOT INDIVIDUAL STEP FITTING
lines(step5-step4,col="purple",lwd=2,lty=2)
lines(step4-step3,col="green",lwd=2,lty=2)
lines(step3-step2,col="blue",lwd=2,lty=2)
lines(step2,col="red",lwd=2,lty=2)

##PLOT RESIDUALS
lines(step5-step1,col="dark grey")

legend(55,.04, 
legend=c("Scaled data", "Full model curve", "Level", "Childhood curve", "Labor force curve", "Retirement curve", "Full model residuals"), 
col=c("black", "black", "red", "blue", "green", "purple", "grey"), 
lwd=c(1,2,2,2,2,2,1), lty=c(NA,1,2,2,2,2,1), pch=c(1,NA,NA,NA,NA,NA,NA), cex=0.8)

squaredsumoffullmodelresiduals


##############################
##WRITE THE DATA
##############################

#write.table(###, file="G:/###/###.csv", sep=",")

