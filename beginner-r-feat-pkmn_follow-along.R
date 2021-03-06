# Thanks to Tamsin, who prepared this file
# This document may change as the main document changes
# Main doc at https://matt-dray.github.io/beginner-r-feat-pkmn/

#this script has been taken from section 5-8 of the online tutorial 
#'Beginner R and RStudio training' by Matt Dray (DfE)
#at the following web address
#https://matt-dray.github.io/beginner-r-feat-pkmn/#5_get_data_in_and_look_at_it
  
#install required packages if not already installed
#install.packages('tidyverse') #note quotes

#load required packages, note no quotes
library(tidyverse)
#tidyverse is a collection of packages, including, but not limited to
#dplyr, ggplot, readr, stringr, tibble

#throughout this I have tried to be explicit about 
#which package each funciton comes from
#all the function calls are in the form
#package_name::function_name()
#however, if function name is unique, within the packages loaded
#then you don't need to declare the package_name 
#and can just use the function_name

#to find out more about a function simply type ?function_name, eg
?read_csv
#or explicitly
?readr::read_csv

#read in data and asign to the newly created object 'pokemon'
pokemon <- readr::read_csv(file = "data/pokemon_go_captures.csv")

#data inspection
tibble::glimpse(pokemon)

#print to console
print(pokemon)

#view data
View(pokemon) # note the capital 'V'

#summary {base} stats
base::summary(pokemon)



# dplyr functions ---------------------------------------------------------

#dplyr::select
# save as an object for later
pokemon_hp <- dplyr::select( 
  pokemon,  # the first argument is always the data
  hit_points,  # the other arguments are column names you want to keep
  species
)  

print(pokemon_hp)

#select by dropping columns
select(
  pokemon,  # data frame first
  -hit_points, -combat_power, -fast_attack, -weight_bin  # columns to drop
)

#select columns with similar names
select(pokemon, starts_with("weight"))

select(pokemon, contains("bin"))

#see 
?dplyr::select_helpers

# CHALLENGE!
#   Create an object called my_selection that uses the select() function 
# to store from  pokemon the species column and any columns that end with 
# with "attack"

#dplyr::filter
#logical operators
# 
# ==      equals
# !=      not equals
# %in%    match to several things listed with c()
# >, >=   greater than (or equal to)
# <, <=   less than (or equal to)
# &       âandâ
# |       âorâ

#filter on a single species
dplyr::filter(pokemon, species == "jigglypuff")

#now everything except for one species
dply::filter(pokemon, species != "pidgey")  # not equal to

#filter on three species
dplyr::filter(
  pokemon,
  species %in% c("staryu", "psyduck", "charmander")
)

#we can work with numbers too
dplyr::filter(
  pokemon,
  combat_power > 900 & hit_points < 100  # two conditions
)  # note the '&'

# CHALLENGE!
#   
#Filter the pokemon dataframe to include species rows that:
#   
# are the species âabraâ, âchanseyâ, or âbellsproutâ
# and have greater than 100 combat_power
# or less than 100 hit_points

#dplyr::mutate
# we're going to subset by columns first
pokemon_power_hp <- select(  # create new object by subsetting our data set
  pokemon,  # data
  species, combat_power, hit_points  # columns to keep
)

# now to mutate with some extra information
mutate(
  pokemon_power_hp,  # our new, subsetted data frame
  power_index = combat_power * hit_points,  # new column from old ones
  caught = 1,  # new column will fill entirely with number
  area = "kanto"  # will fill entirely with this text 
)


# So we have a column caught filled for every row with 1 and and a
# column filled with  kanto for every row. R ârecyclesâ whatever you
# put there for each row. For example, if you gave the argument a
# vector of three numbers, e.g. caught = c(1:3), then the row 1 would
# get 1, row 2 would get 2, row 3 would get 3 and it would cycle back
# to 1 for row 4, and so on.
# 
# You can mutate a little more easily with an if_else() statement:
dplyr::mutate(
  pokemon_hp,
  common = if_else(
    condition = species %in% c(  # if this condition is met...
      "pidgey", "rattata", "drowzee", 
      "spearow", "magikarp", "weedle", 
      "staryu", "psyduck", "eevee"
    ),
    true = "yes",  # ...fill column with this string
    false = "no"  # ...otherwise fill it with this string
  )
)

