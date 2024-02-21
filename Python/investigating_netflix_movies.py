#Importing pandas and matplotlib
import pandas as pd
import matplotlib.pyplot as plt

#Loading the CSV file and store as netflix_df
netflix_df = pd.read_csv("netflix_data.csv")

#Inspecting our DataFrame 
netflix_df.head()

#Filtering the data to remove TV shows and storing as netflix_subset
netflix_subset = netflix_df[netflix_df.type.eq('Movie')]

#Inspecting our DataFrame
netflix_subset.head()

#Selecting only columns of interest and saving into a new DataFrame called netflix_movies
netflix_movies = netflix_subset.loc[:,['title','country','genre','release_year','duration']]

#Inspecting our DataFrame
netflix_movies.head()

#Filtering netflix_movies to find the movies that are strictly shorter than 60 minutes, saving the resulting DataFrame as short_movies
short_movies = netflix_movies[netflix_movies['duration'] < 60]

#Inspecting our DataFrame
print(short_movies[0:20])

#Iterating through the rows of netflix_movies and assigning colors to the four genre groups
#define an empty list
colors = []

#iterate over rows of netflix_movies
for lab,row in netflix_movies.iterrows():
    if row['genre'] == 'Children':
        colors.append('blue')
    elif row['genre'] == 'Documentaries':
        colors.append('green')
    elif row['genre'] == 'Stand-Up':
        colors.append('yellow')
    else:
        colors.append('red')

#Inspecting our list
print(colors[0:5])

#initialize a figure object called fig with width 12 and height 8
fig = plt.figure(figsize=(12,8))

#plotting a scatter plot
plt.scatter(netflix_movies['release_year'],netflix_movies['duration'],color=colors)

#creating a title and axis labels
plt.title('Movie Duration by Year of Release')
plt.xlabel('Release year')
plt.ylabel('Duration (min)')

#showing the plot
plt.show()
