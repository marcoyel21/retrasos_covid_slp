clear

set obs 142
gen n=_n
gen date=n+22024
drop n

sort date

merge 1:1 date using muertes_ocurridas.dta
drop _merge

sort date
merge 1:1 date using muertes_reportadas.dta


for varlist occ* rep*: replace X=0 if X==.
	

format date %tdnn/dd/YY
twoway (bar occ_deaths date, bcolor(red%30)) (bar rep_deaths date, bcolor(black%30)) if date>22024, title(Panel A: México) xtitle(Fecha) ytitle(Decesos)  legend(off)
 graph export "curvapais.png", as(png) replace

twoway (bar occ_deaths_metro date, bcolor(red%30)) (bar rep_deaths_metro date, bcolor(black%30)) if date>22024, title(Panel B: San Luis Potosí) xtitle(Fecha) ytitle(Decesos) legend(order(1 "Por fecha de ocurrencia" 2 "Por fecha de reporte"))
 graph export "curvaslp.png", as(png) replace


graph combine "epicurve_tot.gph" "epicurve_metro.gph", plotregion(color(white))
graph export "curva.png", as(png) replace


