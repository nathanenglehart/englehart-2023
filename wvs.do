clear all

set more off

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
gen bearing_children = Q37
recode bearing_children 1=4 2=3 3=2 4=1
gen beat_wife = Q189
gen women_rights = Q249
gen abortion = Q184
gen housewife_fufilling = Q32
recode housewife_fufilling 1=4 2=3 3=2 4=1

* dep vars for probit robustness check
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
*gen homo_parents = Q36
*recode homo_parents 1=5 2=4 3=3 4=2 5=1  

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

* Justif. of homosexuality
eststo p1: oprobit `dep_var' homophobia `controls' if ses == 2 & homophobia > 0, r
eststo m1: margins, dydx(homophobia) post
marginsplot, ytitle("ME of Justif. of Homosex.") xtitle("Conf. in Gov. (LO->HI)") title("") name(graph1, replace) `me_color_opts' 

oprobit `dep_var' homophobia `controls' if homophobia > 0 & ses == 2, r
margins, at(homophobia=(1(1)10)) post
marginsplot, name(grapha, replace) `prob_color_opts'

* Women's rights model
eststo p2: oprobit `dep_var' women_rights `controls' if ses == 2 & women_rights > 0, r
eststo m2: margins, dydx(women_rights) post
marginsplot, ytitle("ME of Import. of Women's Rights") xtitle("Conf. in Gov. (LO->HI)") title("") name(graph3, replace) `me_color_opts' 

oprobit `dep_var' women_rights `controls' if women_rights > 0 & ses == 2, r
margins, at(women_rights=(1(1)10)) post
marginsplot, name(graphb, replace) `prob_color_opts'

* Importance of bearing children model
eststo p3: oprobit `dep_var' bearing_children `controls' if ses == 2 & bearing_children > 0, r
eststo m3: margins, dydx(bearing_children) post
marginsplot, ytitle("ME of Import. of Children") xtitle("Conf. in Gov. (LO->HI)") title("") name(graph5, replace) `me_color_opts' 

oprobit `dep_var' bearing_children `controls' if bearing_children > 0 & ses == 2, r
margins, at(bearing_children=(1(1)5)) post
marginsplot, name(graphc, replace) `prob_color_opts'

* Justif. of beating wife model
eststo p4: oprobit `dep_var' beat_wife `controls' if ses == 2 & beat_wife > 0, r
eststo m4: margins, dydx(beat_wife) post
marginsplot, ytitle("ME of Justif. of Beating Wife") xtitle("Conf. in Gov. (LO->HI)") title("") name(graph6, replace) `me_color_opts' 

oprobit `dep_var' beat_wife `controls' if beat_wife > 0 & ses == 2, r
margins, at(beat_wife=(1(1)10)) post
marginsplot, name(graphd, replace) `prob_color_opts'

* Additional reference models
eststo control: oprobit `dep_var' `controls' if ses == 2, r
eststo ns1: oprobit `dep_var' abortion `controls' if abortion > 0 & ses == 2, r
eststo ns2: oprobit `dep_var' housewife_fufilling `controls' if housewife_fufilling > 0 & ses == 2, r

* Regression Tables
esttab control p1 p2 p3 ns1 ns2 p4, pr2 drop("0.*") eqlabels(none) 

* Regression Tables (latex)
*esttab control p1 p2 p3 ns1 ns2 p4 using "tab1.tex", pr2 drop("0.*") eqlabels(none) 

* ME Tables (not included in paper)
esttab m1 m2 m3 m4, pr2 eqlabels(none)

* ME Figures
graph combine graph1 graph3 graph5 graph6, name(first)

* Pred Probs Figures
graph combine grapha graphb, name(second)
graph combine graphc graphd, name(third)

