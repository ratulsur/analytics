* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
* Identify Duplicate Cases.
SORT CASES BY age(A) ed(A) employ(A) address(A) income(A) debtinc(A) creddebt(A) othdebt(A) 
    default(A) preddef1(A) preddef2(A) preddef3(A).
MATCH FILES
  /FILE=*
  /BY age ed employ address income debtinc creddebt othdebt default preddef1 preddef2 preddef3
 /DROP = PrimaryLast  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryFirst InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryLast 'Indicator of each last matching case as Primary'.
VALUE LABELS  PrimaryLast 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryLast (ORDINAL).
FREQUENCIES VARIABLES=PrimaryLast.
EXECUTE.

SORT CASES BY income(A).



#SELECT CASES

DATASET ACTIVATE DataSet1.
DATASET COPY  loan_1.
DATASET ACTIVATE  loan_1.
FILTER OFF.
USE ALL.
SELECT IF (address > 3).
EXECUTE.
DATASET ACTIVATE  DataSet1.


#RECODE

RECODE employ (1=3) (2=2) (3=1) INTO employment_1.
VARIABLE LABELS  employment_1 'employment_1'.
EXECUTE.

COMPUTE

COMPUTE SUM_1=preddef1 + preddef2 + preddef3.
EXECUTE.


FILTER OFF.
USE ALL.
EXECUTE.



REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS BCOV R ANOVA COLLIN TOL CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT default
  /METHOD=ENTER employ income debtinc creddebt othdebt
  /RESIDUALS DURBIN.



REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS BCOV R ANOVA COLLIN TOL CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT default
  /METHOD=ENTER employ income debtinc creddebt othdebt
  /SCATTERPLOT=(default ,*ZPRED)
  /RESIDUALS DURBIN.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT PRE_1
  /METHOD=ENTER income debtinc creddebt othdebt
  /SCATTERPLOT=(PRE_1 ,*ZPRED).

LOGISTIC REGRESSION 
VARIABLES default
  /METHOD=ENTER income debtinc creddebt othdebt 
  /SAVE=PRED PGROUP COOK LEVER DFBETA RESID LRESID SRESID ZRESID DEV
  /CLASSPLOT
  /CASEWISE OUTLIER(2)
  /PRINT=GOODFIT CORR ITER(1) CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).







REGRESSION (HIERARCHICAL)
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT default
  /METHOD=ENTER address income debtinc creddebt othdebt
  /METHOD=ENTER employ address income debtinc creddebt othdebt.



FACTOR
  /VARIABLES employ address income debtinc creddebt othdebt default preddef1 preddef2 preddef3
  /MISSING LISTWISE 
  /ANALYSIS employ address income debtinc creddebt othdebt default preddef1 preddef2 preddef3
  /PRINT UNIVARIATE INITIAL CORRELATION SIG DET KMO INV REPR AIC EXTRACTION ROTATION
  /CRITERIA MINEIGEN(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /METHOD=CORRELATION.

RELIABILITY
  /VARIABLES=age ed employ address income debtinc creddebt othdebt default preddef1 preddef2 
    preddef3
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA.



*Multilayer Perceptron Network.
MLP default (MLEVEL=N) WITH employ income debtinc creddebt othdebt
 /RESCALE COVARIATE=STANDARDIZED 
  /PARTITION  TRAINING=7  TESTING=3  HOLDOUT=0
  /ARCHITECTURE   AUTOMATIC=NO HIDDENLAYERS=2 (NUMUNITS=AUTO) HIDDENFUNCTION=TANH 
    OUTPUTFUNCTION=IDENTITY 
  /CRITERIA TRAINING=BATCH OPTIMIZATION=SCALEDCONJUGATE LAMBDAINITIAL=0.0000005 
    SIGMAINITIAL=0.00005 INTERVALCENTER=0 INTERVALOFFSET=0.5 MEMSIZE=1000 
  /PRINT CPS NETWORKINFO SUMMARY CLASSIFICATION SOLUTION 
  /PLOT NETWORK ROC   
  /STOPPINGRULES ERRORSTEPS= 1 (DATA=AUTO) TRAININGTIMER=ON (MAXTIME=15) MAXEPOCHS=AUTO 
    ERRORCHANGE=1.0E-4 ERRORRATIO=0.001 
 /MISSING USERMISSING=EXCLUDE .


GET
  FILE='/Users/bart/Desktop/cars.sav'.
DATASET NAME CarsData WINDOW=FRONT.


GET
  FILE='/Users/bart/Desktop/cars.sav'.
DATASET NAME CarsData WINDOW=FRONT.



CLUSTER   mpg cyl disp hp wt qsec am gear carb
  /METHOD BAVERAGE
  /MEASURE=SEUCLID
  /ID=car
  /PRINT SCHEDULE
  /PLOT VICICLE.

* DENDROGRAM ONLY ****************************************************************

CLUSTER   mpg cyl disp hp wt qsec am gear carb
  /METHOD BAVERAGE
  /MEASURE=SEUCLID
  /ID=car
  /PLOT DENDROGRAM
  /PRINT NONE.

* SAVE CLUSTER MEMBERSHIP ********************************************************

* Use dendrogram to select the number of clusters to save.

CLUSTER   mpg cyl disp hp wt qsec am gear carb
  /METHOD BAVERAGE
  /MEASURE=SEUCLID
  /ID=car
  /PLOT NONE
  /PRINT NONE
  /SAVE CLUSTER(4)
  

