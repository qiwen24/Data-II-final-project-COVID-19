# Data and Programming for Public Policy II
# PPHA 30536

## Final Project: Reproducible Research
## Winter 2022

## Due: Thursday, March 17th by midnight on GitHub
## Qiwen Zhang

### Research Question:
In this project, I tried to study the relationship between Chicago COVID-19 death rate and race as well as fully vaccinated rate. My initial attempt was to study the relationship between COVID-19 and economic status across different neighborhoods in Chicago. However, I eventually switched to the current research question because it was hard to obtain up-to-date economic data (e.g. income and savings) by neighborhoods.

### Data sets:
All 4 data sets used in this project come from [Chicago Data Portal](https://data.cityofchicago.org). *COVID-19 Cases, Tests, and Deaths by ZIP Code* and *COVID-19 Vaccination by ZIP Code* contain data by ZIP code and date. *COVID-19 Daily Cases, Deaths, and Hospitalizations* contains data by different age, gender, and race. In this project, I only used data related to race. *Chicago Population Counts* contains demographic data sourced from the Census 5-year estimates (by ZIP Code). This data set is used to calculate COVID-19 death rate by race. Note that the latest population counts in this data set date back to 2019, which could be slightly different from the actual population structure during the pandemic. I manually compared (to be specific, by eyes) some numbers and the differences are acceptable (this is the best version I can get so let's just stick with it).

### Explanation of codes and discussion:
Everything starts from loading data sets and cleaning and wrangling. Data sets from the Chicago Data Portal are pretty clean. I removed some columns that are unrelated to my research interest.

I created two static plots to explore relationship between death rate and race and fully vaccinated rate, a series of 7 plots to display sentiment analysis results from 7 CDC weekly reports, and a Shiny plot showing vaccination status in Chicago by ZIP Codes.

  1. Bar plot showing case rate and death rate across different races

For this plot, I created a data frame that contains the rates I calculated using two data sets (*COVID-19 Daily Cases, Deaths, and Hospitalizations* and *Chicago Population Counts*). Then I plot the rates by races in a single plot. One difficulty I came across was to change the scale of y-axis. The problem is that death rates are much smaller than case rates, so if I use the equally distributed y-axis, death rates can hardly be seen. I changed the distribution of labels and breaks on y-axis using `scale_y_continuous(trans = "sqrt")` to make death rates more visible.

We can see from the plot that death rates are higher among Blacks and Hispanics, compared to White and Asians. Case rate of "other" race is unusually high, this is probably because some cases are not correctly assigned to the right race.

  2. Scatter plot of death rate and fully vaccinated population rate during Omicron wave

Initially I wanted to plot data of all periods of time and see if there is any visible trend. However, that plot has points all over the space and the fitted line was flat and very hard to interpret. Considering the fact that the coronavirus has become more transmissible and less deadly, I decided to only look into data during the Omicron wave (mid-December to mid-February). Each point represents weekly death rate of a given ZIP Code and a given week.

The plot shows a clear downward sloping trend between weekly death rate and fully vaccinated population rate, which was verified by many past researches. The CDC has been encouraging people to get vaccinated in order to avoid severe syndromes.

  3. A series of 7 plots showing sentiment analysis results of CDC weekly reports

For text processing, I web scraped 7 weekly reports during the Omicron wave from [CDC](https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/covid-view-past-summaries.html?Sort=Posted%20Date%3A%3Adesc) and conducted sentiment analysis. The structure of weekly reports are quite complex, having many information in plots or headers that are hard to scrape. I managed to scrape down as much text as possible and created a series of 7 plots, each showing the sentiment analysis result of one weekly report.

The plots show an overall positive sentiment in all reports. Note that words like "increase" and "vaccine" are categorized as positive. But in the context of pandemic, "increase" usually implies more cases, deaths, and higher hospitalization rate, and "vaccine" implies that CDC want people to get vaccinated to avoid serious syndromes in the upsurging wave. In order to get a more accurate result, we probably have to build a sentiment data frame specifically for the pandemic topic.

  4. A Shiny plot showing vaccination status in Chicago by ZIP Codes

I created a Shiny plot that reflects vaccination status in Chicago by ZIP Codes. There are two drop down boxes that allow people to choose a specific date and the type of data (Cumulative fully vaccinated counts and cumulative fully vaccinated population rate) they want to view on the plot. Please click [here](https://qiwen24.shinyapps.io/final-project-qiwen/) to view the plot on shinyapps.io.

  5. Fit an OLS model

In the last part of the code, I fitted an OLS model to the COVID-19 data during the Omicron wave. Each observation is the COVID-19 data in one ZIP Code in one given week. I tried to explore the relationship between death rate and race as well as fully vaccinated population rate. Unfortunately, the model does not return a satisfying result as p-values of all factors are insignificant. Among all factors, fully vaccinated population rate has the lowest p-value (0.235). So I reran the model with the fully vaccinated population rate as the only variable. This time the model returned a significant p-value, which is consistent with the scatter plot and fitted line I plotted previously.

In future research, variables related to vaccination and age could be included in the model.
