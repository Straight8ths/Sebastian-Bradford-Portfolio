# Parking Meters: A Love Story

An idle curiosity turned passion project.

<img width="500" height="500" alt="SF Parking Meter" src="https://github.com/user-attachments/assets/e986b573-5777-4eff-8646-cc6272e983be" />

## Overview

Some time ago, I was looking for ways to sharpen my Excel skills outside of work, with a focus on the manipulation of large and irregular datasets. Eventually, I found SF Open Data, the central repository of city-wide data managed by the City of San Francisco. This database is filled with intriguing datasets, including:
- Aicraft Passenger Statistics
- Film Locations in San Francisco
- Temporary Street Closures

and my personal favorite...
- **SFMTA Parking Meter Detailed Revenue Transactions**

This dataset is a continuously updated feed of *every transaction* logged across the parking meter network of San Francisco. At last count, the dataset contains 198 million rows which can be queried and exported as the user desires. One week's worth of transaction data ends up occupying about 300,000 rows, so I have chosen to analyze this data in one-week blocks. Following is a collection of my observations and conclusions drawn from this data. I selected a random week of this year to analyze, which ended up being **May 11th to May 17th, 2025.**

# Nomenclature

There are a few coventions to cover before diving into the data.

1. Post IDs
   - Each individual meter gets its own identification number, called its "post ID". The City features this ID in the low-level data, which allows us to examine trends on the meter-level.

2. A Companion Dataset
   - We will need to pull in a **second** data source from the database in order to analyze parking meters more deeply. The reason is that the Revenue Transactions dataset focuses only on transactions that occured, but does not tell us much about the individual meters themselves. This is where the above point about Post IDs comes in handy. There is a second dataset published by the City, simply called "Parking Meters", which lists the full inventory of meters managed by the City, along with their coordinates, neighborhood codes, and most importantly **their Post IDs**. Using this as a common vector between the two sets, we can merge them and greatly augment our analysis.

# General Statistics

- Number of transactions: 322,260
- Gross amount paid: $955,500.74


# Big Winners and Big Losers

# The 9AM Surge

# Geographic Distribution

# A Look at Neighborhoods
