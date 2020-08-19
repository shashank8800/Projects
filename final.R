library(ggplot2) # Data visualization
library(readr) # CSV file I/O, e.g. the read_csv function
library(dplyr)
library(gganimate) #for animated gifs
library(ggthemes) 
library(RColorBrewer) 
library(tidyverse) # general
library(ggalt) # dumbbell plots
library(countrycode) # continent
library(rworldmap) # quick country-level heat maps
library(gridExtra) # plots
library(broom) # significant trends within countries

# 1) Import & data cleaning

data <- read_csv(file.choose()) 

# glimpse(data) # will tidy up these variable names

# sum(is.na(data$`HDI for year`)) # remove, > 2/3 missing, not useable

# table(data$age, data$generation) # don't like this variable

data <- data %>% 
  select(-c(`HDI for year`, `suicides/100k pop`)) %>%
  rename(gdp_for_year = `gdp_for_year ($)`, 
         gdp_per_capita = `gdp_per_capita ($)`, 
         country_year = `country-year`) %>%
  as.data.frame()



# 2) OTHER ISSUES

# a) this SHOULD give 12 rows for every county-year combination (6 age bands * 2 genders):

# data %>% 
#   group_by(country_year) %>%
#   count() %>%
#   filter(n != 12) # note: there appears to be an issue with 2016 data
# not only are there few countries with data, but those that do have data are incomplete

data <- data %>%
  filter(year != 2016) %>% # I therefore exclude 2016 data
  select(-country_year)

# b) excluding countries with <= 3 years of data:

minimum_years <- data %>%
  group_by(country) %>%
  summarize(rows = n(), 
            years = rows / 12) %>%
  arrange(years)

data <- data %>%
  filter(!(country %in% head(minimum_years$country, 7)))


# 3) TIDYING DATAFRAME
data$age <- gsub(" years", "", data$age)
data$sex <- ifelse(data$sex == "male", "Male", "Female")


# getting continent data:
data$continent <- countrycode(sourcevar = data[, "country"],
                              origin = "country.name",
                              destination = "continent")

# Nominal factors
data_nominal <- c('country', 'sex', 'continent')
data[data_nominal] <- lapply(data[data_nominal], function(x){factor(x)})

data$age <- factor(data$age, 
                   ordered = T, 
                   levels = c("5-14",
                              "15-24", 
                              "25-34", 
                              "35-54", 
                              "55-74", 
                              "75+"))

# Making generation ordinal
data$generation <- factor(data$generation, 
                          ordered = T, 
                          levels = c("G.I. Generation", 
                                     "Silent",
                                     "Boomers", 
                                     "Generation X", 
                                     "Millenials", 
                                     "Generation Z"))

data <- as_tibble(data)

# the global rate over the time period will be useful:

global_average <- (sum(as.numeric(data$suicides_no)) / sum(as.numeric(data$population))) * 100000


# view the finalized data
glimpse(data)

summary(data)
-------------------------------------------------------------------------------------------------------------------------
data %>%
  group_by(year) %>%
  summarize(population = sum(population), 
            suicides = sum(suicides_no), 
            suicides_per_100k = (suicides / population) * 100000) %>%
  ggplot(aes(x = year, y = suicides_per_100k)) + 
  geom_line(col = "deepskyblue", size = 1) + 
  geom_point(col = "deepskyblue", size = 2) + 
  geom_hline(yintercept = global_average, linetype = 2, color = "grey", size = 1) +
  labs(title = "Global Suicides (per 100k)",
       subtitle = "Time Period, 1985 - 2015.",
       x = "Year", 
       y = "Suicides per 100k") + 
  scale_x_continuous(breaks = seq(1985, 2015, 2)) + 
  scale_y_continuous(breaks = seq(10, 20))

  
  #Insights
  
  #Peak suicide rate was 15.3 deaths per 100k in 1995
#Decreased steadily, to 11.5 per 100k in 2015 (~25% decrease)
#Rates are only now returning to their pre-90's rates
#Limited data in the 1980's, so it's hard to say if rate then was truly representative of the global population
-------------------------------------------------------------------------------------------------------------------------
  
  country <- data %>%
  group_by(country) %>%
  summarize(suicide_per_100k = (sum(as.numeric(suicides_no)) / sum(as.numeric(population))) * 100000)

