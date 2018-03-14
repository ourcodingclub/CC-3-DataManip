######################################################
# Tidy data and efficient manipulation               #
# Coding Club tutorial                               #  
# January 18th 2017                                  #
# Sandra Angers-Blondin (s.angers-blondin@ed.ac.uk)  #
######################################################

# Set your working directory to the folder where you have downloaded the course material

setwd("C:/ShrubHub/scripts/users/sangersblondin/Coding Club") # copy here the file path from your computer


# Load the relevant packages ----------------------------------------------
# **TIP: when you want to create an expandable section like this in your script, use Ctrl+Shift+R or go to Code -> Insert section

# You might need to install them before using the command install.packages("name of package")

library(dplyr) # an excellent data manipulation package
library(tidyr) # a package to format your data


# Import data -------------------------------------------------------------

seedling <- read.csv("Seedling_Elevation_Traits.csv") # seedling traits measured at various elevations 

elongation <- read.csv("EmpetrumElongation.csv", sep = ";") # stem elongation measurements on crowberry

germination <- read.csv("Germination.csv", sep = ";") # germination of seeds subjected to toxic solutions



# TIDYING DATA ------------------------------------------------------------

# The best way to arrange data is so that each row is an observation, and each column is a variable

# What can you see about the elongation dataframe? 
head(elongation)

# There is more than one observation per row (5 years of observations in each row. This is called wide format. To run most analyses (e.g. ANOVAs) in R, the data need to be in long format. For this you can use the gather() function from the tidyr package. (The function spread() does the reverse, going from long to wide format.)

elongation_long <- gather(elongation, Year, Length, c(X2007, X2008, X2009, X2010, X2011, X2012)) #gather() works like this: data, key, value, columns to gather. Here we want the lengths (value) to be gathered by year (key). Note that you are completely making up the names of the second and third arguments, unlike most functions in R.

head(elongation_long)

# Now you can perform standard operations and statistical tests on the data using year as a grouping factor. Let's make boxplots to visualise elongation for each year.
boxplot(Length ~ Year, data = elongation_long, xlab = "Year", ylab = "Elongation (cm)", main = "Annual growth of Empetrum hermaphroditum")

# Converting back to wide format
elongation_wide <- spread(elongation_long, Year, Length)


# MANIPULATING DATA -------------------------------------------------------

# The package dplyr has some very useful functions to subset dataframes or perform grouped operations. Let's have a look at the seed germination dataset

head(germination)


# You can use filter() to keep only certain rows of the dataset, using logical operators, factor levels, etc. For instance, say we only want the observations that were made for the species "SR"

germinSR <- filter(germination, Species == 'SR')


# You can combine conditions within filter(), for instance we could only keep the observations for the species SR where at least 10 seeds germinated

germinSR10 <- filter(germination, Species == 'SR', Nb_seeds_germin >= 10)


# The equivalent of filter() for columns is select(): it will keep only the variables you specify, calling  them by name (header)

germin_clean <- select(germination, Species, Treatment, Nb_seeds_germin)


# The mutate() function lets you create a new column, which is particularly useful if you want to create a variable from other data. For instance, let's calculate the germination percentage using the total number of seeds and the number of seeds that germinated. (Tip: you can simply give the column a name inside the function; if you don't, it will be called "Var1" and you will have to rename it later.)

germin_percent <- mutate(germination, Percent = Nb_seeds_germin / Nb_seeds_tot * 100)


# And another great function is summarise(), which lets you calculate summary statistics for your data. This will always return a dataframe shorter than the initial one and it is particularly useful when used with grouping factors (more on that in a minute). Let's just calculate the overall average germination percentage.

germin_average <- summarise(germin_percent, Germin_average = mean(Percent))


# That does not tell us anything about differences in species and treatments. We can use the group_by() function to tell dplyr to create different subsets of the data (e.g. for different sites, species, etc.) and to apply functions to each of these subsets. 

germin_grouped <- group_by(germin_percent, Species, Treatment) # this does not change the look of the dataframe but there is a grouping behind the scenes
germin_summary <- summarise(germin_grouped, Average = mean(Percent))

# Now let's remove the objects we will not be using again before moving on
rm(elongation_wide, germin_average, germin_clean, germin_grouped, germin_summary, germin_percent, germinSR10, germinSR)

# PIPING ------------------------------------------------------------------

# Piping is an efficient way of writing chains of commands in a linear way, feeding the output of the first step into the second and so on, until the desired output. It eliminates the need to create several temporary objects just to get to what you want, and you can write the code as you think it, instead of having to "think backwards". 

# The pipe operator is %>% . A pipe chain always starts with your initial dataframe, and then you apply a suite of functions. You don't have to call the object every time (which means you can drop the first argument of the dplyr functions), the result of a function will be fed to the next command. 

# Here we will start with the germination data and get to the summary we did last:
germin_summary <- germination %>%  # this is the dataframe 
  mutate(Percent = Nb_seeds_germin/Nb_seeds_tot * 100) %>% # we are creating the percentage variable
  group_by(Species, Treatment) %>% # introducing the grouping levels
  summarise(Average = mean(Percent),
            SD = sd(Percent)) # calculating the summary stats; you can do several at once

# Your turn: using the elongation_long object we created earlier, can you write a pipe that will produce a dataframe showing the average elongation and its standard deviation for each year and each zone? 




# CHALLENGE!! -------------------------------------------------------------

# Using the seedling (`Seedling_Traits.csv`) dataset, extract, only for the seedlings above 850 m elevation and possessing more than 3 leaves, the mean, maximum and minimum SPAD value at each site and for each species. You should be able to do this with one chain of pipes.
  # A SPAD is a machine which can estimate leaf chlorophyll content, by shining a light of a specific wavelength on the leaf.
  # `SPAD.mean` contains the mean of three measurements on a single leaf on each seedling. `SPAD.SD` is the standard deviation of those measurements.
  # This dataset was used to investigate the effect of adult tree competition on tree seedling stress levels. Low chlorophyll content is indicative of seedling stress. 




