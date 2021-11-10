* Importing the data
insheet using sports-and-education.csv,  names clear

* I label all the variables again
label variable academicquality 					"School Academic Quality"
label variable athleticquality 					"School Athletic Quality"
label variable nearbigmarket 					"Proximity to Metropolitan Area"
label variable ranked2017 						"Top Basketball Program Ranking"
label variable alumnidonations2018 				"Subsequent Year Alumni Donations"



** Making Balance Tables to compare both Ranked and Unranked schools **

global balanceopts  noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01)
estpost ttest academicquality athleticquality nearbigmarket, by(ranked2017) unequal welch
esttab using balancetables.rtf, cell("mu_1(f(3)) mu_2(f(3)) b(f(3) star)") wide label collabels("Control" "Treatment" "Difference") noobs $balanceopts mlabels(none) eqlabels(none) replace mgroups(none)

** As is evident from output, data is not balanced along tested covariates in the two groups (ranked and unranked); Hence, we do Propensity Score Matching **

** First calculating the Propensity Score using a Logit Model **

logit ranked2017 academicquality athleticquality nearbigmarket 
predict propensity_score, pr


** Now, we make a histogram to compare the two groups (ranked and unranked) on the propensity score **

twoway (histogram propensity_score if ranked2017==1, start(0) width(0.1) color(blue%40)) (histogram propensity_score if ranked2017==0, start(0) width(0.1) color(green%30)), legend(order(1 "Ranked" 2 "Not Ranked" ))

** We drop observations with propensity score more than 0.8, as they have no likelihood of being in the unranked group **
drop if propensity_score>0.8

** Creating blocks - I create 2 blocks just to compare the results. One is more segregated while the other is at a broader value **
sort propensity_score
gen block = floor(_n/4)
gen block2 = floor(_n/10)

** Running regressions to test the effect of ranking on donations **
reg alumnidonations2018 ranked2017 academicquality athleticquality nearbigmarket  i.block
eststo regression1
quietly estadd local fdblock "4", replace


reg alumnidonations2018 ranked2017 academicquality athleticquality nearbigmarket  i.block2
eststo regression2
quietly estadd local fdblock "10", replace

global tableoptions "bf(%15.2gc) sfmt(%15.2gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) replace r2"
esttab regression1 regression2 using regoutput.rtf, $tableoptions drop (*.block *.block2) s(fdblock , label("Fixed Effects Block at Units of:")) 






    