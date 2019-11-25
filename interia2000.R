
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

library(jsonlite)

avapi <- 'http://archive.org/wayback/available?url='

resp <- fromJSON(paste0(avapi,links$url[3],'&timestamp=2000'))

str(resp$archived_snapshots$closest$url)


links$url -> links.lst

links.lst <- as.character(links.lst)

wb_links <- data.frame(stringsAsFactors = FALSE)

get_wayback_urls <- function(data) {
  
  for(l in data) {
  
  tryCatch(
    expr = {
  
      avapi <- 'http://archive.org/wayback/available?url='  
      resp <- fromJSON(paste0(avapi,l,'&timestamp=2000'))

      if(length(resp$archived_snapshots) > 0) {
        # status odpowiedzi 200 oznacza, że strona została poprawnie zapisana w Wayback Machine
        # wpisywanie do ramki danych odpowiedzi serwera z adresem archiwalnej kopii strony

        b_url <- resp$archived_snapshots$closest$url
        time <- resp$archived_snapshots$closest$timestamp
        status <- resp$archived_snapshots$closest$status
        y <- substr(time,1,4)
        clean_url <- paste0('http://web.archive.org/web/',time,'id_/',l)
        
      } else {
        # wpisywanie do ramki danych statusu odpowiedzi serwera 
        b_url <- NA
        time <- NA
        status <- NA
        y <- NA
        clean_url <- NA
      }
      wb_links <- rbind(wb_links, as.data.frame(list(url = l, wb_url = b_url, wb_url_clean = clean_url, timestamp = time, year = y, http_status = status), stringsAsFactors = FALSE))
    },

    error = function(e){
      message('Wystąpił błąd!')
      print(e)
      cat('-----------------------------------------\n')    
      
    },
    warning = function(w){
      message('Ostrzeżenie!')
      print(w)
      cat('-----------------------------------------\n')    
      
    },
      finally = {
        message('Odpowiedź serwera zapisana')
      }
    )    
  }
  return(wb_links)
}



#a <- fromJSON("https://archive.org/wayback/available?url=http://www.optel.com.pl/i&timestamp=2000")
#a
a <- get_wayback_urls(links.lst[130:145])
