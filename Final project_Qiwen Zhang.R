### Data II Final Project
### Qiwen Zhang

library(tidyverse)
library(rvest)
library(tidytext)

### Data cleaning and wrangling
case_zip <- read_csv("./data/COVID-19_Cases__Tests__and_Deaths_by_ZIP_Code.csv")
vac_zip <- read_csv("./data/COVID-19_Vaccinations_by_ZIP_Code.csv")
case <- read_csv("./data/COVID-19_Daily_Cases__Deaths__and_Hospitalizations.csv")
pop <- read_csv("./data/Chicago_Population_Counts.csv")

case_zip_clean <- case_zip %>%
  filter(`ZIP Code` != "Unknown") %>%
  select(-c("Tests - Weekly":"Percent Tested Positive - Cumulative", 
            "ZIP Code Location", "Row ID"))
vac_zip_clean <- vac_zip %>%
  filter(`Zip Code` != "Unknown") %>%
  select(-c("1st Dose - Daily":"1st Dose - Percent Population", 
            "Total Doses - Daily - Age 5+":"Vaccine Series Completed - Daily - Age 65+",
            "ZIP Code Location", "Row_ID"))
case <- case %>% filter(Date != "NA")
pop <- pop %>% 
  filter(Year == 2019, Geography != "Chicago") %>%
  select(-c("Population - Age 0-17":"Population - Male", "Record ID"))

write.csv(vac_zip_clean, "./data/vac_zip_clean.csv", row.names = FALSE)

### Create a bar plot showing positive case rate and death rate across different races
race <- c("Latinx", "Asian", "Black", "White", "Other")
case_rate <- c(sum(case$`Cases - Latinx`)/sum(pop$`Population - Latinx`),
               sum(case$`Cases - Asian Non-Latinx`)/sum(pop$`Population - Asian Non-Latinx`),
               sum(case$`Cases - Black Non-Latinx`)/sum(pop$`Population - Black Non-Latinx`),
               sum(case$`Cases - White Non-Latinx`)/sum(pop$`Population - White Non-Latinx`),
               sum(case$`Cases - Other Race Non-Latinx`)/sum(pop$`Population - Other Race Non-Latinx`))
death_rate <- c(sum(case$`Deaths - Latinx`)/sum(pop$`Population - Latinx`),
                sum(case$`Deaths - Asian Non-Latinx`)/sum(pop$`Population - Asian Non-Latinx`),
                sum(case$`Deaths - Black Non-Latinx`)/sum(pop$`Population - Black Non-Latinx`),
                sum(case$`Deaths - White Non-Latinx`)/sum(pop$`Population - White Non-Latinx`),
                sum(case$`Deaths - Other Race Non-Latinx`)/sum(pop$`Population - Other Race Non-Latinx`))
df <- data.frame(race, case_rate, death_rate) %>%
  pivot_longer(c("case_rate", "death_rate"), names_to = "category", values_to = "rate")
write.csv(df, "./data/case_death_race.csv", row.names = FALSE)

png("./images/case_death_race.png")
ggplot(data = df, aes(x = race, y = rate, fill = category)) +
  geom_bar(stat = "identity",
           position = "dodge") +
  geom_text(aes(label = round(rate, 4)),
            vjust = -0.5,
            position = position_dodge(0.9), 
            size = 3) +
  scale_x_discrete(limits = c("White", "Black", "Asian", "Latinx", "Other")) +
  scale_y_continuous(trans = "sqrt", breaks = c(0.002, 0.005, 0.05, 0.2, 0.5)) +
  labs(title = "Chicago COVID-19 case rate and death rate among different races",
       x = element_blank(),
       y = "Rate",
       fill = "Types of rate") +
  scale_fill_discrete(labels = c("Case rate", "Death rate")) +
  theme_bw()
dev.off()

