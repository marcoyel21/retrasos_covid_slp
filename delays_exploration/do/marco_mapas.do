
/*================================================
LLAMAMOS AL MAPA EN FORMATO STATA
==================================================*/
clear
use munsmex.dta, clear
cap drop _merge
destring CVEGEO, gen(statemun)
gen entidad_res=floor(statemun/1000)
sort statemun
merge 1:1 statemun using mean_delays.dta

keep if _merge==3
/*================================================
Agrego las regiones de SLP
==================================================*/
drop _merge
gen a = entidad_res*1000
gen municipio_res = statemun - a
merge 1:1 entidad_res municipio_res using regionsanluis
drop _merge


/*================================================
MAPA de municipios
==================================================*/

spmap retraso_30 using coordmuns, id(id) clmethod(custom) clbreaks(0 5 10 20 30) legtitle("Retrasos promedio") legend(size(vsmall)) legorder(lohi) legend(position(7)) osize(vthin vthin vthin vthin vthin vthin) title("Mexico")


spmap retraso_30 using coordmuns if (entidad_res==24), id(id) clmethod(custom) clbreaks (0 5 10 20 30)  legtitle("Retrasos promedio") legend(position(7)) osize(vthin vthin vthin vthin vthin vthin) 
graph save "delayspormmun.gph", replace




/*================================================
MAPA de regiones
==================================================*/
clear all
use munsmex.dta, clear

cap drop _merge
destring CVEGEO, gen(statemun)
gen entidad_res=floor(statemun/1000)
gen a = entidad_res*1000
gen municipio_res = statemun - a
merge 1:1 entidad_res municipio_res using regionsanluis
drop _merge

merge m:1 region using mean_delays_region


spmap retraso_30 using coordmuns if (entidad_res==24), id(id) clmethod(custom) clbreaks (5 6 7 8 9)  legtitle("Retrasos promedio") legend(position(7)) osize(vthin vthin vthin vthin vthin vthin) 
graph save "delaysporregion.gph", replace
/*================================================
Ambos mapas
==================================================*/

graph combine "delayspormmun.gph" "delaysporregion.gph", plotregion(color(white))
graph export "delaysmunvsregions.png", as(png) replace
