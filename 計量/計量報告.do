clear
capture log close

cd "C:\Users\user\Desktop\eco\STATA"
import delimited using Result03
log using 2021_6_1.log, replace

*資料處理
generate air = 1
replace air = 0 if centralair == "N"

generate exterqual_level = 5
replace exterqual_level = 4 if exterqual == "Gd"
replace exterqual_level = 3 if exterqual == "TA"
replace exterqual_level = 2 if exterqual == "Fa"
replace exterqual_level = 1 if exterqual == "Po"

generate extercond_level = 5
replace extercond_level = 4 if extercond == "Gd"
replace extercond_level = 3 if extercond  == "TA"
replace extercond_level = 2 if extercond  == "Fa"
replace extercond_level = 1 if extercond  == "Po"

generate kitchenqual_level = 5
replace kitchenqual_level = 4 if kitchenqual == "Gd"
replace kitchenqual_level = 3 if kitchenqual  == "TA"
replace kitchenqual_level = 2 if kitchenqual  == "Fa"
replace kitchenqual_level = 1 if kitchenqual  == "Po"

generate garagequal_level = 5
replace garagequal_level = 4 if garagequal == "Gd"
replace garagequal_level = 3 if garagequal == "TA"
replace garagequal_level = 2 if garagequal == "Fa"
replace garagequal_level = 1 if garagequal == "Po"
replace garagequal_level = 0 if garagequal == "NA"
*畫圖
twoway(scatter saleprice overallqual)
twoway(scatter saleprice exterqual_level)
twoway(scatter saleprice totalbsmtsf)
twoway(scatter saleprice grlivarea)
twoway(scatter saleprice garagearea)
twoway(scatter saleprice yearbuilt)





*品質
reg saleprice overallqual
reg saleprice overallqual exterqual_level kitchenqual_level garagequal_level
*等級評價
reg saleprice overallcond extercond_level
*廚房
reg saleprice kitchenabvgr
reg kitchenabvgr kitchenqual_level
*空調與壁爐
reg saleprice air
reg saleprice fireplaces
*廚房
reg saleprice kitchenabvgr
reg kitchenabvgr kitchenqual_level
*年代
reg saleprice yearbuilt
*空間大小
reg saleprice grlivarea
reg saleprice grlivarea if grlivarea<4500
reg saleprice totalbsmtsf
reg saleprice totalbsmtsf if totalbsmtsf<3000
reg saleprice grlivarea totalbsmtsf garagearea





*車庫
reg saleprice garagecars garagearea kitchenabvgr
gen yearbuilt2 = yearbuilt^2
gen air3 = air^3
reg saleprice garagecars garagearea kitchenabvgr kitchenabvgr2 kitchenabvgr3
test yearbuilt yearbuilt2
gen area = grlivarea*kitchenabvgr
gen kitchen_qual = kitchenabvgr*overallqual
gen airr = air*grlivarea
*全體 
reg saleprice overallqual exterqual_level totalbsmtsf air fireplaces grlivarea kitchenabvgr kitchenqual_level garagecars garagearea yearbuilt
reg saleprice overallqual exterqual_level totalbsmtsf air fireplaces grlivarea kitchenabvgr kitchenqual_level garagecars garagearea yearbuilt area kitchen_qual
rvfplot, recast(scatter)
reg saleprice overallqual exterqual_level totalbsmtsf air fireplaces grlivarea kitchenabvgr kitchenqual_level garagecars garagearea garagequal_level garagequal2 garagequal3 yearbuilt if totalbsmtsf<3000 & grlivarea<4500
rvfplot, recast(scatter)
reg saleprice air air2
*異質性
*1
reg saleprice overallqual exterqual_level totalbsmtsf air fireplaces grlivarea kitchenabvgr kitchenqual_level garagecars garagearea yearbuilt yearbuilt2

predict error1, res
predict yhat, xb
gen error11 = log(error1^2)

reg error11 overallqual exterqual_level totalbsmtsf air fireplaces grlivarea kitchenabvgr kitchenqual_level garagecars garagearea yearbuilt
predict ghat, xb
gen h = exp(ghat)

*2
gen error1sq = error1^2

gen yhatsq = yhat^2

reg error1sq yhat yhatsq

*predict h, xb

*3
gen cst=1
foreach v in saleprice overallqual exterqual_level totalbsmtsf air fireplaces grlivarea kitchenabvgr kitchenqual_level garagecars garagearea yearbuilt yearbuilt2 cst {
	gen `v'_w = `v'/sqrt(h)
}
gen yearbuilt2_w = yearbuilt2/sqrt(h)
reg saleprice_w overallqual_w exterqual_level_w totalbsmtsf_w air_w fireplaces_w grlivarea_w kitchenabvgr_w kitchenqual_level_w garagecars_w garagearea_w yearbuilt_w yearbuilt2_w,noconst

log close


reg saleprice overallqual overallcond bsmtfinsf1 bsmtfinsf2 bsmtunfsf fireplaces stflrsf ndflrsf garagecars garagearea air ExterQual_level extercond_level kitchenqual_level
