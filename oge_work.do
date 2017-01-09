clear
import delimited using drone_pricing.csv, varnames(1)
*keep noofrotors maxflighttimemin operatingrangem maxspeedms gpscompatible externalcameracompatible inbuiltcamera batterymah price
tostring noofrotors, gen(no_of_rotors)
encode no_of_rotors, gen(number_rotors)
foreach var of varlist gpscompatible-inbuiltcamera{
	encode `var', gen(nu_`var')
}
replace nu_externalcameracompatible = 1 if nu_externalcameracompatible == 3



*regress price noofrotors maxflighttimemin operatingrangem maxspeedms batterymah nu_gpscompatible nu_externalcameracompatible nu_inbuiltcamera, vce(robust)
*regress price noofrotors maxflighttimemin operatingrangem maxspeedms i.nu_externalcameracompatible, vce(robust)

misstable summarize //summarizes all the encoded data and provides the number missing values by variable
mi set mlong
mi misstable patterns 
mi register imputed maxflighttimemin operatingrangem maxspeedms batterymah 
mi register regular price number_rotors nu_gpscompatible
mi impute mvn maxflighttimemin operatingrangem maxspeedms batterymah = price number_rotors nu_gpscompatible, add(10) rseed(123) replace
mi estimate: regress price i.number_rotors maxflighttimemin operatingrangem maxspeedms batterymah ib2.nu_gpscompatible, vce(robust)








gen material_body = bodymaterial
replace material_body = "Plastic" if material_body == "plastic"
replace material_body = "other" if ((material_body != "Carbon Fiber") & (material_body != "Plastic"))
encode material_body, gen(b_material)

gen lnprice = ln(price)
regress lnprice i.number_rotors weightg maxspeedms ib2.nu_gpscompatible ib3.b_material operatingrangem, vce(robust)

regress lnprice i.number_rotors weightg ib2.nu_gpscompatible ib3.b_material operatingrangem, vce(robust)
