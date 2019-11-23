
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

######################################################################

get_links <- function(d) {
  # d - directory
  
  library(xml2)
  links <- data.frame(stringsAsFactors = FALSE)
  pages <- dir(d)
  
  for(p in pages) {
    
    p.html <- read_html(paste0(d,'/',p), encoding = "UTF-8")
    l <- xml_find_all(p.html, '//a/@href')
    
    links <- rbind(links,as.data.frame(unlist(as_list(l))))
    
  }

return(links)  
    
}

tst <- get_links('pages')

write.csv(tst, 'interia2000links.csv', fileEncoding = "UTF-8")

tst -> links

################################

names(links) <- 'url'

links %>% filter(!grepl('interia', url)) -> links

links %>% filter(grepl('http', url)) -> links

links %>% filter(!grepl('www.poczta.fm', url)) -> links

unique(links) -> links

write.csv(links, 'interia2000_outside.csv', fileEncoding = "UTF-8")

##########################################

# http://archive.org/wayback/available?url=example.com&timestamp=20060101

# test

avapi <- 'http://archive.org/wayback/available?url='

resp <- fromJSON(paste0(avapi,links$url[3],'&timestamp=2000'))

str(resp$archived_snapshots$closest$url)


links$url -> links.lst

links.lst <- as.character(links.lst)

wb_links <- data.frame(stringsAsFactors = FALSE)

for(l in links.lst[1:15]) {

  #str(l)
  avapi <- 'http://archive.org/wayback/available?url='
  resp <- fromJSON(paste0(avapi,l,'&timestamp=2000'))
  b_url = resp$archived_snapshots$closest$url
  cat(paste0(b_url,'\n'))
  #ifelse(!is.null(b_url), wb_url = b_url, wb_url = NULL)  
  #wb_links <- rbind(wb_links, as.data.frame(list(url = l, wb_url), stringsAsFactors = FALSE))
  
}

