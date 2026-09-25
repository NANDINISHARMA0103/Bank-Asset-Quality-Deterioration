library(dplyr)
library(tidyr)
library(tidyverse)
library(janitor)
library(ggcorrplot)
library(gganimate)
library(gifski)
setwd("/Users/nandinisharma/Desktop/Dissertation/Dissertation Data csv")
df <- read.csv("Fixed Dataset-Table 1.csv") %>% clean_names()

str(df)
dim(df)
colnames(df)
summary(df)
levels(df$category)
table(df$category)

sum(is.na(df))
colSums(is.na(df))
sapply(df, class)

df$category <- as.factor(df$category)
df$deterioration_flag <- as.factor(df$deterioration_flag)
levels(df$Category)
table(df$Category)

mean(df$gnpa_ratio, na.rm = TRUE)
median(df$gnpa_ratio, na.rm = TRUE)
sd(df$gnpa_ratio, na.rm = TRUE)
var(df$gnpa_ratio, na.rm = TRUE)
range(df$gnpa_ratio, na.rm = TRUE)
IQR(df$gnpa_ratio, na.rm = TRUE)

aggregate(gnpa_ratio ~ category, data = df, FUN = mean)
aggregate(gnpa_ratio ~ category, data = df, FUN = sd)

#The current study is based on a secondary panel data set that contains the observations of 47 
#Indian public and private commercial banks for the period 2005–2025 (861 banks-years of observation) 
#collected primarily from the Reserve Bank of India (RBI), including the Database on Indian Economy 
#(DBIE), Statistical Tables Relating to Banks in India, RBI's Select Macro-Economic Aggregates, and 
#the Major Monetary Policy Rates publications.

#Basic Graph 1: Histogram- Distribution of GNPA Ratio
hist(df$gnpa_ratio, main = 
       "Distribution of GNPA Ratio", xlab = "GNPA Ratio (%)", col = "#a559aa")

#Interpretation: It is skewed to the right: most of the observations of the bank years are in 
# the lowest GNPA band (0-5%), with frequency gradually decreasing as GNPA increases, and a 
#small number of observations in the observeable range towards 30-40%. This indicates that the 
#banks had generally fairly good asset quality during the period examined, but a smaller group 
#of banks suffered from a high level of NPA stress, stretching the distribution to the right.


#Basic Graph 2: Boxplot — Credit Growth by Bank Category
boxplot(df$credit_growth ~ df$category,
        main = "Credit Growth by Bank Category",
        xlab = "Category", ylab = "Credit Growth (%)",
        col = c("#7B2CBF", "#C8B6FF"))

#Interpretation:The median credit growth of Private and Public sector banks is similar, 
#with Private sector banks having a higher number of high end outliers (beyond 100%), 
#than Public sector banks (with outliers remaining within ~90%). This could indicate that 
#in some years, or some banks more aggressive lending policies resulted in more credit expansion, 
#but this would need to be investigated by determining if these outliers were concentrated in 
#certain years or banks.

#Basic Graph 3: Barplot — Average ROA by Bank Category 
avg_roa <- aggregate(return_on_assets ~ category, data = df, FUN = mean)
barplot(avg_roa$return_on_assets, names.arg = avg_roa$category,
        main = "Average ROA by Category", ylab = "ROA (%)", col = "#702963")

#Interpretation: The private sector banks have visibly higher average Return on Assets than the 
#Public sector banks in this data set. One plausible reason for this, given the correlation plot's 
#finding that GNPA is strongly negatively associated with ROA (r=-0.78), is that Public banks have 
#a higher level of Non-Performing Assets, contributing to their relatively lower profitability: 
#This bar chart does not isolate NPA as the specific source of difference, though, since other 
#factors (such as cost structure, scale, and provisioning norms) could also differ between the 
#two categories.


df <- df %>% clean_names()
df$category <- as.factor(df$category)
df$deterioration_flag <- as.factor(df$deterioration_flag)

#Advanced Graph 1: Correlation plot
corr_df <- df %>%
  select(gnpa_ratio, credit_growth, return_on_assets,
         capital_adequacy_ratio, net_interest_income,
         repo_rate, real_gdp_growth_pct)
colnames(corr_df) <- c("GNPA Ratio", "Credit Growth", "ROA",
                       "CAR", "Net Interest Income",
                       "Repo Rate", "Real GDP Growth")