countrydata <- joinCountryData2Map(country, joinCode = "NAME", nameJoinColumn = "country")

par(mar=c(0, 0, 0, 0)) # margins

mapCountryData(countrydata, 
               nameColumnToPlot="suicide_per_100k", 
               mapTitle="", 
               colourPalette = "heat", 
               oceanCol="lightblue", 
               missingCountryCol="grey65", 
               catMethod = "pretty")  
----------------------------------------------------------------------------------------------------------------------------------  
data %>%
group_by(continent, sex) %>%
summarize(n = n(), 
            suicides = sum(as.numeric(suicides_no)), 
            population = sum(as.numeric(population)), 
            suicide_per_100k = (suicides / population) * 100000) %>%
ggplot(aes(x = continent, y = suicide_per_100k, fill = sex)) + 
geom_bar(stat = "identity", position = "dodge") + 
geom_hline(yintercept = global_average, linetype = 2, color = "grey35", size = 1) +
labs(title = "Gender Disparity, by Continent",
       x = "Continent", 
       y = "Suicides per 100k", 
       fill = "Sex") 
---------------------------------------------------------------------------------------------------------------------------------
  country_long <- data %>%
  group_by(country, continent) %>%
  summarize(suicide_per_100k = (sum(as.numeric(suicides_no)) / sum(as.numeric(population))) * 100000) %>%
  mutate(sex = "OVERALL")

### by country, continent, sex

sex_country_long <- data %>%
  group_by(country, continent, sex) %>%
  summarize(suicide_per_100k = (sum(as.numeric(suicides_no)) / sum(as.numeric(population))) * 100000)


sex_country_wide <- sex_country_long %>%
  spread(sex, suicide_per_100k) %>%
  arrange(Male - Female)


sex_country_wide$country <- factor(sex_country_wide$country, 
                                   ordered = T, 
                                   levels = sex_country_wide$country)

sex_country_long$country <- factor(sex_country_long$country, 
                                   ordered = T, 
                                   levels = sex_country_wide$country) # using the same order
  


country_gender_prop <- sex_country_wide %>%
  mutate(Male_Proportion = Male / (Female + Male)) %>%
  arrange(Male_Proportion)

sex_country_long$country <- factor(sex_country_long$country, 
                                   ordered = T,
                                   levels = country_gender_prop$country)

ggplot(sex_country_long, aes(y = suicide_per_100k, x = country, fill = sex)) + 
  geom_bar(position = "fill", stat = "identity") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Proportions of suicides that are Male & Female, by Country", 
       x = "Country", 
       y = "Suicides per 100k",
       fill = "Sex") + 
  coord_flip()
--------------------------------------------------------------------------------------------------------------------------------
  data %>%
  group_by(continent, age) %>%
  summarize(n = n(), 
            suicides = sum(as.numeric(suicides_no)), 
            population = sum(as.numeric(population)), 
            suicide_per_100k = (suicides / population) * 100000) %>%
  ggplot(aes(x = continent, y = suicide_per_100k, fill = age)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  geom_hline(yintercept = global_average, linetype = 2, color = "grey35", size = 1) +
  labs(title = "Age Disparity, by Continent",
       x = "Continent", 
       y = "Suicides per 100k", 
       fill = "Age")  
-------------------------------------------------------------------------------------------------------------------------------
  demographic_most <- data %>%
  mutate(suicides_per_100k = suicides_no * 100000 / population) %>%
  arrange(desc(suicides_per_100k)) %>% 
  filter(year != 1985) %>%
  head(n = round(nrow(.) * 5 / 100))


demographic_most$time <- ifelse(demographic_most$year <= 1995, "1986 - 1995", 
                                ifelse(demographic_most$year <= 2005, "1996 - 2005", 
                                       "2006 - 2015"))
  
    
  set.seed(1)

ggplot(demographic_most, aes(x = age, y = suicides_per_100k, col = sex)) + 
  geom_jitter(alpha = 0.5) + 
  labs(title = "5% Most At-Risk Instances in History", 
       subtitle = "Instances by Decade, Age, & Sex",
       x = "Age", 
       y = "Suicides per 100k", 
       col = "Sex") + 
  facet_wrap(~ time) + 
  scale_y_continuous(breaks = seq(50, 300, 10))
----------------------------------------------------------------------------------------------------------------------
  
