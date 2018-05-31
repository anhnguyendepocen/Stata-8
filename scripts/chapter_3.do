/*********************************************************************
* Biostatistiques et analyse des données de santé avec Stata
* chapter_3.tex
* Stata 13
* Christophe Lalanne, Mounir Mesbah
*********************************************************************/

replace lwt = lwt/2.2
summarize bwt lwt

scatter bwt lwt
twoway (scatter bwt lwt) (lowess bwt lwt), legend(off) ytitle("bwt")

twoway scatter bwt lwt || lowess bwt lwt, legend(off) ytitle("bwt")

correlate lwt bwt

pwcorr lwt bwt, obs sig

corrci lwt bwt

spearman lwt bwt

regress bwt lwt

display _b[lwt]

regress bwt lwt, noheader coeflegend

display "Coefficient de détermination = " %3.2f e(r2)*100 " %"

twoway (scatter bwt lwt) (lfit bwt lwt)

predict double p, xb

predict sep, stdp
generate lci = p - 1.96*sep
generate uci = p + 1.96*sep

twoway (lfitci bwt lwt) (scatter bwt lwt)

estat ic

fitstat

predict double r, rstandard
predict double rr, residuals
predict double rrr, rstudent
format r-rrr %9.5f
summarize r-rrr, format

kdensity r

twoway (scatter r p) (lowess r p), yline(0, lcolor(black) lpattern(dash)) legend(off)

rvfplot, mlabel(smoke)

quietly: summarize lwt
generate lwts = lwt - r(mean)

generate lwts = (lwt - r(mean)) / r(sd)

egen lwts = std(lwt)

regress bwt lwts ftv i.race, noheader

/*********************************************************************
* Applications
*********************************************************************/

infile int (Sub Age Sex) Height Weight BMP FEV RV FRC ///
  TLC PEmax using "cystic.dat" in 2/26, clear
label define labsex 0 "M" 1 "F"
label values Sex labsex
tabulate Sex
correlate PEmax Weight
corrci PEmax Weight
pwcorr PEmax Weight, sig
graph matrix Age Height-PEmax
pwcorr Age Height-PEmax
spearman Age Height-PEmax, stats(rho)
pcorr PEmax Weight Age
xtile Age3 = Age, nq(3)
scatter PEmax Weight if Age3 != 2, mlab(Age3)
scatter PEmax Weight if Age3 == 1, msymbol(circle) || scatter PEmax ///
  Weight if Age3 == 3, msymbol(square) /// 
  legend(label(1 "1st tercile") label(2 "3rd tercile"))

insheet using "Framingham.csv"
describe, simple
list in 1/5
label define labsex 1 "M" 2 "F"
label values sex labsex
tabulate sex
misstable summarize
tabulate sex if bmi < .
scatter sbp bmi, by(sex) msymbol(Oh)
by sex, sort: correlate sbp bmi
gen logbmi = log(bmi)
gen logsbp = log(sbp)
histogram bmi, saving(gphbmi)
histogram logbmi, saving(gphlogbmi)
histogram sbp, saving(gphsbp)
histogram logsbp, saving(gphlogsbp)
graph combine gphbmi.gph gphlogbmi.gph gphsbp.gph gphlogsbp.gph
regress logsbp logbmi if sex == 1, noheader
regress logsbp logbmi if sex == 2, noheader

insheet using "quetelet.csv", delim(";") clear
describe
destring qtt, dpcomma replace
label define ltab 0 "NF" 1 "F"
label values tab ltab
list in 1/5
summarize pas-tab
corrci pas qtt, level(90)
regress pas qtt
matrix b = e(b)
svmat b
display "pente = " b1 ", ordonnée origine = " b2
twoway lfit pas qtt if tab == 0, range(2 5) lpattern(dot) || ///
  scatter pas qtt if tab == 0, msymbol(square) || ///
  lfit pas qtt if tab == 1, range(2 5) || ///
  scatter pas qtt if tab == 1, msymbol(circle) ///
  legend(label(1 "") label(2 "NF") label(3 "") label(4 "F"))
regress pas qtt if tab == 1


