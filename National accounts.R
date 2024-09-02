
#Load library 
library(tidyverse)
library(Hmisc)

install.packages('shiny')
library(shiny)
library(tibble)


#Removes all the variable stores previously
rm(list = ls())

# Import data file 
df <- read_excel("/Users/hoanglinh/Project/Important/PortfolioPreject/World Development.xlsx")
View(df)


#Sort data
sorted_df <- df[order(df$Series_Name),]
view(sorted_df)

str(sorted_df)

#specify NA values

sorted_df <- sorted_df %>%
  mutate(across(starts_with('19'), ~ as.numeric(replace(., . == "NA", NA))))
sorted_df <- sorted_df %>%
  mutate(across(starts_with('20'), ~ as.numeric(replace(., . == "NA", NA))))


#Missing data
sum(is.na.data.frame(sorted_df))

library(dplyr)
library(tidyr)
df <- sorted_df
view(df)

df <- df %>% mutate(across(where(is.numeric), ~ ifelse(is.na(.), rowMeans(across(where(is.numeric)), na.rm=TRUE), .))) #remove all missing with row mean
View(df)

sum(is.na.data.frame(df))

df_new <- na.omit(df) #remove any rows with na and have no meaning in the dataframe
view(df_new)

sum(is.na.data.frame(df_new))

df <- df_new

#Retrieve data to create table and visualize

# Find the indices where the country name is 'Austria'
start_indices <- which(df$Country_Name %in% c("Andorra", "Austria"))

# Find the indices where the country name is 'United Kingdom'
end_indices <- which(df$Country_Name == "United Kingdom")

# Create a list to store the separate tables
list_of_tables <- list()

# Initialize a counter for the tables
table_counter <- 1

# Loop through the dataframe and create separate tables
for (start in start_indices) {
  # Find the next end index that comes after the current start index
  end <- end_indices[end_indices > start][1]
  
  # If an end index is found, create a table
  if (!is.na(end)) {
    list_of_tables[[table_counter]] <- df[start:end, ]
    table_counter <- table_counter + 1
  }
}


#Store each table in a dataframe
# Create an empty list to store the new dataframes
dataframes <- list()

# Loop through the list and assign each table to a new dataframe
for (i in seq_along(list_of_tables)) {
  dataframe_name <- paste0("df_", i)
  dataframes[[dataframe_name]] <- list_of_tables[[i]]
}

# Print the names of the new dataframes to check
print(names(dataframes))


view(dataframes)

# From the raw data, I've replace and remove NA values.
#I've also split it into different dataframe, I'm going to visualise some selected dataframe


library(ggplot2)
library(tidyverse)


#GDP Line chart using ggplot2

GDP_df <- dataframes[["df_8"]]
df_2013 <- GDP_df[, c("Country_Name", "2019", "2018")]
df_long <- pivot_longer(df_2013, cols = c("2018", "2019"), names_to = "Years", values_to = "Value")

ggplot(df_long, aes(x = Country_Name, y = Value, color = Years, group = Years)) +
  geom_line(size = 1.5) +  # Adjust the size parameter to make the lines thicker
  geom_point(size = 1.5) +
  labs(x = "Country", y = "Value", title = "Values for Each Country in 1979 and 2013") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 12, face = "bold"),  # Rotate and style the country names
    axis.text.y = element_text(size = 12, face = "bold"),  # Style the y-axis text
    axis.title.x = element_text(size = 14, face = "bold"),  # Style the x-axis title
    axis.title.y = element_text(size = 14, face = "bold"),  # Style the y-axis title
    plot.title = element_text(size = 16, face = "bold")  # Style the plot title
  ) 

#GNI line chart using plotly
install.packages("plotly")
library(plotly)

df_filtered <- GNI_df[, c("Country_Name", "Country_Code", "2018", "2019")]
df_long <- pivot_longer(df_filtered, cols = c("2018", "2019"), names_to = "Year", values_to = "Value")

plot_ly(df_long, x = ~Country_Name, y = ~Value, color = ~Year, type = 'scatter', mode = 'lines+markers', 
        line = list(width = 3), marker = list(size = 8)) %>%
  layout(title = "Values for Each Country in 1979 and 2013",
         xaxis = list(title = "Country", tickangle = -90, tickfont = list(size = 12, family = "bold")),
         yaxis = list(title = "Value", tickfont = list(size = 12, family = "bold")),
         legend = list(title = list(text = 'Year')),
         font = list(size = 14, family = "bold"))












