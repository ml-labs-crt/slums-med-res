#In this version the classifier is loaded with 1s and 2s. The dataset was shuffled.
#library(raster)
setwd(".../LowResolution")
#data_tif <- stack('Medellin.tif')
#groundTruth_tif <- raster('Medellin_ground_truth.tif')
#data_tif <- stack('ElDaein.tif')
#groundTruth_tif <- raster('ElDaein_ground_truth.tif')
#data_tif <- stack('ElGeneina.tif')
#groundTruth_tif <- raster('ElGeneina_ground_truth.tif')
data_tif <- stack('Mokako.tif')
groundTruth_tif <- raster('Mokako_ground_truth.tif')
groundTruth <- as.data.frame(groundTruth_tif)
df_complete <- data.frame(as.data.frame(data_tif[[1]]), as.data.frame(data_tif[[2]]),as.data.frame(data_tif[[3]]),as.data.frame(data_tif[[4]]), as.data.frame(data_tif[[5]]),as.data.frame(data_tif[[6]]),as.data.frame(data_tif[[7]]), as.data.frame(data_tif[[8]]), as.data.frame(data_tif[[9]]),as.data.frame(data_tif[[10]]))
names(groundTruth) <- c("ground_truth")
#Checking imbalance
table(groundTruth$ground_truth)
#datasetX_y_complete <- data.frame(df_complete,groundTruth)
#datasetX_y <- datasetX_y_complete %>% drop_na()
datasetX_y <- data.frame(df_complete,groundTruth)
names(datasetX_y) <- c("band1", "band2", "band3", "band4", "band5", "band6", "band7", "band8", "band9", "band10", "class")
slum <- datasetX_y[datasetX_y$class == 1,]
nonslum <- datasetX_y[datasetX_y$class == 0,]
#library(dplyr)
set.seed(0)
BalancedNonslums <- sample_n(nonslum, nrow(slum))
floor <- round(0.8*nrow(slum))
set.seed(0)
rows <- sample(nrow(slum),floor,replace = FALSE)
trainSlum <- slum[rows,]
testSlum <- slum[-rows,]
trainNonSlum <- BalancedNonslums[rows,]
testNonSlum <- BalancedNonslums[-rows,]
#Scaling the training set
X_train80 <- rbind(trainSlum,trainNonSlum)
X_train80NotScaled <- X_train80[,1:10]
StDev <- apply(X_train80NotScaled, 2, sd)
Mean <- apply(X_train80NotScaled, 2, mean)
X_train80Centered <- sweep(X_train80NotScaled, 2, Mean, "-")
X_train80Scaled <- sweep(X_train80Centered, 2, StDev, "/")
#Scaling the test set
X_test20 <- rbind(testSlum,testNonSlum)
X_test20NotScaled <- X_test20[,1:10]
X_test20Centered <- sweep(X_test20NotScaled, 2, Mean, "-")
X_test20Scaled <- sweep(X_test20Centered, 2, StDev, "/")
rm(X_test20Centered,X_train80Centered,X_test20NotScaled,X_train80NotScaled)
#Preparing dataset for Canonical Correlation Forest
y_train80Class <- as.integer(X_train80[,11]+1)
X_train80Scaled[,11] <- y_train80Class
names(X_train80Scaled)[11] <- "class"
y_test20Class <- as.integer(X_test20[,11]+1)
X_test20Scaled[,11] <- y_test20Class
names(X_test20Scaled)[11] <- "class"
#Shuffling the dataset
set.seed(0)
rows2 <- sample(nrow(X_train80Scaled), replace = FALSE)
X_train80Scaled <- X_train80Scaled[rows2, ]
#Applying Canonical Correlation Forest
#install.packages("devtools")
#devtools::install_github("jandob/ccf", force=TRUE)
library(ccf)
start_time <- Sys.time()
modelCCF <- canonical_correlation_forest(X_train80Scaled[,1:10], X_train80Scaled[,11], ntree = 10)
end_time <- Sys.time()
get_missclassification_rate(model = modelCCF, data_test = X_test20Scaled)
#Prediction
prediction <- predict(modelCCF, X_test20Scaled[,1:10])
results <- data.frame(y_test20Class,prediction)
#results <- data.frame(y_test20Class,prediction)
confusionmatrix <- table(results$y_test20Class,results$prediction)
confusionmatrix
#Calculating metrics
accuracySlums <- confusionmatrix[2,2]/sum(confusionmatrix[2,])
accuracyNonSlum <- confusionmatrix[1,1]/sum(confusionmatrix[1,])
IoUSlum <- confusionmatrix[2,2]/(confusionmatrix[2,2]+confusionmatrix[1,2]+confusionmatrix[2,1])
IoUNonSlum <- confusionmatrix[1,1]/(confusionmatrix[1,1]+confusionmatrix[1,2]+confusionmatrix[2,1])
MeanIoU <- (IoUSlum+IoUNonSlum)/2
ResultsSummary <- data.frame(accuracySlums,accuracyNonSlum,IoUSlum, IoUNonSlum, MeanIoU)
View(ResultsSummary)
CCF <- end_time - start_time
CCF