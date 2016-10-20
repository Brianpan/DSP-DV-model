dest_file <- "/Users/brianpan/Desktop/data/imputed_age_DVAS.csv"

setwd("/Users/brianpan/Desktop/data");
getwd();

library(mice);

to_clean <- read.csv("/Users/brianpan/Desktop/data/DVAS_before_impute.csv", header=T)

# 其餘依照johnson建議以cart完成
mice_method <- rep("cart", 55)
# age 用pmm 補值
imputed_data<-mice(to_clean, m=1, method=mice_method, maxit=15, seed=500)

completed_data <- complete(imputed_data, 1)
write.csv(completed_data, dest_file)
