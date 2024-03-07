libname b "/home/u62564367/ADET/project1";

/* Importing the data */
FILENAME REFFILE '/home/u62564367/ADET/project1/Customer Churn.csv';
RUN;

options validvarname=v7;
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=b.customer_churn;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=b.customer_churn; 
RUN;


/* ----------------- DATA PREPROCESSING ------------------- */
/* Creating table */

data b.customer_churn;
	set b.customer_churn;
run;

/* Showing statistical summary */
proc means data=b.customer_churn;
run;

/* Checking missing values */
proc means data=b.customer_churn nmiss;
run;

/* Checking the proportion of target variable churn */
proc freq data=b.customer_churn;
  tables churn/ nocum;
run;

/* some of the variables do not have the appropriate format */
/* 
Call__Failure
Complains
Subscription__Length
Charge__Amount
Seconds_of_Use
Frequency_of_use
Frequency_of_SMS
Distinct_Called_Numbers
Age_Group
Tariff_Plan
Status
Age
Customer_Value
Churn
 */
/* Rename variables */
data b.customer_churn;
  set b.customer_churn(rename=(Call__Failure = Call_Failure Subscription__Length = Subscription_Length Charge__Amount = Charge_Amount ));
run;

/* Creating standard binary classification */ 
data b.customer_churn;
	set b.customer_churn;
	/*Changing the value of customer status from 1 = active, 2 = inactive to 1 = active and 0 =inactive */
	if status = 2 then status = 0;
	/*Cahnging the value of customer tariff_plan from 1 = pay as you go , 2 = contractual to 1 = pay as you go and 0 = contractual */
	if tariff_plan = 2 then tariff_plan = 0;
run;


/* ------------------ FEATURE ENGINEERING ----------------- */
data b.updated_customer_churn;
   set b.customer_churn;
   /* Usage Intensity Features */
   call_failure_rate = round(call_failure / frequency_of_use, 0.01);
   average_call_length = round(seconds_of_use / frequency_of_use, 0.01);
   average_monthly_usage_ratio = round(seconds_of_use / subscription_length, 0.01);
   average_monthly_charge = round(charge_amount / subscription_length, 0.001);
   text_to_call_ratio = round(frequency_of_sms / frequency_of_use, 0.01);
 
   /* Customer Interaction Features */
   average_calls_per_contact = round(frequency_of_use / distinct_called_numbers, 0.01);

 
   /* Loyalty and Satisfaction Features */

   charge_to_usage_ratio = round(charge_amount / seconds_of_use, 0.00001);

run;


