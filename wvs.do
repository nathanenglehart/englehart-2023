* Nathan Englehart (Spring, 2023)

clear all

set more off

* WVS dataset available for download here: https://www.worldvaluessurvey.org/WVSDocumentationWV7.jsp 
use "Z:\home\nath\wvs-7.dta"

* total respondents
count

drop if B_COUNTRY != 643

* total Russian respondents
count 

* control variables
gen female = 1
replace female = 0 if Q260 == 1
gen age = Q262
gen educ = Q275
gen ethnic_minority = 1
replace ethnic_minority = 0 if Q290 != 643001
gen ses = Q288R

* dependent variables
gen gov_satisfaction = Q71
recode gov_satisfaction 1=4 2=3 3=2 4=1

* key independent variables
gen homophobia = Q182
recode homophobia 1=10 2=9 3=8 4=7 5=6 6=5 7=4 8=3 9=2 10=1
gen homo_parents = Q36
gen bearing_children = Q37
recode bearing_children 1=4 2=3 3=2 4=1
gen beat_wife = Q189
gen women_rights = Q249
gen abortion = Q184
gen housewife_fufilling = Q32
recode housewife_fufilling 1=4 2=3 3=2 4=1
recode Q29 1=5 2=4 3=3 4=2 5=1
recode Q30 1=5 2=4 3=3 4=2 5=1
recode Q31 1=5 2=4 3=3 4=2 5=1
gen sexism = Q29 + Q30 + Q31
gen divorce = Q185

* dep vars if probit check desired (ur = united russia voter)
*gen ur = 1
*replace ur = 0 if Q223 != 643032
*gen confident = 1
*replace confident = 0 if gov_satisfaction == 1 | gov_satisfaction == 2

* other notable variables not used in this sequence:
*gen strong_leader = Q235
*gen dem_satisfaction = Q251
*gen elections_confidence = Q76
*recode elections_confidence 1=4 2=3 3=2 4=1
*gen religious_importance = Q6
*recode religious_importance 1=4 2=3 3=2 4=1
*gen womens_movement = Q80
*recode womens_movement 1=4 2=3 3=2 4=1
*gen orthodox = 1
*replace orthodox = 0 if Q289 != 3
*gen homo_neighbors = Q22
*recode homo_neighbors 2=0 1=1 
*gen unions = Q68
*recode unions 1=4 2=3 3=2 4=1

* controls
drop if female < 0
drop if age < 0
drop if educ < 0
drop if ses < 0

* minority non-response
drop if Q290 < 0 

* sex non-response
drop if Q260 < 0

* dep vars
drop if gov_satisfaction < 0

* global model specifications
local controls "i.female age educ i.ethnic_minority"
local dep_var "gov_satisfaction"

* color scheme for marginal effects plots and marginal probabilities plots
local me_color_opts "nodraw ylabel(-0.02(0.01)0.02) yline(0, lcolor(black)) plot1opts(color(red)) ciopt(color(red))"
local prob_color_opts "nodraw noci ylabel(0(0.1)0.5) plot1opts(color(red)) plot2opts(color(purple)) plot3opts(color(blue)) plot4opts(color(green))"

* Control model
eststo control: oprobit `dep_var' `controls' `conditions' if ses == 2, r

* LGBTQ+ model 
eststo p1: oprobit `dep_var' homophobia homo_parents `controls' if ses == 2 & homophobia > 0 & homo_parents > 0, r
eststo m1: margins, dydx(homophobia) post

* Women's rights model
eststo p2: oprobit `dep_var' sexism women_rights bearing_children abortion divorce beat_wife `controls' if ses == 2 & women_rights > 0 & Q29 > 0 & Q30 > 0 & Q31 > 0 & bearing_children > 0 & abortion > 0 & divorce > 0 & beat_wife > 0, r
eststo m2: margins, dydx(women_rights bearing_children) post

local key_indep = "homophobia homo_parents sexism women_rights bearing_children abortion divorce beat_wife"
local conditions = "if ses == 2 & homophobia > 0 & homo_parents > 0 & Q29 > 0 & Q30 > 0 & Q31 > 0 & women_rights > 0 & bearing_children > 0 & abortion > 0 & divorce > 0 & beat_wife > 0"

* Full model
eststo p3: oprobit `dep_var' `key_indep' `controls' `conditions', r
eststo m3: margins, dydx(homophobia women_rights bearing_children) post

* Marginal Probs for homophobia
quietly oprobit `dep_var' `key_indep' `controls' `conditions', r
margins, at(homophobia=(1(1)10)) post
marginsplot, name(grapha, replace) `prob_color_opts'

* Marginal Probs for women's rights
quietly oprobit `dep_var' `key_indep' `controls' `conditions', r
margins, at(women_rights=(1(1)10)) post
marginsplot, name(graphb, replace) `prob_color_opts'

* Marginal Probs for bearing_children
quietly oprobit `dep_var' `key_indep' `controls' `conditions', r
margins, at(bearing_children=(1(1)5)) post
marginsplot, name(graphc, replace) `prob_color_opts'

* Marginal Effects of Homophobia vs. women's rights vs. bearing_children .... (test later)
quietly oprobit `dep_var' `key_indep' `controls' `conditions', r
quietly margins, dydx(homophobia) post
est store homophobia_
quietly oprobit `dep_var' `key_indep' `controls' `conditions', r
quietly margins, dydx(women_rights) post
est store women_rights_ 
quietly oprobit `dep_var' `key_indep' `controls' `conditions', r
quietly margins, dydx(bearing_children) post
est store bearing_children_ 

* Cronbach's alpha for sexism index
alpha Q29 Q30 Q31 if Q29 > 0 & Q30 > 0 & Q31 > 0

* Correlation matrix of attitudes towards gender/sexuality (Table 2)
pwcorr sexism abortion beat_wife bearing_children women_rights homophobia homo_parents divorce, sig

* Regression table (Table 3)
esttab control p1 p2 p3, drop("0.*") eqlabels(none) pr2

* Regression table (latex)
esttab control p1 p2 p3 using "tab3.tex", drop("0.*") eqlabels(none) pr2

* Marginal Effects (Table 4)
esttab m1 m2 m3 

* Marginal Effects (latex)
esttab m1 m2 m3 using "tab4.tex"

* Marginal Effects (Fig 1)
coefplot homophobia_ women_rights_ bearing_children_, vertical xtitle("Conf. in Gov. (LO->HI)") ytitle("Marginal Effects") title("") yline(0, lcolor(black)) ciopts(recast(rcap)) recast(connected) coeflabels(1._predict = "1" 2._predict = "2" 3._predict = "3" 4._predict = "4") name(second, replace)

* Predicted Prob (Fig 2)
graph combine grapha graphb graphc, name(first)
