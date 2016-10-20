library('caret')

train_data <- read.csv("/Users/brianpan/Desktop/data/new_output600_noid.csv")
train_data <- na.omit(train_data)

train_data <- transform(train_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
train_data <- transform(train_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))

train_data_stepwise <- subset(train_data, select=-c(Count_plus, OCCUPATION, ACTIONID, 施暴武器說明, lng, lat, district))
train_data <- subset(train_data, select=-c(Count, OCCUPATION, ACTIONID, 施暴武器說明, lng, lat, district))

# lvq model feature selection
# 家暴因素.疑似或罹患精神疾病      0.029096
# town                             0.017736
# 暴力型態.精神暴力                0.016282
# 求助時間差.小時                  0.014684
# AGE                              0.012428
# 家暴因素.照顧壓力                0.012116
# X8                               0.011869
# 被害人婚姻狀態                   0.011020
# 家暴因素.性生活不協調            0.009189
# 暴力型態.經濟暴力                0.008844
# 家暴因素.施用毒品.禁藥或迷幻物品 0.008117
# 成人家庭暴力兩造關係             0.006351
# MAIMED                           0.005877
# 家暴因素.感情.外遇問題           0.004703
# X2                               0.004476
# X10                              0.004453
# X1                               0.004376
# 自殺行為                         0.004321
# 自殺意念                         0.003935
# X9                               0.003183

# control <- trainControl(method="repeatedcv", number=10, repeats=3)
# model <- train(factor(Count_plus) ~., data=train_data,
# 				method="lvq", preProcess="scale", trControl=control)

# importance <- varImp(model, scale=FALSE)

# print(importance)
# plot(importance)


# StepWise Backward
# http://www.ats.ucla.edu/stat/r/modules/factor_variables.htm
# AIC: log(likelihood) + 2*(estimators) 愈小愈好
# AIC referece : http://rightthewaygeek.blogspot.tw/2013/10/aic.html

#                               Df Deviance     AIC
# <none>                               75.59  988.36
# - X14                           1    75.92  988.53
# - OCCUPATION.不詳               1    75.95  988.73
# - X10                           1    75.97  988.84
# - X13                           1    76.03  989.24
# - X2                            1    76.11  989.74
# - MAIMED                        1    76.27  990.82
# - X1.4.5.6                      1    76.33  991.19
# - 家暴因素.照顧壓力             1    76.34  991.28
# - 高危機.死亡                   1    76.37  991.45
# - 自殺行為                      1    76.42  991.83
# - 受暴持續總月數                1    76.62  993.08
# - X3                            1    76.92  995.04
# - 使用武器                      1    77.25  997.17
# - 家暴因素.親屬間相處問題       1    77.45  998.47
# - X8                            1    78.64 1006.09
# - 求助時間差.小時               1    81.02 1020.95
# - 家暴因素.疑似或罹患精神疾病   1    81.13 1021.65
# - town                        238   532.55 1486.57

count_reg <- glm(Count ~ ., data=train_data_stepwise)
stepFeature <- step(count_reg, direction="backward")

# Random Forest Feature Selection
# Caret references: https://topepo.github.io/caret/recursive-feature-elimination.html
# 變數不可超過53個
#
# [1] "求助時間差.小時"                       "AGE"                                  
# [3] "受暴持續總月數"                        "被害人婚姻狀態"                       
# [5] "成人家庭暴力兩造關係"                  "暴力型態.精神暴力"                    
# [7] "EDUCATION"                             "TIPVDA"                               
# [9] "TIPVDA"                              "家暴因素.疑似或罹患精神疾病"

# x <- subset(train_data, select=-c(Count_plus, town))
# y <- subset(train_data, select=c(Count_plus))

# rfControl <- rfeControl(functions=rfFuncs, method="cv", number=10)
# RandomForestFeature <- rfe(x, factor(y[,1]), c(1:10), rfeControl=rfControl)
# predictors(RandomForestFeature)

# svm selection
# x <- subset(train_data, select=-c(Count_plus, town))
# y <- subset(train_data, select=c(Count_plus))

# svmFeatureSelection <- rfe(x, factor(y[, 1]), size=c(5, 10),
# 						   rfeControl= rfeControl(functions=caretFuncs, number=100),
# 						   method="svmRadial")