# And we can get more nuanced by using a case_when() statement 
# (you may have seen this in SQL). This prevents us writing nested if_else() statements to specify multiple conditions.

dplyr::mutate(
  pokemon_hp,  # data
  common = dplyr::case_when(
    species %in% c("pidgey", "rattata", "drowzee") ~ "very_common",
    species == "spearow" ~ "pretty_common",
    species %in% c("magikarp", "weedle", "staryu", "psyduck") ~ "common",
    species == "eevee" ~ "less_common",
    TRUE ~ "no" #else = "no"
  )
)
# 
# CHALLENGE!
# Create a new datafrmae object that takes the pokemon data and adds a 
# column containing Pokemon body-mass index (BMI).
# 
# Hint: BMI is weight over height squared (you can square a number by 
# writing ^2 after it).
# 
# Now use a case_when() to categorise Pokemon:
#   
# Underweight = <18.5
# Normal weight = 18.5â24.9
# Overweight = 25â29.9
# Obesity = BMI of 30 or greater
# Note that these are BMI groups for humans. 

#dplyr::arrange
dplyr::arrange(
  pokemon,  # again, data first
  height_m  # column to order by
)

#And in reverse order (tallest first):
dplyr::arrange(pokemon, desc(height_m))  # descending
# 
# CHALLENGE!
# What happens if you arrange by a column containing characters rather 
# than numbers? For example, the species column.

#dplyr::join
# 
# Again, another verb that mirrors what you can find in SQL. There are 
# several types of join, but weâre going to focus on the most common one:
# the left_join(). This joins information from one table â x â to 
# another â y â by some key matching variable of our choice.
# 
# Letâs start by reading in a lookup table that provides some extra 
# infomration about our species.

pokedex <- readr::read_csv("data/pokedex_simple.csv")
tibble::glimpse(pokedex)  # let's inspect its contents

# Now weâre going to join this new data to our pokemon data. The key 
# or matching these in the species column, which exists in both datasets.

pokemon_join <- dplyr::left_join(
  x = pokemon,  # to this table...
  y = pokedex,   # ...join this table
  by = "species"  # on this key
)

tibble::glimpse(pokemon_join)
# 
# CHALLENGE!
# Try right_join() instead of left_join(). What happens? And what 
# about  anti_join()?

# Other verbs
# This document does not contain an exhaustive list of other functions 
# within the same family as select(), filter(), mutate(), arrange() and
# *_join(). There are other functions that will be useful for your work 
# and other ways of manipulating your data. For example, the stringr 
# package helps with dealing with data in strings (text, for example).
# 
# Pipes
# Alright great, weâve seen how to manipulate our dataframe a bit. But 
# weâve been doing it one discrete step at a time, so your script might 
# end up looking something like this:

pokemon <- read_csv(file = "data/pokemon_go_captures.csv")

pokemon_select <- select(pokemon, -height_bin, -weight_bin)

pokemon_filter <- filter(pokemon_select, weight_kg > 15)

pokemon_mutate <- mutate(pokemon_filter, organism = "pokemon")

# In other words, you might end up creating lots of intermediate 
# variables and cluttering up your workspace and filling up memory.
# 
# You could do all this in one step by nesting each function inside 
# the others, but that would be super messy and hard to read. Instead 
# weâre going to âpipeâ data from one function to the next. The pipe 
# operator â %>% â says âtake whatâs on the left and pass it through 
# to the next functionâ.
# 
# So you can do it all in one step:
  
pokemon_piped <- readr::read_csv(file = "data/pokemon_go_captures.csv") %>% 
  dplyr::select(-height_bin, -weight_bin) %>% 
  dplyr::filter(weight_kg > 15) %>% 
  dplyr::mutate(organism = "pokemon")

tibble::glimpse(pokemon_piped)

# This reads as:
# for the object named pokemon_piped, assign (<-) the contents of a CSV file read 
# with readr::read_csv()
# then select out some columns
# then filter on a variable
# then add a column
# See how this is like a recipe?
#   
# Did you notice something? We didnât have to keep calling the dataframe object 
# in each function call. For example, we used dplyr::filter(weight_kg > 15) rather than  
# dplyr::filter(pokemon, weight_kg > 15) because the data argument was piped in. The 
# functions mentioned above all accept the data thatâs being passed into them 
# because theyâre part of the Tidyverse. (Note that this is not true for all 
# functions, but we can talk about that later.)
# 
# Hereâs another simple example using a datafram that we built ourselves:
#   
my_df <- data.frame(
    species = c("Pichu", "Pikachu", "Raichu"),
    number = c(172, 25, 26),
    location = c("Johto", "Kanto", "Kanto")
  )

