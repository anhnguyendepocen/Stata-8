/*********************************************************************
* Biostatistiques et analyse des données de santé avec Stata
* chapter_2.tex
* Stata 13
* Christophe Lalanne, Mounir Mesbah
*********************************************************************/

format lwt %4.1f
tabulate low, summarize(lwt)

histogram lwt, by(low)

graph box lwt, over(low, relabel(1 "Normal" 2 "Low (< 2.5 kg)")) /// 
  b1title("Baby weight") ytitle("Mother weight")

ttest lwt, by(low)

preserve
gen lwt1 = lwt if low == 0
gen lwt2 = lwt if low == 1

summarize lwt*

ttest lwt1 == lwt2, unpaired

sdtest lwt, by(low)

ttest x1 == x2

ranksum lwt, by(low)

signrank x1 = x2

tabulate low smoke, chi expected

tabi 86 44\ 29 30, chi2 exact nofreq

bitest smoke == 0.5, detail

prtest smoke == 0.5

prtest smoke, by(low)

replace freq = 1 // la variable existe déjà

graph bar (sum) freq, over(smoke, relabel(1 "Non smoking" 2 "Smoking")) ///
  asyvars over(low, relabel(1 "Normal" 2 "Low (< 2.5 kg)")) /// 
  legend(title("Mother")) ytitle("Counts")

ssc install catplot

catplot low smoke, recast(bar) /// 
  var1opts(relabel(1 "Normal" 2 "Low (< 2.5 kg)"))

tabodds low smoke, or

tabodds low smoke [fweight=N], or

input lowb smokeb N

list lowb-N in 1/4

tabulate lowb smokeb [fw=N]

label define status 0 "Normal weight" 1 "Low weight"
label define smoker 0 "Non smoker" 1 "Smoker"
label values lowb status
label values smokeb smoker
graph dot (asis) N, over(smokeb) asyvars over(lowb) /// 
  yscale(range(0 100)) ylabel(0(20)100) ///
  marker(1, msymbol(oh)) marker(2, msymbol(X))

histogram bwt, by(race, col(3)) freq

oneway bwt race, tabulate

robvar bwt, by(race)

oneway bwt race, bonferroni noanova

quietly: ttest bwt if race != 3, by(race)
display r(p)*3

recode ftv (0=0) (1=1) (2/6=2), gen(ftv2)

tabulate ftv2 ftv

regress bwt ftv2

quietly: regress bwt i.ftv2
contrast p.ftv2, noeffects

display e(r2)

anova bwt ftv2

regress bwt i.race

lincom 3.race - 2.race

ci bwt if race == 1

lincom _cons + 1.race

kwallis bwt, by(race)

anova bwt race##ht

anova bwt race ht race#ht

table race, by(ht) contents(mean bwt sd bwt count bwt)

table race ht, contents(mean bwt sd bwt count bwt)

quietly: margins race#ht
marginsplot

/*********************************************************************
* Applications
*********************************************************************/

input DHH LHH
list in 1/5
tabstat DHH LHH, save
return list
matrix m = r(StatTotal)
matrix list m
display m[1,2] - m[1,1]
gen sdif = LHH - DHH
tabstat sdif, stats(mean sd)
histogram sdif, percent bin(8) start(0)
ttest DHH == LHH
graph hbar DHH LHH, bargap(20)

tabi 26 21\ 38 44, exact chi2 expected
prtesti 64 0.233 65 0.237

use polymorphism.dta
by genotype: summarize age
by genotype: summarize age, detail
graph box age, over(genotype)
histogram age, by(genotype, col(3))
oneway age genotype
robvar age, by(genotype)
oneway age genotype, tabulate
display invttail(14-3, 0.025)
collapse (mean) agem=age (sd) ages=age (count) n=age, by(genotype)
generate agelci = agem - invttail(n-1, 0.025)*(ages/sqrt(n))
generate ageuci = agem + invttail(n-1, 0.025)*(ages/sqrt(n))
gen ageb = agem-agelci
serrbar agem ageb genotype, xlabel(1 "1.6/1.6" 2 "1.6/0.7" 3 "0.7/0.7")
regress age i.genotype
lincom 3.genotype - 2.genotype
lincom _cons + 1.genotype

use "weights.dta", clear
list in 1/5
tabulate PARITY
tabstat WEIGHT, stats(mean sd) by(PARITY) format(%9.2f)
oneway WEIGHT PARITY
anova WEIGHT PARITY
histogram WEIGHT, by(PARITY) freq
stripplot WEIGHT, over(PARITY) stack height(.4) center vertical width(.3)
scatter WEIGHT PARITY, jitter(3) xlabel(1 "Singleton" 2 "One sibling" 3 "2 siblings" 4 "3 more")
robvar WEIGHT, by(PARITY)
recode PARITY (1=1) (2=2) (3/4=3), gen(PARITY2)
tabulate PARITY PARITY2
oneway WEIGHT PARITY2
quietly: regress WEIGHT i.PARITY2
contrast p.PARITY2, noeffects
regress WEIGHT PARITY2


