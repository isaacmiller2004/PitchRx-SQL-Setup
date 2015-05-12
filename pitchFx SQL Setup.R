#Load pitchRx and other packages
library(pitchRx)
library(lattice)
library(RMySQL)

#Scrape 2014 regular season data (takes a long time)
data <- scrapeFX(start="2014-03-22", end="2013-09-28")

#Connect to MySQL. MAMP needs to be running
install.packages("RMySQL")
drv <- dbDriver("MySQL")
MLB <- dbConnect(drv, user="root", password="root", port=8889, dbname="pitchfx_2014", 
                      host="localhost", unix.socket="/Applications/MAMP/tmp/mysql/mysql.sock")

#Write pitchfx to MySQL tables
dbWriteTable(MLB, value = data$pitch, name = "pitch", row.names = FALSE, append = TRUE)
dbWriteTable(MLB, value = data$atbat, name = "atbat", row.names = FALSE, append = TRUE)

#Get data
koji <- dbGetQuery(MLB, "SELECT * FROM atbat INNER JOIN pitch ON
(atbat.num = pitch.num AND atbat.url = pitch.url)
WHERE atbat.pitcher_name = 'Koji Uehara'")

andrus <- dbGetQuery(MLB, "SELECT * FROM atbat INNER JOIN pitch ON
(atbat.num = pitch.num AND atbat.url = pitch.url)
WHERE atbat.batter_name = 'Elvis Andrus'")

#Example plots
xyplot(pz ~ px | stand, data=koji, groups=pitch_type, auto.key=TRUE)
xyplot(pz ~ px | stand, data=koji, groups=pitch_type, auto.key=TRUE, 
       aspect="iso",
       xlim=c(-2.2, 2.2),
       ylim=c(0, 5),
       xlab="Horizontal Location\n(ft. from middle of plate)",
       ylab="Vertical Location\n(ft. from ground)")
pitchnames <- c("4-Seam Fastball", "Splitter", "2-Seam fastball", "IN", "Slider")
myKey <- list(space="right",
              border=TRUE,
              cex.title=.8,
              title="Pitch Type",
              text=pitchnames,
              padding.text=4)
topKzone <- 3.5
botKzone <- 1.6
inKzone <- -.95
outKzone <- 0.95
xyplot(pz ~ px | stand, data=koji, groups=pitch_type,
       auto.key=myKey,
       aspect="iso",
       xlim=c(-2.2, 2.2),
       ylim=c(0, 5),
       xlab="horizontal location\n(ft. from middle of plate)",
       ylab="vertical location\n(ft. from ground)",
       panel=function(...){
         panel.xyplot(...)
         panel.rect(inKzone, botKzone, outKzone, topKzone,
                    border="black", lty=3)
       }
)