# My Data Analytics Portfolio Projects

## 1. [Covid-19 Deaths and Vaccinations: SQL Data Exploration](https://github.com/hazelapondi/Data-Analytics-Portfolio-Projects/blob/main/SQL/covid_deaths_and_vaccinations.sql)

![Covid-19 across the globe](https://github.com/hazelapondi/Data-Analytics-Portfolio-Projects/blob/main/img/covid.png)

I used SQL for Data Exploration of the Covid-19 Deaths and Vaccinations from a data set obtained from [Our World in Data](https://ourworldindata.org/covid-deaths "Coronavirus"). After downloading the data set, I transformed it. The data captures confirmed deaths from Covid-19 from Jan 2021. 

I explored Covid-19 Cases, Deaths and Vaccinations to learn more about statistics such as the global & regional death and infection percentages, the population vs number of people vaccinated among others.

## 2. [Maji Ndogo: Querying Data with SQL](https://github.com/hazelapondi/Data-Analytics-Portfolio-Projects/blob/main/SQL/maji_ndogo.sql)

![People queueing for water in Maji Ndogo - 42 Amani Loop, Sokoto](https://github.com/hazelapondi/Data-Analytics-Portfolio-Projects/blob/main/img/maji_ndogo.PNG)

Maji Ndogo is a fictitious country facing a water access issue in a number of its provinces. Using SQL I was able to draw insights on areas with very long queues, gender dynamics in queues (with the composition consisting of children, women and men) and  findings on crime rates at water sources over different days of the week and hours of the day. 

In summary, the findings included that:

* Most water sources are rural in Maji Ndogo.
* 43% of the people in Maji Ndogo are using shared taps. 2000 people often share one tap.
* 31% of our population has water infrastructure in their homes but within that group 45% face non-functional systems due to issues with pipes, pumps, and reservoirs. Towns like Amina, the rural parts of Amanzi, and a couple of towns across Akatsi and Hawassa have broken infrastructure.
* 18% of the people are using wells, but within that, only 28% are clean. These are mostly in Hawassa, Kilimani and Akatsi.
* The citizens often face long wait times for water, averaging more than 120 minutes:
  * Queues are very long on Saturdays.
  * Queues are longer in the mornings and evenings.
  * Wednesdays and Sundays have the shortest queues
    
The findings provided a clear picture of the current situation and helped understand areas of improvement to resolve the water crisis in Maji Ndogo. 

Sidenote: it was interesting determining fraudulent activities among some employees and discovering other unexpected insights.

## 3. [Top Football Players: Querying Data with SQL](https://github.com/hazelapondi/Data-Analytics-Portfolio-Projects/blob/main/SQL/football_players.sql)
![Group of sports players kneeling on a field](https://github.com/hazelapondi/Data-Analytics-Portfolio-Projects/blob/main/img/football_players.png)

I queried [a dataset](https://drive.google.com/file/d/1ZpBC71J-SFbA0tgJjWiNy58QA57YT1I8/view) (I got from [Frank’s blog](https://towardsdatascience.com/9-sql-core-concepts-that-helped-me-get-my-first-data-analyst-job-a582f892276f)) containing information about 100+ top football players and gained the insights below:

* The eldest player was born in 1981 and the youngest in 2000. A reminder that football’s narrative is written by players young and old.

* The average height of players is 182.79 cm, and the average weight stands at 78.10 kg.

* Most top players are between the ages 26 to 30, with 71 out of 148 players falling in this age group.

* Goalkeepers (GK) account for the highest number of top players, with a count of 22 players. On the flip side, the attacking midfielders on the right (RAM) and left (LAM) find themselves in solitary splendor, each with only one player.

* Brazil has 19 players, closely trailing behind Spain with 20 players. Many nations are represented by only one or two players. Whereas France and Germany both have 17 players each, while Italy and Argentina have 7 players.

* FC Barcelona and FC Bayern München both have a squad of 15 players. Followed by Real Madrid with 14 players. Among the other clubs featured Manchester City has 12 players, Liverpool has 8, Tottenham Hotspur has 6, Arsenal has 5, Chelsea has 3 and Manchester United has 2.

* Barcelona, Real Madrid, Manchester City, and Manchester United are the economic powerhouses, with average wages surpassing the 200-euro mark, while FC Bayern München stands strong at a little over 140 euros.

* Lionel Messi, Eden Hazard, Cristiano Ronaldo, Kevin De Bruyne, and Antoine Griezmann emerge as the top grossing players in terms of wages i.e. the highest earners.

* Neymar da Silva, Lionel Messi, Kylian Mbappé, Eden Hazard, Kevin De Bruyne, and Harry Kane emerge as the titans with the highest market values.

* The average wage-value ratio is 3.79, indicating the average player in the dataset earns approximately 3.79 times their market value annually.

## 4. [Investigating Netflix Data: Exploratory Data Analysis with Python](https://github.com/hazelapondi/Data-Analytics-Portfolio-Projects/blob/main/Python/investigating_netflix_movies.py)
![A computer screen showing a selection of movies on Netflix](https://github.com/hazelapondi/Data-Analytics-Portfolio-Projects/blob/main/img/netflix.png)

Netflix! What started in 1997 as a DVD rental service has since exploded into one of the largest entertainment and media companies. As of the fourth quarter of 2023, Netflix has approximately 260 million paid subscribers worldwide.

In this project, I conducted exploratory data analysis of Netflix movie data. (This is a DataCamp project). The hypothesis was that the average duration of movies has been declining. So I set out to determine whether movie lengths are actually getting shorter and what are some contributing factors, if any.

## The data
### **netflix_data.csv**
| Column | Description |
|--------|-------------|
| `show_id` | The ID of the show |
| `type` | Type of show |
| `title` | Title of the show |
| `director` | Director of the show |
| `cast` | Cast of the show |
| `country` | Country of origin |
| `date_added` | Date added to Netflix |
| `release_year` | Year of Netflix release |
| `duration` | Duration of the show in minutes |
| `description` | Description of the show |
| `genre` | Show genre |

While newer movies are overrepresented on the platform, many short movies have been released in the past two decades.
It also looks like many of the films under 60 minutes fall into genres such as "Children", "Stand-Up", and "Documentaries". This is a logical result, as these types of films are probably often shorter than standard 90 minute Hollywood blockbuster.

Closer inspection of our scatter plot ("Movie Duration by Year of Release") also reveals non-typical genres such as children's movies and documentaries are all clustered around the bottom half of the plot, this is not unexpected. Based on our plot, we cannot however conclude with certainty whether movies are actually getting shorter.
