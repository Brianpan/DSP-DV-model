library(e1071)

train_data <- read.csv("/Users/brianpan/Desktop/data/new_output600.csv")
# train_data <- na.omit(train_data)

# 做資料轉換


# count_reg <- glm(Count_plus ~ . - Count - 高危機.死亡 - ACTIONID - 施暴武器說明 - district - lat - lng, data=train_data)
# step_result <- step(count_reg, direction="backward")

# Count_plus ~ X + TIPVDA + X3 + X7 + X8 + X9 + 家暴因素.子女教養問題 + 
#     家暴因素.照顧壓力 + 家暴因素.疑似或罹患精神疾病 + 
#     家暴因素.經濟狀況不佳 + 家暴因素.親屬間相處問題 + 
#     家暴因素.酗酒 + 暴力型態.精神暴力 + 暴力型態.經濟暴力 + 
#     暴力型態.肢體暴力 + 受暴持續總月數 + 求助時間差.小時 + 
#     OCCUPATION + EDUCATION + town
# svm train
train_data <- transform(train_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
train_data <- transform(train_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))
x <- subset(train_data, select=c(家暴因素.照顧壓力, 家暴因素.子女教養問題, 暴力型態.肢體暴力, 家暴因素.酗酒, 家暴因素.個性.生活習慣不合, 家暴因素.疑似或罹患精神疾病,MAIMED,OCCUPATION.無工作,OCCUPATION.不詳,EDUCATION, TIPVDA, X1.4.5.6))
y <- train_data$Count_plus

dataset <- subset(train_data, select=c(Count_plus, 家暴因素.照顧壓力, 家暴因素.子女教養問題, 暴力型態.肢體暴力, 家暴因素.酗酒, 家暴因素.個性.生活習慣不合, 家暴因素.疑似或罹患精神疾病,MAIMED,OCCUPATION.無工作,OCCUPATION.不詳,EDUCATION, TIPVDA, X1.4.5.6))

# tune svm
svm_tune <- tune(svm, train.x=x, train.y=factor(y), kernel="radial", ranges=list(cost=10^(-1:2), gamma=c(0.5,1,2)))
print(svm_tune)

svm_model_after_tune <- svm(factor(Count_plus)~., kernel="radial", cost=10, gamma=2, data=dataset)
summary(svm_model_after_tune)

pred_tune <- predict(svm_model_after_tune, x)
table(pred_tune, y)

# test set
target_file <- "/Users/brianpan/Desktop/data/train.csv"
data_list <- read.csv(target_file)
data_list <- transform(data_list, OCCUPATION.無工作=(OCCUPATION=="無工作"))
data_list <- transform(data_list, OCCUPATION.不詳=(OCCUPATION=="不詳"))

data_list$Count.處遇中 <- ifelse(data_list$Count.處遇中>2, 3, ifelse(data_list$Count.處遇中==2,2, ifelse(data_list$Count.處遇中==1,1,NA)))
names(data_list)[2] = "Count_plus"

testdata <- subset(data_list, select=c(Count_plus, 家暴因素.照顧壓力, 家暴因素.子女教養問題, 暴力型態.肢體暴力, 家暴因素.酗酒, 家暴因素.個性.生活習慣不合, 家暴因素.疑似或罹患精神疾病,MAIMED,OCCUPATION.無工作,OCCUPATION.不詳,EDUCATION, TIPVDA, X1.4.5.6))
testset <-testdata[sample(nrow(testdata), 500),]

test_y <- testset$Count_plus
test_x <- subset(testset, select=-Count_plus)
pred_tune <- predict(svm_model_after_tune, test_x)
table(pred_tune, test_y)