rm(list=ls())
library(sqldf)

#############get data - load all csvs into dataframes and clean it

setwd("C:/_MAIN/projects/NCI/Stats for DA/Project")

#list all csv files in folder
temp = list.files(path = "./data/UNdata/", pattern = "*.csv", full.names = T)

#read all csv files into list of dataframes
myfiles = lapply(temp, read.csv, header=TRUE, na.strings=c("",".","..","…","NA","â€¦"))

#MarriagesAge = read.csv(temp[6], header=TRUE, na.strings=c("",".","..","…","NA"))
#names(MarriagesAge)<-gsub("\\.","_",names(MarriagesAge))
#MarriagesAge<-MarriagesAge[!(is.na(MarriagesAge$Value)),] 

#replace dots in the name of each dataframe and remove footnotes (and other missing values if any in Value column)
myfilesfixed<-lapply(myfiles, function(x) {
                                  names(x)<-gsub("\\.","_",names(x))
                                  #x<-x[-which(is.na(x$Value)),] 
                                  x<-x[!(is.na(x$Value)),] 
                                  x} )

#separate dataframes from a list into separate dataframes and give them name of their file
for (i in 1:length(myfilesfixed)) {
  datasetname<-gsub("\\.csv","",basename(temp[i]))#paste0("data",i)
  assign(datasetname, as.data.frame(myfilesfixed[i])) 
}

PopulationMF<-PopulationMF[!(PopulationMF$Country_or_Area=='Anguilla' & PopulationMF$Source=="UNSD_Demographic Yearbook Database_Sep2007 (Census figure)"),]

#rm(myfiles)
#############create dataset for analysis

#for each country_or_area the last year when the data was collected for each of the individual datasets
LatestAvailableData<-sqldf("
                       select y.country_or_area, Max_y, 
                            Max_x1,Max_x2,Max_x3,Max_x4,Max_x5,Max_x6,Max_x7,Max_x8,Max_x9

                       from (select country_or_area, max(year) as Max_y
                            from NumberOfDivorces
                            group by country_or_area) as y

                       left join (select country_or_area, max(year) as Max_x1
                            from EnrolmentEducation
                            group by country_or_area) as x1 on (y.country_or_area=x1.country_or_area)   

                       left join (select country_or_area, max(year) as Max_x2
                            from FirstMarriagesByAge
                            group by country_or_area) as x2 on (y.country_or_area=x2.country_or_area)   

                       left join (select country_or_area, max(year) as Max_x3
                            from GDPperCapita
                            group by country_or_area) as x3 on (y.country_or_area=x3.country_or_area)   

                       left join (select country_or_area, max(year) as Max_x4
                            from LiteracyParityIndex
                            group by country_or_area) as x4 on (y.country_or_area=x4.country_or_area)   

                       left join (select country_or_area, max(year) as Max_x5
                            from LiteracyRate
                            group by country_or_area) as x5 on (y.country_or_area=x5.country_or_area)   

                       left join (select country_or_area, max(year) as Max_x6
                            from MarriagesAge
                            group by country_or_area) as x6 on (y.country_or_area=x6.country_or_area)   

                       left join (select country_or_area, max(year) as Max_x7
                            from MarriagesByUrbanRural
                            group by country_or_area) as x7 on (y.country_or_area=x7.country_or_area)   

                       left join (select country_or_area, max(year) as Max_x8
                            from PopulationMF
                            group by country_or_area) as x8 on (y.country_or_area=x8.country_or_area)   

                       left join (select country_or_area, max(year) as Max_x9
                            from Religion
                            group by country_or_area) as x9 on (y.country_or_area=x9.country_or_area)   

                       order by y.country_or_area      ")

DivorceData<-sqldf("select y.country_or_area, d.Max_y, y.year, y.area,
                              y.value as Divorces, 
                              x1_1.Value as EducationF, 
                              x1_2.Value as EducationM,
                              x3.Value as GDPpc,
                              x4.Value as LitParityIndex,
                              x5_1.Value as LiteracyF,
                              x5_2.Value as LiteracyM,
                              x6.SingulateAgeWomen,
                              x6.SingulateAgeMen,
                              x7.Value as Marriages,
                              x8_1.Value as PopulationF,
                              x8_2.Value as PopulationM

                       from LatestAvailableData d
                       join NumberOfDivorces y on (y.country_or_area=d.country_or_area and
                                                   y.area='Total' and
                                                   y.year>2005 and 
                                                   y.year=(case when d.Max_y<2017 then d.Max_y else 2017 end)
                                                  )
                       left join EnrolmentEducation x1_1 on (y.country_or_area=x1_1.country_or_area 
                                                                and x1_1.Subgroup='Female'
                                                             and x1_1.year=d.Max_x1)   
                       left join EnrolmentEducation x1_2 on (y.country_or_area=x1_2.country_or_area 
                                                                and x1_2.Subgroup='Male'
                                                             and x1_2.year=d.Max_x1)        
                       left join GDPperCapita x3 on (y.country_or_area=x3.country_or_area 
                                                             and x3.year=d.Max_x3)   
                       left join LiteracyParityIndex x4 on (y.country_or_area=x4.country_or_area 
                                                             and x4.year=d.Max_x4)  

                       left join LiteracyRate x5_1 on (y.country_or_area=x5_1.country_or_area 
                                                             and x5_1.year=d.Max_x5
                                                             and x5_1.Subgroup like 'Female%')  
                       left join LiteracyRate x5_2 on (y.country_or_area=x5_2.country_or_area 
                                                             and x5_2.year=d.Max_x5
                                                             and x5_2.Subgroup like 'Male%') 

                       left join MarriagesAge x6 on (y.country_or_area=x6.country_or_area 
                                                             and x6.year=d.Max_x6) 
                       left join MarriagesByUrbanRural x7 on (y.country_or_area=x7.country_or_area 
                                                                    and x7.year=d.Max_x7
                                                                    and x7.area='Total') 

                       left join PopulationMF x8_1 on (y.country_or_area=x8_1.country_or_area 
                                                                    and x8_1.year=d.Max_x8
                                                                    and x8_1.Subgroup='Female') 
                       left join PopulationMF x8_2 on (y.country_or_area=x8_2.country_or_area 
                                                                    and x8_2.year=d.Max_x8
                                                                    and x8_2.Subgroup='Male') 

                                         ")

#I leave out Religion for the moment as not sure what I want to use from it: 
#proportion or religious people to total? proportion of catholics+muslims to total? 
#Labels for religions between countries vary a lot

#FirstMarriagesByAge dataset I leave out too because SingulateAge give me what I need

CDivorceData<-DivorceData[complete.cases(DivorceData),]

write.csv(DivorceData,file.path("./data/CleanData/","DivorceData.csv"))
write.csv(CDivorceData,file.path("./data/CleanData/","CDivorceData.csv"))

#missing data - might need to restrict dataset to a certain set of countries
#approach to select year - better to have data from different datasets refered to the same year to have consistency. 
#For many datasets the data is only available on some years, they probably do not change often. 
#I use the latest available year for all except dependent variable data (which is 2017 or the latest before 2017, but not earlier than 2005)


