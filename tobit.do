*tobit
use JTRAIN1, clear
log using tobit.txt, text replace
reg hrsemp lemploy i.union i.grant i.year, vce(robust)
tobit hrsemp lemploy i.union i.grant i.year, ll 
*below is the effect of a change in grants on:
margins, dydx(grant) predict(ystar(0,.)) // y (observed hours of training) including zeros or censored y 
margins, dydx(grant) //for latent index ystar  (desired hours of training)
margins, dydx(grant) predict(e(0,.)) //for left truncated mean y (actual hours of training)
*OLS although inconsistent is closer to y (observed values)
tobcm //reject the null hypothesis of normality in disturbances and conclude that tobit is inconsistent stick to the linear regression model. 
//linear regression model under normality the MLE
//remains consistent even if the errors are nonnormal, but the censored MLE becomes
//inconsistent if the errors are nonnormal 
gen s = (hrsemp !=0) if !missing(hrsemp)
heckman hrsemp lemploy i.union i.grant i.year, select(s = lemploy i.union i.year) twostep mills(mymills)
ttest mymills == 0 //reject null hypothesis, correlation exists
heckman hrsemp lemploy i.union grant i.year, select(s = lemploy union i.year)
log close




