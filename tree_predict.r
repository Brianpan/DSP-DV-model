calc_table <- function(test_data, model){
	cats_Class <- test_data$group
	total <- dim(test_data)[1]
	prob_matrix <- predict(model, test_data)
	cats_pred_Class <- apply( prob_matrix, 1, function(row) return(colnames(prob_matrix)[which(row == max(row))]) )

	rtable <- table(cats_pred_Class,cats_Class)
	rrate <- sum(diag(rtable))/total
	
	return(rtable)
}

# CART predictors
# References: https://c3h3notes.wordpress.com/2010/10/22/r%E4%B8%8A%E7%9A%84cart-package-rpart/
# https://topepo.github.io/caret/recursive-feature-elimination.html#helper-functions
library(rpart)
library(randomForest)
library(mlr)
library(dplyr)

par(family="LiHei Pro")
train_data <- read.csv("/Users/brianpan/Desktop/data/sample.csv")
train_data <- na.omit(train_data)
train_data <- transform(train_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
train_data <- transform(train_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))
train_data$EDUCATION <- factor(train_data$EDUCATION)
train_data$MAIMED <- factor(train_data$MAIMED)
# train_data$被害人婚姻狀態 <- factor(train_data$被害人婚姻狀態)



target_file <- "/Users/brianpan/Desktop/data/train2.csv"
test_data <- read.csv(target_file)
test_data <- transform(test_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
test_data <- transform(test_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))
test_data <- transform(test_data, group=( ifelse(Count > 2, 2, 1) ) ) 
test_data$EDUCATION <- factor(test_data$EDUCATION)
test_data$MAIMED <- factor(test_data$MAIMED)
# test_data$被害人婚姻狀態 <- factor(test_data$被害人婚姻狀態)
tt <- test_data
test_data <- subset(test_data, select=-c(district, town))

# model 
rf_rdata <- "/Users/brianpan/Desktop/data/rf_features.RData"
load(rf_rdata)
x <- subset(train_data, select=rf_predictors)
y <- subset(train_data, select=c(group))
# y <- subset(train_data, select=c(Count))
rf_train_data <- cbind(x,y)

# model_rf_10 <- rpart(group ~  ., data=rf_train_data)
rfmodel_rf_10 <- randomForest(group ~ ., data=rf_train_data)
rfrf_10_t_result <- table(train_data$group, round(predict(rfmodel_rf_10, train_data) ))


# model_rf_10 <- rpart(factor(Count) ~  ., data=rf_train_data)
# rfmodel_rf_10 <- randomForest(factor(Count) ~ ., data=rf_train_data)
# test
# rf_10_result <- calc_table(test_data, model_rf_10)

# rfrf_10_result <- table(test_data$group, predict(rfmodel_rf_10, test_data))
rfrf_10_result <- table(test_data$group, round(predict(rfmodel_rf_10, test_data) ))

# 輸出預測的平均 
district_file <- "/Users/brianpan/Desktop/data/district_rank.csv"
tt$predict <-predict(rfmodel_rf_10, test_data)
district_sheet <- tt %>% group_by(district) %>% summarise(avg_predict=mean(predict))
write.csv(district_sheet, district_file)

# 輸出沒風險被分為高風險的平均
test_data$predict<-predict(rfmodel_rf_10, test_data)

to_extract <-test_data[round(test_data$predict)==2 & test_data$group==1,]
to_extract <- subset(to_extract, select=c(ACTIONID, Count, predict, group, district, town) )
out<-data.frame(to_extract)
out_file <- "/Users/brianpan/Desktop/data/rf_numerical.csv"
write.csv(out, out_file)

reprtree:::plot.getTree(rfmodel_rf_10, k=6)