r <- cor(corr_df, use = "complete.obs")
ggcorrplot(r, type = "lower", lab = TRUE,
           title = "Correlation: Bank Health & Macro Variables",
           colors = c("#e2f0de", "#80ae9a", "#1b485e"))

#Interpretation- The GNPA Ratio has a strong negative correlation with Return on Assets (r = -0.78), 
#a moderate negative correlation with Credit Growth (r = -0.56) and a weak negative correlation 
#with Capital Adequacy Ratio (r = -0.25). Interestingly, its correlations with macroeconomic 
#variables are not high — Repo Rate (r = -0.29), Real GDP Growth (r = -0.12), Net Interest Income 
#(r = -0.01) — indicating that in this data, deterioration in asset quality is more closely linked 
#to financial indicators at the bank level than to macroeconomic conditions. Credit Growth and ROA 
#have moderate positive correlation (r = 0.55) and ROA and Capital Adequacy Ratio have also 
#moderate positive correlation (r = 0.46).

#Advanced Graph 2: Facet Density Plot
df <- df %>%
  mutate(gnpa_tier = cut(gnpa_ratio,
                         breaks = c(-Inf, 2, 5, 10, Inf),
                         labels = c("Low", "Moderate", "High", "Severe")))
ggplot(df, aes(x = credit_growth, fill = gnpa_tier)) +
  geom_density(alpha = 0.9, color = NA) +
  facet_wrap(~ gnpa_tier, scales = "free_y") +
  scale_fill_manual(values = c("Low" = "#440154",      # viridis purple
                               "Moderate" = "#3B528B",  # viridis blue
                               "High" = "#008080",      # teal
                               "Severe" = "#2E8B57")) + # sea green
  labs(title = "Credit Growth Distribution by GNPA Risk Tier", 
       x = "Credit Growth (%)", y = "Density") + theme_minimal(base_size = 13)+
  theme(
    strip.text = element_text(hjust = 0, face = "plain", size = 10),
    strip.background = element_blank(),
    legend.position = "none",
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
    panel.spacing = unit(1, "lines")
  )

ggsave("density_faceted_teal_seagreen.png", width = 10, height = 7, dpi = 300)

#Interpretation: The Low and Moderate risk levels represent relatively broad but high density peaks 
#clustered together within a narrow range of credit growth values, but the density peak for the 
#Severe level is much shallower and broader, covering most of the credit growth values as well as 
#negative growth values and values above 80%. This implies that the credit growth response across 
#banks is more heterogeneous and less predictable with respect to NPA stress than for lower risk 
#banks, but causality (erratic growth driving NPA stress or NPA stress driving erratic growth) can 
#be tested statistically with further testing.

#Animated Graph 1: GNPA trend line by category over years
avg_gnpa_year <- df %>%
  group_by(year, category) %>%
  summarise(gnpa_ratio = mean(gnpa_ratio, na.rm = TRUE), .groups = "drop")

p_line <- ggplot(avg_gnpa_year, aes(x = year, y = gnpa_ratio,
                                    color = category, group = category)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_color_manual(values = c("#594e90", "#bc4c96")) +
  labs(title = "Average GNPA Ratio Trend by Category",
       subtitle = "Year: {frame_along}",
       x = "Year", y = "GNPA Ratio (%)", color = "Category") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(face = "italic"),
        legend.position = "top") +
  transition_reveal(year) +
  shadow_mark(past = TRUE, future = FALSE, alpha = 0.3)

animate(p_line, renderer = gifski_renderer(), nframes = 150, fps = 10,
        width = 600, height = 500, end_pause = 20)
anim_save("gnpa_trend_by_category.gif")

#Interpretation: This visually illustrates that the Indian banks' public sector banking NPA 
#problems were not only bigger but had also reached the peak earlier than the private banks, 
#in this case, PSU banks' NPA was more than double the peak of private bank's NPA. It appears that 
#there was a lag time between the PSU peaking (2018) and the Private banking peaking (2020) that 
#may be attributed to the fact that the economy or asset quality assessment came under pressure on 
#the banking sector as a whole in the years that followed. The full recovery to pre-crisis levels by 
#2025 for both categories suggests the resolution measures (IBC, recapitalization, etc.) were 
#eventually effective across the sector.