my_df %>%  # take the dataframe object...
  dplyr::select(species, number) %>%   # ...then select these columns...
  dplyr::filter(number %in% c(172, 26))  # ...then filter on these values
# 
# CHALLENGE!
# Write a pipe recipe that creates a new dataframe called my_poke that takes the 
# pokemon dataframe and:
#   
# select()s only the species and combat_power columns
# left_join()s the pokedex dataframe by species
# filter()s by those with a type1 thatâs ânormalâ


# Summaries ---------------------------------------------------------------
# Assuming weâve now wrangled out data using the dplyr functions, we can do some quick, 
# readable summarisation thatâs way better than the summary() function.
# 
# So letâs use our knowledge â and some new functions â to get the top 5 pokemon by count.

pokemon %>%  # take the dataframe
  dplyr::group_by(species) %>%   # group it by species
  dplyr::tally() %>%   # tally up (count) the number of instances
  dplyr::arrange(desc(n)) %>%  # arrange in descending order
  dplyr::slice(1:5)  # and slice out the first five rows

# The order of your functions is important â remember itâs like a recipe. Donât crack 
# the eggs on your cake just before serving. Do it near the beginning somewhere, I guess 
# (Iâm not much a cake maker).
# 
# Thereâs also a specific summarise() function that allows you to, wellâ¦ summarise.

pokemon_join %>%  # take the dataframe
  dplyr::group_by(type1) %>%   # group by variable
  dplyr::summarise( # summarise it by...
    count = n(),  # counting the number
    mean_cp = round(mean(combat_power), 0)  # and taking a mean to nearest whole number
  ) %>% 
  dplyr::arrange(desc(mean_cp))  # then organise in descending order of this column

# 
# Note that you can group by more than one thing as well. We can group on the  weight_bin 
# category within the type1 category, for example.

pokemon_join %>%
  dplyr::group_by(type1, weight_bin) %>% 
  dplyr::summarise(
    mean_weight = mean(weight_kg),
    count = n()
  )

# Plot the data
# Weâre going to keep this very short and dangle it like a rare candy 
# in front of your nose. Weâll revisit this in more depth in a later 
# session. For now, weâre going to use a package called ggplot2 to 
# create some simple charts.

# CHALLENGE!
# The âggâ in âggplot2â stands for âgrammar of graphicsâ. This is a
# way of thinking about plotting as having a âgrammarâ â âelements 
# that can be applied in succession to create a plot. This is âthe 
# idea that you can build every graph from the same few componentsâ: 
# a data set, geoms (marks representing data points), a co-ordinate 
# system and some other things.
# 
# The ggplot() function from the ggplot2 package is how you create 
# these plots. You build up the graphical elements using the + rather 
# than a pipe. Think about it as placing down a canvas and then adding
# layers on top.

pokemon %>%
  ggplot2::ggplot() +
  ggplot2::geom_boxplot(aes(x = weight_bin, y = combat_power))

# ggplot plays nicely with the pipe â itâs part of the Tidyverse â 
# so we can create recipes that combine data reading, data manipulation
# and plotting all in one go. Letâs do some manipulation before 
# plotting and then introduce some new elements to our plot that 
# simplify the theme and change the labels.

pokemon_join %>%
  dplyr::filter(type1 %in% c("fire", "water", "grass")) %>% 
  ggplot2::ggplot() +
  ggplot2::geom_violin(aes(x = type1, y = combat_power)) +
  ggplot2::theme_bw() +
  ggplot2::labs(
    title = "CP by type",
    x = "Primary type",
    y = "Combat power"
  )

#How about a dotplot? Coloured by type1?
  
pokemon_join %>%
  dplyr::filter(type1 %in% c("fire", "water", "grass")) %>%
  ggplot2::ggplot() +
  ggplot2::geom_point(aes(x = pokedex_number, y = height_m, colour = type1))
# 
# CHALLENGE!
# Create a boxplot for Pokemon with type1 of ânormalâ, âpoisonâ, 
# âgroundâ and âwaterâ against their hit-points


#fin
