
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

save.image()

dta.df %>% filter(grepl('tresc', original)) -> dta.cat

dta.cat[-2,] -> dta.cat
dta.cat[-1,] -> dta.cat

dta.cat %>% mutate(wayback_url = paste0('https://web.archive.org/web/',timestamp,'id_/',original)) -> dta.data

e <- 1

for(u in dta.data$wayback_url) {
  
  download.file(u, paste0('pages/',e,'.html'))
  e <- e + 1
}

save.image()
