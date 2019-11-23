
#https://web.archive.org/cdx/search/cdx?url=katalog.interia.pl/*&from=2000&to=2000&output=json&limit=150000

library(jsonlite)

u <- "https://web.archive.org/cdx/search/cdx?url=katalog.interia.pl/*&from=2000&to=2000&output=json&limit=150000"

dta <- fromJSON(u)
dta[1,] -> columns
dta <- dta[-1,]
dta.df <- as.data.frame(dta)
names(dta.df) <- columns
dta.df.copy <- dta.df

library(dplyr)

dta.df %>% filter(mimetype == 'text/html') %>% filter(statuscode == 200) -> dta.df
