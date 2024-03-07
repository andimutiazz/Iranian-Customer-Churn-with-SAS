libname b "/home/u62564367/ADET/project";

/* Importing the data */
FILENAME REFFILE '/home/u62564367/ADET/project/Iranian Customer Churn.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=b.customer_churn;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=customer_churn; RUN;

/* ----------------- DATA PREPROCESSING ------------------- */
/* Creating table */

data customer_churn;
	set b.customer_churn;
run;

/* Showing statistical summary */
proc means data=customer_churn;
run;

/* Checking missing values */
proc means data=customer_churn nmiss;
run;

/* Checking the proportion of target variable churn */
proc freq data=customer_churn;
  tables churn/ nocum;
run;

/* Cahnging the value of customer status from 1 = active, 2 = inactive to 1 = active and 0 =inactive */
data b.customer_churn;
	set b.customer_churn;
	if status = 2 then status = 0;
run;

/* ------------------ FEATURE ENGINEERING ----------------- */

data b.customer_churn;
   set b.customer_churn;
   /* Usage Intensity Features */
   call_failure_rate = round(call_failure / frequency_use, 0.01);
   average_call_length = round(seconds_of_use / frequency_use, 0.01);
   monthly_usage_ratio = round(seconds_of_use / subscription_length, 0.01);
   monthly_charge = round(charge_amount / subscription_length, 0.001);
   text_to_call_ratio = round(frequency_sms / frequency_use, 0.01);
 
   /* Customer Interaction Features */
   average_calls_per_contact = round(frequency_use / distinct_called_numbers, 0.01);
   SMS_per_Contact = round(frequency_sms / distinct_called_numbers, 0.01); /* (?) not all numbers are texted*/
 	
 
 
   /* Loyalty and Satisfaction Features */
   complaint_rate = round(complains / subscription_length, 0.0001);
   if seconds_of_use > 0 then do;
       charge_to_usage_ratio = round(charge_amount / seconds_of_use, 0.0001);
   end;
   else do;
       charge_to_usage_ratio = .; /* Handle division by zero if there are no seconds of use */
   end;
run;















