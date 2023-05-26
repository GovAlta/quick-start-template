# Prosthetic 1 Description

The analysis-ready rectangle `./data-public/raw/example-prosthetic-1.csv` contains fictional data with the results of a survey in which 2000 respondents answered questions about their background and employment status following their participation in a training program. Each row of this table is a response to the survey. The data table contains the following columns:

`id` - unique person identifier, each row has a unique value of `id`\
`weight` - a combined non-response and sampling weight, must adjust by this factor when genralizing to the population of clients, from which this current sample (N = 2,000) was derived. `date` - the date of survey response\
`employed` - employment status at the time of the survey\
`gender` - gender of the respondent\
`age` - age group of the respondent\
`race` - race of the respondent

Univariate distributions of categorical variables are as follows:

Input:
``` r
ds0 <- readr::read_rds("../../data-public/raw/example-prosthetic-1.rds")
ds0 %>% select(-id,-weight,-date) %>% tableone::CreateTableOne(data=.)
```
Output:
```         
                          Overall     
  n                       2000        
  employed = employed (%) 1096 (56.9) 
  gender (%)                          
     male                  836 (41.8) 
     female               1164 (58.2) 
     unknown                 0 ( 0.0) 
  age (%)                             
     middle age           1312 (65.6) 
     senior                400 (20.0) 
     youth                 288 (14.4) 
  race (%)                            
     caucasian            1251 (64.5) 
     visible minority      450 (23.2) 
     aboriginal            240 (12.4) 
```

Links:

Data
[https://raw.githubusercontent.com/GovAlta/quick-start-template/main/data-public/raw/example-prosthetic-1.csv](https://raw.githubusercontent.com/GovAlta/quick-start-template/main/data-public/raw/example-prosthetic-1.csv)

Description
[https://raw.githubusercontent.com/GovAlta/quick-start-template/main/data-public/raw/example-prosthetic-1.md](https://raw.githubusercontent.com/GovAlta/quick-start-template/main/data-public/raw/example-prosthetic-1.md)


# Prompt

> Use this description (https://raw.githubusercontent.com/GovAlta/quick-start-template/main/data-public/raw/example-prosthetic-1.md) to understand this data set (https://raw.githubusercontent.com/GovAlta/quick-start-template/main/data-public/raw/example-prosthetic-1.csv). Refer to this data set as `ds0`