### Create a scatter plot of death rate and fully vaccinated population rate during Omicron wave
case_vac <- case_zip_clean %>% 
  left_join(vac_zip_clean, by = c("ZIP Code" = "Zip Code", "Week End" = "Date")) %>%
  na.omit()
case_vac$`Week End` <- as.Date(case_vac$`Week End`, format = "%m/%d/%Y")

case_vac <- case_vac %>%
  filter(`Week End` >= "2021-12-18" & `Week End` <= "2022-02-19")
write.csv(case_vac, "./data/case_vac_omicron.csv", row.names = FALSE)

png("./images/case_vac_omicron.png")
ggplot(data = case_vac, aes(x = `Vaccine Series Completed  - Percent Population`,
                            y = `Death Rate - Weekly`)) +
  geom_point(alpha = 0.7, color = "coral") +
  geom_smooth(color = "sky blue", size = 1.5) +
  labs(title = "Chicago COVID-19 death rate and fully vaccinated rate",
       subtitle = "During the Omicron wave (mid-Dec 2021 to mid-Feb 2022)",
       x = "Fully vaccinated population rate",
       y = "Weekly death rate") +
  theme_bw()
dev.off()

### Web scraping and sentiment analysis
url0 <- "https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/past-reports/"
dates <- c("12172021", "01072021", "01142022", "01212022", "01282022", "02042022", "02112022")
# The weekly report released on Jan 7th 2022 is noted with a wrong date (01072021) in the url.

text <- list()
for (date in dates) {
  request <- read_html(paste0(url0, date, ".html"))
  Sys.sleep(0.5)
  article <- html_nodes(request, ".col-md-12")
  paragraphs <- html_nodes(article, "p")
  text_list <- html_text(paragraphs)
  text[date] <- paste(text_list, collapse = "")
}

text_tb <- tibble(report = names(text), text = text)
word_tb <- unnest_tokens(text_tb, word, text, token = "words")
word_count <- word_tb %>% 
  group_by(report) %>%
  summarise(totalwc = n())
word_nrc <- word_tb %>%
  left_join(get_sentiments("nrc"), by = "word")

word_nrc_count <- word_nrc %>%
  count(report, sentiment) %>%
  filter(!is.na(sentiment)) %>%
  left_join(word_count, by = "report") %>%
  mutate(prop = n / totalwc)
write.csv(word_nrc_count, "./data/word_nrc_count.csv", row.names = FALSE)

for (date in dates) {
  data <- word_nrc_count %>% filter(report == date)
  plot <- ggplot(data = data) +
    geom_col(aes(x = sentiment, y = prop), fill = "coral") +
    ylim(0, 0.065) +
    labs(title = "CDC COVID-19 Weekly Report: NRC sentiment",
         subtitle = paste0("Report date: ", as.Date(date, format = "%m%d%Y")),
         x = element_blank(),
         y = "Proportion") +
    theme_bw()
  png(paste0("./images/sentiment_", date, ".png"))
  print(plot)
  dev.off()
}

### Fit a model
pop <- pop %>%
  mutate(latinx = `Population - Latinx` / `Population - Total`,
         asian = `Population - Asian Non-Latinx` / `Population - Total`,
         black = `Population - Black Non-Latinx` / `Population - Total`,
         white = `Population - White Non-Latinx` / `Population - Total`,
         other = `Population - Other Race Non-Latinx` / `Population - Total`)
data_model <- case_vac %>%
  left_join(pop, by = c("ZIP Code" = "Geography")) %>%
  filter(`ZIP Code` != 60666) %>%
  select(-c("Cases - Weekly":"Case Rate - Cumulative", "Geography Type":"Population - Other Race Non-Latinx"))

lm <- lm(`Death Rate - Weekly` ~ latinx + asian + black + white + other + `Vaccine Series Completed  - Percent Population`, data = data_model)
summary(lm)

lm_vac <- lm(`Death Rate - Weekly` ~ `Vaccine Series Completed  - Percent Population`, data = data_model)
summary(lm_vac)
