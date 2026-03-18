
# =========================================================
# Insurance Cross-Sell Analysis
# Author: Irem Akcan
# =========================================================

# ========================
# 1. Load Libraries
# ========================
library(dplyr)
library(ggplot2)
library(readr)
library(lme4)
library(corrplot)

# ========================
# 2. Load Dataset
# ========================
train <- read_csv("data/Health_Insurance_Cross_Sell_Train_Dataset.csv")

# ========================
# 3. Data Overview
# ========================
head(train)
str(train)
summary(train)

# ========================
# 4. Data Types
# ========================
train$Gender <- as.factor(train$Gender)
train$Vehicle_Age <- as.factor(train$Vehicle_Age)
train$Vehicle_Damage <- as.factor(train$Vehicle_Damage)

# ========================
# 5. Missing Values & Duplicates
# ========================
colSums(is.na(train))

duplicates_train <- train[duplicated(train), ]
nrow(duplicates_train)

# ========================
# 6. Statistical Tests
# ========================

# t-test
t.test(Annual_Premium ~ Response, data = train)

# F-test
var.test(Annual_Premium ~ Response, data = train)

# Chi-square test
chisq.test(table(train$Gender, train$Response))

# Wilcoxon test
wilcox.test(Annual_Premium ~ Response, data = train)

# ========================
# 7. ANOVA
# ========================
anova_result <- aov(Annual_Premium ~ Vehicle_Age, data = train)
summary(anova_result)

TukeyHSD(anova_result)

# ========================
# 8. Correlation Analysis
# ========================
numerical_columns <- train %>%
  select(Age, Driving_License, Region_Code,
         Previously_Insured, Annual_Premium,
         Policy_Sales_Channel, Vintage, Response)

correlation_matrix <- cor(numerical_columns)

corrplot(correlation_matrix, method = "color", type = "upper")

# ========================
# 9. Logistic Regression
# ========================
logistic_model <- glm(Response ~ Age + Annual_Premium +
                        Policy_Sales_Channel +
                        Previously_Insured + Vintage,
                      data = train,
                      family = binomial)

summary(logistic_model)

# ========================
# 10. Full Model + Reduction
# ========================
full_model <- glm(Response ~ Age + Annual_Premium +
                    Policy_Sales_Channel +
                    Previously_Insured + Vintage +
                    Gender + Vehicle_Age + Vehicle_Damage,
                  data = train,
                  family = binomial)

reduced_model <- step(full_model, direction = "backward")

summary(reduced_model)

# ========================
# 11. Visualization
# ========================

# Boxplot
ggplot(train, aes(x = Gender, y = Annual_Premium, fill = Gender)) +
  geom_boxplot()

# Histogram
ggplot(train, aes(x = Annual_Premium)) +
  geom_histogram(bins = 20, fill = "lightgreen")

# Scatter plot
ggplot(train, aes(x = Age, y = Annual_Premium)) +
  geom_point(alpha = 0.3)

# ========================
# 12. Mixed Effects Model
# ========================
mixed_model <- lmer(Annual_Premium ~ Age +
                      Policy_Sales_Channel +
                      Previously_Insured +
                      Gender + Vehicle_Age +
                      Vehicle_Damage +
                      (1 | Region_Code),
                    data = train)

summary(mixed_model)

# ========================
# 13. PCA
# ========================
train_numeric <- train %>% select(where(is.numeric))

pca_result <- prcomp(train_numeric, scale = TRUE)
summary(pca_result)

# ========================
# 14. Clustering (K-Means)
# ========================
train_scaled <- scale(train_numeric)

wss <- function(k) {
  kmeans(train_scaled, centers = k, nstart = 10)$tot.withinss
}

k.values <- 1:10
wss_values <- sapply(k.values, wss)

plot(k.values, wss_values, type = "b",
     xlab = "Number of clusters",
     ylab = "WSS")

