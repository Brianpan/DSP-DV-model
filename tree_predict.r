# CART predictors
# References: https://c3h3notes.wordpress.com/2010/10/22/r%E4%B8%8A%E7%9A%84cart-package-rpart/
library("rpart")

train_data <- read.csv("/Users/brianpan/Desktop/data/new_output600_noid.csv")
train_data <- na.omit(train_data)
train_data <- transform(train_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
train_data <- transform(train_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))

target_file <- "/Users/brianpan/Desktop/data/train.csv"
test_data <- read.csv(target_file)
test_data <- transform(test_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
test_data <- transform(test_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))
test_data$Count <- ifelse(test_data$Count>2, 3, ifelse(test_data$Count==2,2, ifelse(test_data$Count==1,1,NA)))
names(test_data)[2] = "Count_plus"

# model 
formula_lvq <- factor(Count_plus) ~ 家暴因素.疑似或罹患精神疾病 + 暴力型態.精神暴力 + 求助時間差.小時 + AGE + 家暴因素.照顧壓力 + X8 + 被害人婚姻狀態 + 家暴因素.性生活不協調 + 暴力型態.經濟暴力 + 家暴因素.施用毒品.禁藥或迷幻物品
formula_stepwise <- factor(Count_plus) ~ X14 + OCCUPATION.不詳 + X10 + X13 + X2 + MAIMED + X1.4.5.6 + 家暴因素.照顧壓力 + 高危機.死亡 + 自殺行為
formula_rf_5 <- factor(Count_plus) ~ 求助時間差.小時 + AGE + 受暴持續總月數 + 被害人婚姻狀態 + 成人家庭暴力兩造關係
formula_rf_10 <- factor(Count_plus) ~ 求助時間差.小時 + AGE + 受暴持續總月數 + 被害人婚姻狀態 + 成人家庭暴力兩造關係 + 暴力型態.精神暴力 + EDUCATION + TIPVDA + TIPVDA + 家暴因素.疑似或罹患精神疾病

# train formula
model_lvq <- rpart(formula_lvq, data=train_data)
model_stepwise <- rpart(formula_stepwise, data=train_data)
model_rf_5 <- rpart(formula_rf_5, data=train_data)
model_rf_10 <- rpart(formula_rf_10, data=train_data)

cats_Class <- test_data$Count_plus
total <- dim(test_data)[1]

# test 
lvq_prob_matrix <- predict(model_lvq, test_data)

# 篩選最大預測機率得出來
lvq_cats_pred_Class <- apply( lvq_prob_matrix, 1, function(row) return(colnames(prob_matrix)[which(row == max(row))]) )


lvq_table <- table(lvq_cats_pred_Class,cats_Class)
lvq_rate <- sum(diag(lvq_table))/total

stepwise_prob_matrix <- predict(model_stepwise, test_data)
stepwise_cats_pred_Class <- apply( stepwise_prob_matrix, 1, function(row) return(colnames(prob_matrix)[which(row == max(row))]) )

stepwise_table <- table(stepwise_cats_pred_Class,cats_Class)

stepwise_prob_matrix <- predict(model_stepwise, test_data)
stepwise_cats_pred_Class <- apply( stepwise_prob_matrix, 1, function(row) return(colnames(prob_matrix)[which(row == max(row))]) )

stepwise_table <- table(stepwise_cats_pred_Class,cats_Class)
stepwise_rate <- sum(diag(stepwise_table))/total


rf_5_prob_matrix <- predict(model_rf_5, test_data)
rf_5_cats_pred_Class <- apply( rf_5_prob_matrix, 1, function(row) return(colnames(prob_matrix)[which(row == max(row))]) )

rf_5_table <- table(rf_5_cats_pred_Class,cats_Class)
rf_5_rate <- sum(diag(rf_5_table))/total


rf_10_prob_matrix <- predict(model_rf_10, test_data)
rf_10_cats_pred_Class <- apply( rf_10_prob_matrix, 1, function(row) return(colnames(prob_matrix)[which(row == max(row))]) )

rf_10_table <- table(rf_10_cats_pred_Class,cats_Class)
rf_10_rate <- sum(diag(rf_10_table))/total
