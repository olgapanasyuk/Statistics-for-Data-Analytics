## Statistics for Data Analytics
Here I saved code used to prepare data for the CA1 project (linear regression), collating some datasets from the [UN data repository](http://data.un.org/) and the obtained datasets.

As data was collated from different sources, some of the variables are coming from different calendar year surveys. Generally, data on the number of divorces, marriages and GPD was available for most countries for every year up to 2018. The 2017 data was chosen to be used in this analysis as the most recent and complete. Where the data on divorces was not available for 2017, it was taken from the most recent available year, but not later than 2005. Countries with no data on divorces after 2005 were excluded from the analysis. 115 countries in total were included in the final dataset.

The data on literacy, singulate age, numbers in education, population size was available only in certain years, because by nature it is generally collected during population censuses. These data were taken with reference to the most recent available year.

There are overall 115 observations, of which only 33 are complete (i.e. all variables have values).

The prepared dataset consists of the following data for each country:

+	Number of divorces;
+	Number of females in third level education;
+	Number of males in third level education;
+	GDP per capita, USD;
+	Literacy parity index;
+	Literacy rate females;
+	Literacy rate males;
+	Singulate age women(\*), years;
+	Singulate age men(\*), years;
+	Number of marriages;
+	Population female;
+	Population male;

<font-size:1em>(\*) Singulate means number of years spend in single status, before first marriage.

