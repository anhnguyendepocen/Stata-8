/*********************************************************************
* Biostatistiques et analyse des données de santé avec Stata
* chapter_5.tex
* Stata 13
* Christophe Lalanne, Mounir Mesbah
*********************************************************************/

insheet using "lung.csv", clear
label define gender 1 "Male" 2 "Female"
label values sex gender

stset time, failure(status=2)

list time status age sex in 1/5

tabulate status, summarize(time)

sts list

sts list, at(200 300) enter

stci, dd(2) noshow

stci, p(10) dd(2)

stci, by(sex) noshow

sts graph

sts graph, noshow ci risktable censored(single)

sts graph, by(sex) legend(ring(0) position(2))

sts graph, noshow cumhaz ci

sts list, by(sex) compare noshow

sts test sex, noshow

sts test sex, wilcoxon noshow

stcox sex, noshow

stcox age, strata(sex) noshow

stcox sex, noshow nolog nohr

/*********************************************************************
* Applications
*********************************************************************/

insheet using "pbc.txt", tab
describe, simple
label define trt 1 "Placebo" 2 "DPCA"
label define sexe 0 "M" 1 "F"
label values rx trt
label values sex sexe
tabulate status
tabulate status rx, row
separate number, by(status)
twoway scatter number0 number1 years, msymbol(S O)
tabstat years, by(rx) stats(median) nototal
tabulate status if years > 10.49
tabulate sex if years > 10.49 & status == 1
preserve
egen idx = anymatch(number), values(5 105 111 120 125 158 183 /// 
  241 246 247 254 263 264 265 274 288 291 295 297 345 361 362 375 380 383)
keep if idx
gen days = years*365
tabstat age sex days, stats(mean median sum)
restore
stset years, failure(status)
sts list
sts graph, ci censored(single)
stci, by(rx)
sts graph, by(rx) cen(single)
sts test rx
sts test rx, wilcoxon noshow
egen agec = cut(age), at(26,40,55,79)
sts test rx, strata(agec) noshow
stcox rx, strata(agec)
stcox rx, strata(agec) nohr

insheet using "prostate.dat", delimiter(" ")
list in 1/5
tabulate status
stset time, failure(status)
stci, by(treatment) p(50)
sts graph, by(treatment) censored(s)
sts test treatment, noshow
stcox treatment, noshow