#Animated Graph 2: Faceted Scatter: Credit Growth vs GNPA, by Category,over Years 
p_facet_anim <- ggplot(df, aes(x = credit_growth, y = gnpa_ratio, color = category)) +
  geom_point(alpha = 0.7, size = 3) +
  facet_wrap(~ category) +
  scale_color_manual(values = c("#1AC9E6", "#19AADE")) +
  labs(title = "Credit Growth vs GNPA Ratio by Category",
       subtitle = "Year: {frame_time}",
       x = "Credit Growth (%)", y = "GNPA Ratio (%)") +
  theme_bw(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5, face = "italic"),
  ) +
  transition_time(year) +
  ease_aes('linear')

animate(p_facet_anim, renderer = gifski_renderer(), 
        nframes = 150, fps = 10, width = 600, height = 500, end_pause = 20)
anim_save("animated_facet_scatter_bordered.gif")

#Interpretation: The faceted view is similar to what is seen on the line chart, but injects another 
#dimension to the credit growth story: the stressed period (mid-2010s) shows a pattern of low credit 
#growth and high GNPA from PS banks, which does not seem to be lending through the problem. 
#The collective private sector's credit growth was more or less normal, while a few individual 
#banks saw a rise in their GNPA, indicating that the private sector experienced a lower overall 
#level of asset quality stress during the same period.

#Normality Check
shapiro.test(df$delta_gnpa_ratio)
qqnorm(df$delta_gnpa_ratio)
qqline(df$delta_gnpa_ratio, col = "#f47a00")

#Interpretation:The Shapiro-Wilk test returned W = 0.775, p < 2.2e-16. However, p is very small, 
#and we reject the null hypothesis of normality, so this ratio is not normally distributed. 
#This is the reason why throughout this analysis non-parametric tests (Wilcoxon, Kruskal-Wallis, 
#Spearman correlation) were used instead of their parametric counterparts. 
#Variance Test – GNPA Ratio by Category.Variance Test – GNPA Ratio by Category.

#Homogeneity of Variance — Public vs Private (GNPA Ratio)
var.test(gnpa_ratio ~ category, data = df)

#Interpretation: F-test for equality of variances returned F = 0.491 (p = 4.73e-13), indicating the 
#variances of GNPA ratio differ significantly between Public and Private sector banks — its variance 
#is about half that of Public sector banks (ratio = 0.491, meaning Private banks' variance is roughly double). This indicates that the variances are not equal and in conjunction with the earlier established non-normality of the variables justifies the use of the Wilcoxon test (not the t-test with var.equal = TRUE) for comparing the two group.
#This is the Wilcoxon Test for GNPA Ratio by Category.This is Wilcoxon Test for GNPA Ratio by Category.

#Two-Group Comparison — Public vs Private
wilcox.test(gnpa_ratio ~ category, data = df)

#Interpretation:The Wilcoxon rank-sum test showed that there was statistically significant 
#difference between GNPA ratio of Public sector banks and Private sector banks (W = 63,751, 
#p = 3.67e-15). Our hypothesis being that the distributions are not equal, with p < 0.05, 
#we are rejecting the null hypothesis, which supports the results of the Heat map and trend-lines 
#that indicated that the Public sector banks have been under a significantly higher stress for NPAs 
#over the study period. Using the Wilcoxon test, credit growth by category is assessed.
#The Wilcoxon test is used to estimate credit growth by category.

wilcox.test(credit_growth ~ category, data = df)

#Interpretation:The Wilcoxon test also found a statistically significant difference in credit 
#growth between the two categories (W = 90,819, p = 0.0145). With p < 0.05, the difference in credit 
#growth by ownership category is significant, albeit not as dramatic as that for GNPA (p = 0.0145 vs. 
#p = 3.67e-15), which indicates that the difference in the lending behavior between Private and 
#Public banks is significant but much smaller than their difference in asset quality.

#Multi-Group Comparison — Credit Growth across GNPA Risk Tiers
# Parametric version
anova_result <- aov(credit_growth ~ gnpa_tier, data = df)
summary(anova_result)

#Interpretation:The difference in credit growth between the four GNPA risk tiers was highly 
#significant, with an F(3, 810) = 113.2, p < 2e-16 after one-way ANOVA. This parametric result 
#should be considered in conjunction with the non-parametric result below, however, since the 
#variables are already known to be abnormal for the dataset, this result should not be used in 
#isolation.This is a Kruskal-Wallis Test comparing Credit Growth by GNPA Risk Tier.
#This is a Kruskal-Wallis Test of Credit Growth by GNPA Risk Tier.

