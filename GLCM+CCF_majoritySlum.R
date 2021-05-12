#This script reads the raster files, calculate GLCM and apply CCF.
library(raster)
setwd(".../LowResolution")
data_tif <- stack('Medellin.tif')
groundTruth_tif <- raster('Medellin_ground_truth.tif')
#data_tif <- stack('ElDaein.tif')
#groundTruth_tif <- raster('ElDaein_ground_truth.tif')
#data_tif <- stack('ElGeneina.tif')
#groundTruth_tif <- raster('ElGeneina_ground_truth.tif')
#data_tif <- stack('Makoko.tif')
#groundTruth_tif <- raster('Makoko_ground_truth.tif')
groundTruth <- as.data.frame(groundTruth_tif)
names(groundTruth) <- c("class")
#Checking NA values in the RasterLayer and groundTruth dataset
summary(data_tif)
sum(is.na(groundTruth))
#Separating bands to calculate GLCM
library(glcm)
start_time <- Sys.time()
bandBlueGLCM <- glcm(data_tif[[1]],n_grey = 32, window = c(19,19), shift=list(c(0,1),c(1,1),c(1,0),c(1,-1)),  statistics = c("second_moment","contrast","correlation","homogeneity","entropy","mean","variance"))
bandGreenGLCM <- glcm(data_tif[[2]],n_grey = 32,window = c(19,19), shift=list(c(0,1),c(1,1),c(1,0),c(1,-1)),  statistics = c("second_moment","contrast","correlation","homogeneity","entropy","mean","variance"))
bandRedGLCM <- glcm(data_tif[[3]],n_grey = 32, window = c(19,19), shift=list(c(0,1),c(1,1),c(1,0),c(1,-1)),  statistics = c("second_moment","contrast","correlation","homogeneity","entropy","mean","variance"))
bandNIRGLCM <- glcm(data_tif[[7]],n_grey = 32, window = c(19,19), shift=list(c(0,1),c(1,1),c(1,0),c(1,-1)),  statistics = c("second_moment","contrast","correlation","homogeneity","entropy","mean","variance"))
end_time <- Sys.time()
GLCM_time <- end_time - start_time
GLCM_time
#plot(bandGreenGLCM)
#plot(data_tif)
#plot(groundTruth_tif)
df_NIRGLCM <- data.frame(as.data.frame(bandNIRGLCM$glcm_second_moment),as.data.frame(bandNIRGLCM$glcm_contrast),as.data.frame(bandNIRGLCM$glcm_correlation),as.data.frame(bandNIRGLCM$glcm_homogeneity),as.data.frame(bandNIRGLCM$glcm_entropy),as.data.frame(bandNIRGLCM$glcm_mean),as.data.frame(bandNIRGLCM$glcm_variance))
df_BlueGLCM <- data.frame(as.data.frame(bandBlueGLCM$glcm_second_moment),as.data.frame(bandBlueGLCM$glcm_contrast),as.data.frame(bandBlueGLCM$glcm_correlation),as.data.frame(bandBlueGLCM$glcm_homogeneity),as.data.frame(bandBlueGLCM$glcm_entropy),as.data.frame(bandBlueGLCM$glcm_mean),as.data.frame(bandBlueGLCM$glcm_variance))
df_GreenGLCM <- data.frame(as.data.frame(bandGreenGLCM$glcm_second_moment),as.data.frame(bandGreenGLCM$glcm_contrast),as.data.frame(bandGreenGLCM$glcm_correlation),as.data.frame(bandGreenGLCM$glcm_homogeneity),as.data.frame(bandGreenGLCM$glcm_entropy),as.data.frame(bandGreenGLCM$glcm_mean),as.data.frame(bandGreenGLCM$glcm_variance))
df_RedGLCM <- data.frame(as.data.frame(bandRedGLCM$glcm_second_moment),as.data.frame(bandRedGLCM$glcm_contrast),as.data.frame(bandRedGLCM$glcm_correlation),as.data.frame(bandRedGLCM$glcm_homogeneity),as.data.frame(bandRedGLCM$glcm_entropy),as.data.frame(bandRedGLCM$glcm_mean),as.data.frame(bandRedGLCM$glcm_variance))
df_GLCM <- data.frame(df_NIRGLCM,df_BlueGLCM,df_GreenGLCM,df_RedGLCM,groundTruth)
rm(df_BlueGLCM,df_GreenGLCM,df_RedGLCM,df_NIRGLCM)
rm(bandBlueGLCM,bandGreenGLCM,bandRedGLCM,bandNIRGLCM)
library(tidyr)
df_GLCM_complete <- df_GLCM %>% drop_na()
#Checking imbalance
table(df_GLCM_complete$class)
slum_GLCM <- df_GLCM_complete[df_GLCM_complete$class == 1,]
nonslum_GLCM <- df_GLCM_complete[df_GLCM_complete$class == 0,]
library(dplyr)
set.seed(0)
BalancedSlums <- sample_n(slum_GLCM, nrow(nonslum_GLCM))
floor <- round(0.8*nrow(BalancedSlums))
set.seed(0)
rows <- sample(nrow(BalancedSlums),floor,replace = FALSE)
trainSlum <- BalancedSlums[rows,]
testSlum <- BalancedSlums[-rows,]
trainNonSlum <- nonslum_GLCM[rows,]
testNonSlum <- nonslum_GLCM[-rows,]
#Scaling the training set
X_train80 <- rbind(trainSlum,trainNonSlum)
X_train80NotScaled <- X_train80[,1:28]
StDev <- apply(X_train80NotScaled, 2, sd)
Mean <- apply(X_train80NotScaled, 2, mean)
X_train80Centered <- sweep(X_train80NotScaled, 2, Mean, "-")
X_train80Scaled <- sweep(X_train80Centered, 2, StDev, "/")
#Scaling the test set
X_test20 <- rbind(testSlum,testNonSlum)
X_test20NotScaled <- X_test20[,1:28]
X_test20Centered <- sweep(X_test20NotScaled, 2, Mean, "-")
X_test20Scaled <- sweep(X_test20Centered, 2, StDev, "/")
rm(X_test20Centered,X_train80Centered,X_test20NotScaled,X_train80NotScaled)
rm(trainSlum,trainNonSlum,testSlum,testNonSlum)
#Preparing dataset for Canonical Correlation Forest
y_train80Class <- as.integer(X_train80[,29]+1)
X_train80Scaled[,29] <- y_train80Class
y_test20Class <- as.integer(X_test20[,29]+1)
X_test20Scaled[,29] <- y_test20Class
rm(y_train80Class, X_test20, X_train80)
#Shuffling the dataset
set.seed(0)
rows2 <- sample(nrow(X_train80Scaled), replace = FALSE)
X_train80Scaled <- X_train80Scaled[rows2, ]
#Applying Canonical Correlation Forest
#install.packages("devtools")
#devtools::install_github("jandob/ccf", force=TRUE)
library(ccf)
start_time <- Sys.time()
modelCCF <- canonical_correlation_forest(X_train80Scaled[,1:28], X_train80Scaled[,29], ntree = 10)
end_time <- Sys.time()
get_missclassification_rate(model = modelCCF, data_test = X_test20Scaled)
#Prediction
prediction <- predict(modelCCF, X_test20Scaled[,1:28])
results <- data.frame(X_test20Scaled[,29],prediction)
names(results) <- c("class","prediction")
confusionmatrix <- table(results$class,results$prediction)
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