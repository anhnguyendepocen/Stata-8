/*********************************************************************
* Biostatistiques et analyse des données de santé avec Stata
* chapter_1.tex
* Stata 13
* Christophe Lalanne, Mounir Mesbah
*********************************************************************/

set obs 10
generate x = rnormal(12, 2) 
format x %6.3f
summarize x, format

list x in 5
list x in 1/5

input x y

generate x2 = x / 1000
list x x2 in 1/3

replace x2 = log(x2)

replace x2 = 2600 in 3
list x x2 in 1/3

drop x2

list x in 1/3

list x if y <= 50

list in 1/5

list x if y < 55 & z == 1

count if y < 55 & z == 1

replace x = . in 3
summarize x

misstable summarize x

summarize y if !missing(x)

infile str5 nom age byte rep using "fichier.txt", clear

infile low age lwt race smoke ptl ht ui ftv bwt using "birthwt.dat", clear
list in 1/5

describe, short

describe low-lwt

infile byte low age lwt race smoke ptl ht ui ftv bwt using "birthwt.dat", clear

label variable low "Poids inférieur à 2,5 kg"
describe low-lwt race

tabulate race

label define yesno 0 "No" 1 "Yes"
label define ethn 1 "White" 2 "Black" 3 "Other"
label values ht ui yesno
label values race ethn

tabulate race

egen lwt3 = cut(lwt), at(70,120,170,220,270)
tabulate lwt3

drop lwt3
xtile lwt3 = lwt, nq(4)
tabulate lwt3

summarize bwt

ci bwt

histogram bwt, frequency

tabulate race, plot

tab1 race ht ui

ci low, binomial

gen freq = 1
graph bar (sum) freq, over(race) ytitle("Ethnicite")

by low, sort: summarize lwt

bysort low: summarize

tabstat lwt, by(low) stats(mean sd) format(%6.2f)

table low, contents(freq mean lwt sd lwt) format(%6.2f)

graph dot lwt, over(low)

graph dot (median) lwt, over(low)

drop maxbwt
quietly: summarize bwt if ui == 0
scalar maxbwt0 = r(max)
display maxbwt0

tabulate low smoke, row

/*********************************************************************
* Applications
*********************************************************************/

display log10(50)
count if X <= log10(50)
egen Xm = median(10^X) if X > log10(50)
display round(Xm)

infile using anorexia
describe
tabulate Group
replace Before = Before/2.2
replace After = After/2.2
generate diff = After - Before
summarize diff
tabstat diff, by(Group) stats(mean min max)

infile x using "saisie_x.txt"
tabstat x, stats(mean median)
egen xmode = mode(x), minmode
display xmode
egen varx = sd(x)
di varx^2
egen xc = cut(x), at(24.8,25.2,25.5,25.8,26.1) label
table xc, contents(min x max x)
tabulate xc, plot
histogram x, frequency

infile tailles using "elderly.dat", clear
count if tailles == .
ci tailles
histogram tailles, kdensity