# Non-parametric version (since data isn't normal)
kruskal.test(credit_growth ~ gnpa_tier, data = df)

#Interpretation:The Kruskal-Wallis test also validates the ANOVA result by using a distribution-free 
#test for non-normal data: (χ² = 306.64, df = 3, p < 2.2e-16). Given the <0.05 p value, there is a 
#significant difference in credit growth between at least one pair of GNPA risk tiers. 
#The 0.001 chi squared is so extreme that this is clearly indicative of fundamentally different 
#credit growth behaviour in the banks with the highest stress levels (those in the Severe tier), 
#compared to the lower stress banks, and not just a statistical difference.

#Correlation Test — GNPA Ratio vs Credit Growth
cor.test(df$gnpa_ratio, df$credit_growth, method = "pearson")

#Interpretation:The Pearson correlation indicates there is a moderate to strong negative 
#relationship between the GNPA ratio and credit growth (r = -0.562, p well below 0.05), which is 
#statistically significant. This agrees with the earlier correlation finding and is confirmation 
#that the relationship is not due to chance for this sample of 814 observations. The third chart 
#shows the relationship between the GNPA ratio and credit growth.The third chart plots the 
#correlation between GNPA ratio and credit growth.

# Non-parametric alternative, since normality is violated
cor.test(df$gnpa_ratio, df$credit_growth, method = "spearman")

#Interpretation:As the data is not normally distributed, the Spearman correlation is the better and 
#more reliable estimate than the Pearson correlation and here ρ = -0.650, p < 2.2e-16. In particular, 
#the Spearman coefficient (-0.650) is stronger than the Pearson coefficient (-0.562), meaning that 
#the actual relationship between the two is better expressed as a monotonic (consistently negative-
#ranking) relationship than a linear one: banks with higher GNPA consistently have lower credit 
#growth, though the magnitude of the difference may vary.

#In all the tests carried out, the findings clearly show that there are significant differences in 
#terms of asset quality and lending activities between the Public and Private sector banks; and that 
#GNPA risk tier is closely related to credit growth variability. Initial results of non-normality in 
#the data (Shapiro-Wilk, p < 2.2e-16) led to the use of non-parametric results (Wilcoxon, 
#Kruskal-Wallis, Spearman) as the primary and more reliable results throughout this analysis, with 
#their parametric counterparts (t-test, ANOVA, Pearson) reported for comparison and for 
#methodological transparency.

#Shared Train/Test Split
library(rpart)
library(rpart.plot)
library(caret)
library(randomForest)
library(pROC)
library(AER)

model_df <- df %>%
  select(deterioration_flag, credit_growth, capital_adequacy_ratio,
         return_on_assets, repo_rate, real_gdp_growth_pct, category) %>%
  na.omit()
set.seed(123)
train_index <- createDataPartition(model_df$deterioration_flag, p = 0.75, list = FALSE)
train_data <- model_df[train_index, ]
test_data  <- model_df[-train_index, ]

#Decision Tree
tree_model <- rpart(deterioration_flag ~ credit_growth + capital_adequacy_ratio +
                      return_on_assets + repo_rate + real_gdp_growth_pct + category,
                    data = train_data, method = "class")
rpart.plot(tree_model, main = "Decision Tree — Predicting GNPA Deterioration",
           extra = 104, box.palette = "GnBu")
tree_pred <- predict(tree_model, newdata = test_data, type = "class")
confusionMatrix(tree_pred, test_data$deterioration_flag, positive = "1")
printcp(tree_model)

#Interpretation:The tree performed at 79.6% accuracy (vs. 70.2% baseline, p = 0.002) with 
#Capital Adequacy Ratio, Credit Growth, GDP Growth, Repo Rate and ROA as splitting variables, and 
#category was not included suggesting that no additional value is added when financial indicators 
#are included. Sensitivity was found to be small (42.1%) while specificity was found to be high 
#(95.5%), this was due to the class imbalance in this data (only 29.8% of the cases were deteriorations).

#Logistic Regression
log_model <- glm(deterioration_flag ~ credit_growth + capital_adequacy_ratio +
                   return_on_assets + repo_rate + real_gdp_growth_pct + category,
                 data = train_data, family = "binomial")
