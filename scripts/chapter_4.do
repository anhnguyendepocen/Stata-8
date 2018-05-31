/*********************************************************************
* Biostatistiques et analyse des données de santé avec Stata
* chapter_4.tex
* Stata 13
* Christophe Lalanne, Mounir Mesbah
*********************************************************************/

mhodds low smoke

xtile age4 = age, nq(4)
table low smoke age4

mhodds low smoke, by(age4)

_pctile age, n(4)
return list

label define agec 1 "14-19" 2 "20-23" 3 "24-26" 4 "27-45"
label values age4 agec
label define wght 0 "Normal weight" 1 "Low weight"
label values low wght
label define smoking 0 "Non smoker" 1 "Smoker"
label values smoke smoking
catplot low smoke, by(age4)

cc low smoke, by(age4)

cc low smoke, woolf

tabulate low smoke, col nofreq

display 40.54/25.22

cs low smoke

preserve
drop *
use "diagnos.dta"
list

tabulate Test Dis [fweight=N]

diagt Dis Test [fw=N], chi

restore

logistic low lwt

fitstat

logit low ui, nolog

display exp(_b[ui])

estat classification

quietly: logit low lwt
predict pr, p

predict lo, xb
predict lose, stdp
gen lolci = lo - 1.96*lose
gen louci = lo + 1.96*lose
twoway (scatter lo lwt, sort connect(l)) (line lolci louci lwt, sort pstyle(p3 p3)), ///
  xlabel(35(15)120)

logit low lwt i.race

quietly: margins, at(lwt=(40(10)110)) over(race)
marginsplot


preserve
contract low ui, freq(n)
egen tot = sum(n), by(ui)
list

blogit n tot ui if low == 1, or
restore

/*********************************************************************
* Applications
*********************************************************************/

clear all
input str1 traitement str3 infection N
list
tabulate traitement infection [fweight=N], chi
return list
display %10.9f r(p)
tabulate traitement infection [fweight=N], chi expected nofreq
input traitement infection N
label define tx 0 "Placebo" 1 "Traitement"
label values traitement tx
label define ouinon 0 "Non" 1 "Oui"
label values infection ouinon
cc infection traitement [fweight=N], woolf exact
input infection centre N
tabulate infection centre [fweight=N], chi
input tx inf cen N
label define txlab 0 "A" 1 "B"
label define inflab 0 "Non" 1 "Oui"
label values tx txlab
label values inf inflab
table tx inf [fw=N], by(cen)
cc tx inf [freq=N], by(cen)

import delimited "hdis.dat", delimiter(space, collapse) varnames(1)
label define bpress 1 "<117" 2 "117-126" 3 "127-136" 4 "137-146" 5 "147-156" ///
  6 "157-166" 7 "167-186" 8 ">186"
label values bpress bpress
collapse (sum) hdis (sum) total, by(bpress)
generate prop = hdis/total
list
graph dot (asis) prop, over(bpress)
recode bpress (1 = 111.5) (2 = 121.5) (3 = 131.5) (4 = 141.5) (5 = 151.5) ///
  (6 = 161.5) (7 = 171.5) (8 = 181.5)
blogit hdis total bpress

insheet using "cc_oesophage.csv", clear
label define yesno 0 "No" 1 "Yes"
label values cancer yesno
label define dose 0 "< 80g" 1 ">= 80g"
label values alcohol dose
list
egen ntot = sum(patients)
display ntot
drop ntot
tabulate cancer alcohol [fweight=patients], row
cc cancer alcohol [fweight=patients], woolf
prtesti 96 0.4800 109 0.1406
logistic cancer alcohol [freq=patients]
logit cancer alcohol [freq=patients]



