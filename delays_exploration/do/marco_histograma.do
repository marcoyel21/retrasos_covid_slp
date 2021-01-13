/*=========================================
Do file para realizar histograma

==============================================*/

*Agrego las etiquetas por región


import delimited 200908COVID19MEXICO.csv

merge m:1 entidad_res municipio_res using regionsanluis

drop _merge

/*=========================================


==============================================*/
gen dead=fecha_def!="9999-99-99"
keep if resultado==1
keep if dead==1
sort id_registro
merge 1:1 id_registro using reportdate_all.dta
drop if _merge==2


gen deaddate=date(fecha_def, "YMD")
gen retraso=reportdate-deaddate
replace retraso=0 if retraso<0

gen retraso_30=retraso
replace retraso_30=30 if retraso>30
label variable retraso_30 "Retraso en reporte"

/*=========================================
Realizo los histogramas

==============================================*/

*San Luis vs País
twoway (hist retraso_30 if reportdate>22025, percent discrete bcolor(red%30)) (hist retraso_30 if reportdate>22025 & (entidad_res==24), percent discrete bcolor(black%30)), ytitle(%) ylabel(0(10)30) legend(order(1 "País" 2 "SLP"))
graph save "slpvsmex.gph", replace


*Altiplano vs País
twoway (hist retraso_30 if reportdate>22025, percent discrete bcolor(red%30)) (hist retraso_30 if reportdate>22025 & (region==1), percent discrete bcolor(black%30)), ytitle(%) ylabel(0(10)30) legend(order(1 "País" 2 "Altiplano"))
graph save "altivsmex.gph", replace


*Zona centro vs País
twoway (hist retraso_30 if reportdate>22025, percent discrete bcolor(red%30)) (hist retraso_30 if reportdate>22025 & (region==2), percent discrete bcolor(black%30)), ytitle(%) ylabel(0(10)30) legend(order(1 "País" 2 "Centro"))
graph save "centrovsmex.gph", replace


*Zona media vs País
twoway (hist retraso_30 if reportdate>22025, percent discrete bcolor(red%30)) (hist retraso_30 if reportdate>22025 & (region==3), percent discrete bcolor(black%30)), ytitle(%) ylabel(0(10)30)  legend(order(1 "País" 2 "Media"))
graph save "mediavsmex.gph", replace


*Zona huasteca vs País
twoway (hist retraso_30 if reportdate>22025, percent discrete bcolor(red%30)) (hist retraso_30 if reportdate>22025 & (region==4), percent discrete bcolor(black%30)), ytitle(%) ylabel(0(10)30)  legend(order(1 "País" 2 "Huasteca"))
graph save "huastevsmex.gph", replace


graph combine "slpvsmex.gph" "altivsmex.gph" "centrovsmex.gph" "mediavsmex.gph" "huastevsmex.gph", plotregion(color(white))
graph export "region.png", as(png) replace



/*========================================
CALCULAR RETRASOS PROMEDIO POR 
region 
==========================================*/

preserve

collapse (mean) retraso retraso_30, by(region)
gen statemun=entidad_res*1000+municipio_res

keep statemun retraso retraso_30
sort statemun

save mean_delays_region, replace


restore



/*========================================
CALCULAR RETRASOS PROMEDIO POR 
MUNICIPIO
==========================================*/
preserve

collapse (mean) retraso retraso_30, by(entidad_res municipio_res)
gen statemun=entidad_res*1000+municipio_res

keep statemun retraso retraso_30
sort statemun

save mean_delays, replace


restore

/*=======================================
CALCULEN PARA CADA ESTADO
EL NÚMERO DE DECESOS POR FECHA
1. DE DEFUNCIÓN
2. DE REPORTE
EL CHISTE ES PODER COMPARAR LA
CURVA EPIDÉMICA DE SU ESTADO
CUANDO LA HACEMOS POR FECHA DE REPORTE
O POR FECHA DE DEFUNCIÓN
=========================================*/

*POR FECHA DE DEFUNCIÓN

preserve

*muertes
gen occ_deaths=1
*muertes en mi estado
gen occ_deaths_metro=(entidad_res==24)

collapse (sum) occ_deaths occ_deaths_metro, by(deaddate)

keep deaddate occ_deaths occ_deaths_metro

label variable occ_deaths "Decesos por fecha de ocurrencia (México)"
label variable occ_deaths_metro "Decesos por fecha de ocurrencia (SLP)"

rename deaddate date

sort date
save muertes_occuridas.dta, replace

restore


*POR FECHA DE REPORTE

preserve

*muertes
gen rep_deaths=1
*muertes en mi estado
gen rep_deaths_metro=(entidad_res==24)

collapse (sum) rep_deaths rep_deaths_metro, by(reportdate)

keep reportdate rep_deaths rep_deaths_metro

label variable rep_deaths "Decesos por fecha de reporte (México)"
label variable rep_deaths_metro "Decesos por fecha de reporte (SLP)"

rename reportdate date

sort date
save muertes_reportadas.dta, replace

restore