summary(log_model)
exp(coef(log_model))  # odds ratios
log_probs <- predict(log_model, newdata = test_data, type = "response")
log_pred  <- factor(ifelse(log_probs > 0.5, 1, 0), levels = levels(test_data$deterioration_flag))
confusionMatrix(log_pred, test_data$deterioration_flag, positive = "1")
roc_log <- roc(test_data$deterioration_flag, log_probs)
auc(roc_log)
plot(roc_log, main = "ROC Curve — Logistic Regression", col = "maroon")

#Interpretation:The significant non-GDP predictors included Credit Growth (p < 0.001), Capital 
#Adequacy Ratio (p < 0.001), ROA (p = 0.008) and Repo Rate (p < 0.001) but not category. The negative 
#effect of CRAR (OR = 0.802) is consistent with H2, which states that the greater the capital 
#buffers, the less the deterioration risk. Repo Rate's positive effect (OR = 1.436) supports H5. 
#But the two outcomes (OR = 0.934) and (OR = 1.605) were in the opposite direction for hypothesized 
#results (H1, H3) — both are important to note as unexpected results instead of being disregarded. 
#The model's AUC value was 0.765 while its sensitivity was low (31.6%).

#Random Forest 
set.seed(123)
rf_model <- randomForest(deterioration_flag ~ credit_growth + capital_adequacy_ratio +
                           return_on_assets + repo_rate + real_gdp_growth_pct + category,
                         data = train_data, ntree = 500, importance = TRUE)
print(rf_model)
rf_pred  <- predict(rf_model, newdata = test_data, type = "class")
rf_probs <- predict(rf_model, newdata = test_data, type = "prob")[, 2]
confusionMatrix(rf_pred, test_data$deterioration_flag, positive = "1")
roc_rf <- roc(test_data$deterioration_flag, rf_probs)
auc(roc_rf)
varImpPlot(rf_model, main = "Random Forest — Variable Importance")

# Compare all three models' ROC curves together
plot(roc_log, col = "#457B9D", main = "ROC Curve Comparison — Logistic vs Random Forest")
lines(roc_rf, col = "#9E2A2B")
legend("bottomright", legend = c("Logistic Regression", "Random Forest"),
       col = c("#457B9D", "#9E2A2B"), lwd = 2)

#Interpretation:The AUC of Random Forest was the highest of the three models (0.813) and it had an 
#accuracy of 78.5%, indicating that it was able to capture some non-linearities that were not 
#captured by the logistic model. It had the same problems as the other models in terms of class 
#sensitivity, with an OOB class error of only 11.1% for non-deteriorating banks, and 48.8% for 
#actual deteriorations. This is the same class-imbalance issue that was observed throughout.

#Tobit Model — GNPA Ratio (Left-Censored at 0)
tobit_df <- df %>%
  select(gnpa_ratio, credit_growth, capital_adequacy_ratio,
         return_on_assets, repo_rate, real_gdp_growth_pct, category) %>%
  na.omit()

tobit_model <- tobit(gnpa_ratio ~ credit_growth + capital_adequacy_ratio +
                       return_on_assets + repo_rate + real_gdp_growth_pct + category,
                     left = 0, data = tobit_df)

summary(tobit_model)

# Compare against a plain OLS on the same data, to show why Tobit matters
ols_model <- lm(gnpa_ratio ~ credit_growth + capital_adequacy_ratio +
                  return_on_assets + repo_rate + real_gdp_growth_pct + category,
                data = tobit_df)
summary(ols_model)
tobit_model
summary(tobit_model)

#Interpretation: A Tobit model (left-censored at 0%) was estimated, but since there were no 
#censored observations in the data, its coefficients were identical to those of the OLS regression, 
#thus confirming that censoring was not a problem (although it was correct to check for it). 
#ROA (-3.86), Credit Growth (-0.06), CRAR (0.15), and Repo Rate (-0.63) all had highly significant 
#coefficients (p < 0.001), and Public Sector Banks had a GNPA that was on average 0.85 points higher 
#(p < 0.001), which was in line with the results from the previous analysis. However, the sign of the 
#coefficients of CRAR and Repo Rate is different in this logistic model, which probably means that 
#the current level of GNPA and its changes in the future are influenced to some extent by different 
#factors.


