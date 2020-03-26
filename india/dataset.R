# Setting the working directory
setwd("~/Documents/COVID-19-India/india/")

#####  LIBRARIES  #####
library(stringr)



########################################
data <- read.csv("cleaned/statewise_ready.csv")


# india.states.daily(Conf1/Conf2/Conf3/Deaths/Recovered)
Confirmed.indians <- read.csv("cleaned/Confirmed_indians.csv")
Confirmed.foreigners <- read.csv("cleaned/Confirmed_foreigners.csv")

Confirmed.overall <- read.csv("cleaned/time_series_19-covid-Confirmed.csv")
Deaths <- read.csv("cleaned/time_series_19-covid-Deaths.csv")
Recovered <- read.csv("cleaned/time_series_19-covid-Recovered.csv")
#View(data)
#View(Confirmed.indians)
#View(Confirmed.foreigners)

#View(Confirmed.overall)
#View(Deaths)
#View(Recovered)


#######################################

getPercent <- function(whole, part){
  if(whole == 0) {
    cent = 0.00
  } else {
    cent = (part*100)/whole
    cent = round(cent, 2)  # rounds off the value to hold upto 2 decimal places
  }
  return(cent)
}

country.timeseries  <-  function(dfName) {
  
  temp = get(dfName)            # all states' data of the country
  df = temp[1,]
  
  df[2:ncol(temp)] = apply(   temp[,2:ncol(temp)],
                              2,
                              sum
                           )                              
  
  names <- c("Country", colnames(df[2:ncol(df)]))
  colnames(df) <- names
  df$Country = "India"
  
  row.names(df) <- NULL
  
  return(df)
}

# sort
sort.statewise <- function(dfName){
  df <- get(dfName)
  df = df[order(df$State),]
  
  return(df)
}
sort.datewise <- function(dfName){
  df = get(dfName)
  df = df[order(df$Day),]
  
  return(df)
}

# summarizer
summary.states = function() {
  
  #########################################
  C.i <- get("Confirmed.indians")
  C.f <- get("Confirmed.foreigners")
  C.o <- get("Confirmed.overall")
  D <- get("Deaths")
  R <- get("Recovered")
  
  
  c1 = C.o[,ncol(C.o)]
  c2 = D[,ncol(D)]
  
  rate.of.death = cbind(c1, c2)
  result = data.frame(cent = NULL)
  
  for (j in 1:nrow(rate.of.death)) { # i=1
    whole = as.integer(rate.of.death[j,1])
    part = as.integer(rate.of.death[j,2])
    res = getPercent(whole, part)
    
    temp = data.frame(cent = res)
    result = rbind(result, temp)
  }
  #########################################
  
  
  allStates <- as.character(C.o$State)   # list of states in the country
  
  ###### overall data of the country (all states) ######
  df = data.frame(
    States = allStates,
    "Confirmed Indians" = C.i[,ncol(C.i)],
    "Confirmed Foreigners" = C.f[,ncol(C.f)],
    "Total Confirmed" = C.o[,ncol(C.o)],
    "Total Deaths" = D[,ncol(D)],
    "Total Recovered" = R[,ncol(R)],
    "Total Active Cases" = C.o[,ncol(C.o)] - (D[,ncol(D)] + R[,ncol(R)]),
    "Total Closed Cases" = D[,ncol(D)] + R[,ncol(R)],
    "Overall Death Rate(%)" = result$cent
  )
  
  return(df)
}

india.summary = function(){
  
  allStates = summary.states()
  
  temp = data.frame(
    Country = c("India"),
    "Confirmed Indians" = sum(allStates$Confirmed.Indians),
    "Confirmed Foreigners" = sum(allStates$Confirmed.Foreigners),
    "Total Confirmed" = sum(allStates$Total.Confirmed),
    "Total Recovered" = sum(allStates$Total.Recovered),
    "Total Deaths" = sum(allStates$Total.Deaths),
    "Total Active Cases" = sum(allStates$Total.Active.Cases),
    "Closed Cases" = sum(allStates$Total.Closed.Cases),
    "Overall Death Rate(%)" = getPercent(sum(allStates$Total.Confirmed), sum(allStates$Total.Deaths))
    )
  
  return(temp)
}
#################

india.bulk.summary = function() { # date wise country data
  
  # structure of resulting dataset (initially blank)
  df <- data.frame(
    Country = NULL,
    Day = NULL,           # day no.
    Date = NULL,
    Confirmed = NULL,
    Deaths = NULL,
    Recovered = NULL,
    "Active Cases" = NULL,
    "Closed Cases" = NULL,
    "Death Rate" = NULL
  )
  
  
  for (state in levels(conf.indians$State)) {
    CI = conf.indians[which(str_detect(conf.indians$State, state)),]
    CF = conf.foreigners[which(str_detect(conf.foreigners$State, state)),]
    CO = conf.overall[which(str_detect(conf.overall$State, state)),]
    D = Deaths[which(str_detect(Deaths$State, state)),]
    R = Recovered[which(str_detect(Recovered$State, state)),]
    
    
    times = ncol(CI)-1      # no. of days
    day = 1:times
    d = as.Date("30/01/2020", format(c("%d/%m/%Y")))
    
    date = as.character((day + d), format(c("%d/%m/%Y")))
    date = factor(c(date), levels = date)
    
    #########
    conf.I = as.integer(CI[,2:ncol(CI)])
    conf.F = as.integer(CF[,2:ncol(CF)])
    conf.O = as.integer(CO[,2:ncol(CO)])
    dead = as.integer(D[,2:ncol(D)])
    recovered = as.integer(R[,2:ncol(R)])
    
    rate.of.death = cbind(conf.O, dead)
    result = data.frame(cent = NULL)
    
    for (j in 1:nrow(rate.of.death)) { # i=1
      whole = as.integer(rate.of.death[j,1])
      part = as.integer(rate.of.death[j,2])
      res = getPercent(whole, part)
      
      temp = data.frame(cent = res)
      result = rbind(result, temp)
    }
    #########
    
    dataset <- data.frame(
      State = rep(CI[1,"State"], times),
      Date = date,
      Day = c(1:times),
      "Confirmed Indians" = conf.I,
      "Confirmed Foreigners" = conf.F,
      "Total Confirmed" = conf.O,
      "Deaths" = dead,
      "Recovered" = recovered,
      "Active Cases" = conf.O - (dead + recovered),
      "Closed Cases" = dead + recovered,
      "Death Rate" = result$cent
    )
    df = rbind(df, dataset)
  }
  
  return(df)
}
########################################

# india.aggr.daily(Conf1/Conf2/Conf3/Deaths/Recovered)
india.daily.conf.ind = country.timeseries("Confirmed.indians")
india.daily.conf.forg = country.timeseries("Confirmed.foreigners")
india.daily.conf.all = country.timeseries("Confirmed.overall")
india.daily.dead = country.timeseries("Deaths")
india.daily.cure = country.timeseries("Recovered")

#View(india.daily.conf.ind)
#View(india.daily.conf.forg)
#View(india.daily.conf.all)
#View(india.daily.dead)
#View(india.daily.cure)

# india.states.summary
india.summary.statewise = summary.states()
#View(india.summary.statewise)

# india.aggr.summary
india.summary.overall = india.summary()
#View(india.summary.overall)

india.summary.statewise = india.bulk.summary()
india.summary.datewise = sort.datewise("india.summary.statewise")
#View(india.summary.statewise)
#View(india.summary.datewise)


#######################################################

# to write
# 4. india.aggr.summary.datewise      ------>  use datewise()
# 5. india.aggr.summary.statewise      ------>  supplimentry