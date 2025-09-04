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

This dataset is a continuously updated feed of *every transaction* logged across the parking meter network of San Francisco. At last count, the dataset contains 198 million rows which can be queried and exported as the user desires. One week's worth of transaction data ends up occupying about 300,000 rows, so I have chosen to analyze this data in one-week blocks.

### Following is a collection of my observations and conclusions drawn from this data. I selected a random week of this year to analyze, which ended up being **May 11th to May 17th, 2025.**

# Nomenclature

There are a few coventions to cover before diving into the data.

1. Post IDs
   - Each individual meter gets its own identification number, called its "post ID". The City features this ID in the low-level data, which allows us to examine trends on the meter-level.

2. A Companion Dataset
   - We will need to pull in a **second** data source from the database in order to analyze parking meters more deeply. The reason is that the Revenue Transactions dataset focuses only on transactions that occured, but does not tell us much about the individual meters themselves. This is where the above point about Post IDs comes in handy. There is a second dataset published by the City, simply called "Parking Meters", which lists the full inventory of meters managed by the City, along with their coordinates, neighborhood codes, and most importantly **their Post IDs**. Using this as a common vector between the two sets, we can merge them and greatly augment our analysis.
  
> <img width="400" height="409" alt="Meter data merge" src="https://github.com/user-attachments/assets/96d15a68-f57f-40dc-9a05-c82dff64f9bb" />

# General Statistics

- Number of transactions: 322,260
- Gross transaction revenue: $955,500.74

> <img width="600" height="322" alt="Screenshot 2025-09-03 at 4 32 32 PM" src="https://github.com/user-attachments/assets/333a26d5-2fb6-4fcf-bdb6-028b6d317a3a" />

> <img width="600" height="318" alt="Screenshot 2025-09-03 at 4 32 44 PM" src="https://github.com/user-attachments/assets/cf6db847-c434-4f0d-8224-6f110c3151ab" />

# Big Winners and Big Losers

A list of this magnitude, featuring thousands of individual parking meters, begs the question; Which meters brought in the most and least revenue, and how shapely is the distribution?

Let's use a PivotTable to investigate the most lucrative meters over the course of our entire week...

> <img width="900" height="428" alt="Screenshot 2025-09-03 at 8 15 39 PM" src="https://github.com/user-attachments/assets/81125c4b-a9c8-45f9-8120-95904b539a25" />

For starters, meter #916-00001 deserves a standing ovation. Of the 13,366 unique meters which were present in this week's dataset, this single meter brought in over 1% of the entire system's revenue *by itself*.

However, there is more to the story than that. If we view the Pierce Street Garage on Google Street View, we actually see a set of *three separate meters* positioned in front of the garage, all labeled with the same Post ID of 916-00001. So, even though it is not the case that we have a single absurdly productive meter at the top of the heap, if we divide the revenue from this Post ID into its three constituent parts, *we still see three meters that are performing at the top of the revenue distribution anyway.*

Let's investigate the meters that drew the least revenue...

> <img width="900" height="367" alt="Screenshot 2025-09-03 at 8 36 54 PM" src="https://github.com/user-attachments/assets/2498b9bd-e382-4fa0-a2e3-bf7c84a719c4" />

This list hurts to look at. Some of the meters on this list were outright neglected over the course of the week. But how many meters in total are in this camp? Let's use =COUNTIFS to see how many meters made $1 or less over the course of the full week.

> <img width="400" height="38" alt="Screenshot 2025-09-03 at 8 42 10 PM" src="https://github.com/user-attachments/assets/7e4727eb-9b99-4778-9438-0dbb16f0a438" />

The final answer: 372. If we consider the full fleet of 13,366 meters that were used this week, this means that 2.8% of meters made *a single dollar or less over **seven days***. This prompts questions about the prioritization of the City's resources, and if the fleet of meters should be trimmed when the City sees substantial long-term underperformance of their assets.

# The 9AM Surge

Because each transaction is provided with its timestamp, we can examine how parking revenue evolves over the course of a day. I created a very tall PivotTable from the data, where each row represented individual minutes, as well as the revenue collected in that minute. If we choose to isolate a random weekday from this dataset, say Monday May 12th, we see that there is an unusual spike of revenue **at exactly 9:00 AM**.

The following graph depicts this spike, where each small bar represents a given minute's worth of collected revenue.

> <img width="1100" height="497" alt="Screenshot 2025-09-03 at 8 56 46 PM" src="https://github.com/user-attachments/assets/4b6a94e5-b67e-492f-a94e-9c457aa809e9" />

To put this spike into perspective, we can consult the data to find out that on Monday May 12th, the day's total revenue was $166,199.10. Therefore, this spike of approximately $8,000 at 9AM corresponds to 4.82% of the entire day's revenue, all captured within **one minute.**

Why might this be? To look for answers, we can dive even deeper into the level of individual seconds. If we investigate our PivotTable farther, and explore the various layers of hours, minutes, and seconds, we see a fascinating result.

> <img width="400" height="200" alt="Screenshot 2025-09-03 at 7 46 50 PM" src="https://github.com/user-attachments/assets/8d4b3824-fdb8-47c2-9956-1d7e614910b8" />

While the City makes 4.8% of the day's revenue in the minute of 9:00AM, it turns out that nearly all of that revenue is actually captured in the **single second** of 9:00:00 exactly. The fact that this much transaction volume is occuring within one second suggests that we are seeing the effects of some kind of automated system. And sure enough, further research taught me that parking meters in San Francisco can be reserved and prepaid by way of the PayByPhone parking app. In the data, this spike represents the large number of prepaid meters which become active at 9AM when enforcement begins.

The SFMTA includes a write-up on prepaid parking at [this page](https://www.sfmta.com/getting-around/drive-park/parking-meters/pay-browser).

> <img width="400" height="176" alt="Screenshot 2025-09-03 at 7 52 40 PM" src="https://github.com/user-attachments/assets/01ffb815-2248-4e10-930c-0c9412c04139" />

Herein lies a prime example of how enormous datasets can rise above being mere numbers and instead paint a picture for us users as to how a given system behaves and "breathes" as it operates. By using this dataset, I was able to learn a completely new fact about the City's civic architecture using only a spreadsheet and some intuition.

# Geographic Distribution

Let's push the humble PivotTable closer to its limits in order to get the most out of this data. We're going to use the PivotTable engine, as well as some formatting tricks, to build **a revenue heatmap from scratch.**

Each row in our final table will correspond to a given latitude value, and the columns will similarly display longitudes. At the intersection of each set of values, we will display the revenue gathered at that location, from all meters within the bounds of that intersection. When repeated over the course of all latitudes and longitudes in our dataset, we will come out with a low-resolution heatmap of parking revenue, powered by conditional formatting.

## Step 1: Latitude and Longitude

Thanks to our earlier work of bringing over the identification data for each individual meter, we can tag each transaction in our set with the coordinates of the meter that received it. However, the coordinate data provided to us by the City of San Francisco is *too precise*. In our source data, we are given coordinates at *10 digits of precision.*

<img width="500" height="254" alt="Screenshot 2025-09-03 at 9 14 10 PM" src="https://github.com/user-attachments/assets/f6336598-ad7f-4623-bfaa-274ceecde3d7" />

Because we will be making our map in a PivotTable, we need to obey the corresponding row limits, and including a row for each latitude or longitude value at 10 digits of precision would exceed the rows available to us. Plus, a map made at that level of precision would barely be different from a table of the values themselves, due to the geographic uniqueness of each individual meter's coordinates. If we want to design a heatmap, and study how the data behaves when it is grouped and displayed in space, we will need to reduce our precision.

To make this happen in our source data, we need to use the uncommon but useful =TRUNC. This allows us to simply clip off certain digits of precision without worrying about the implications of rounding the coordinate values with =ROUNDDOWN or =ROUNDUP.

## Step 2: Size Constraints

In order to figure out how much to trim our coordinate values by, we need to understand how many data points will be present in the final map depending on what level of precision we choose. To do this, I created columns next to the raw latitude and longitude values, and used =TRUNC to create copies of the values at different precision levels (for example, the column titled LONG-4 contains longitude values at 4 digits of precision).

<img width="1100" height="341" alt="Screenshot 2025-09-03 at 9 36 12 PM" src="https://github.com/user-attachments/assets/40cf37ae-6858-4769-85fa-131da032cc93" />

My instincts told me that around four to five digits would yield enough resolution without breaking the PivotTable. To validate this, we can create a PivotTable from our dataset, and put our adjustable-length columns into it, which will strip out duplicates and allow us to make a final count.

**4** digits of precision - **893** unique lat. and long. values

**5** digits of precision - **6,733** unique lat. and long. values

## Step 3: The Three-Semicolon Trick

## Step 4: Conditional Formatting (with intention)

# A Look at Neighborhoods

## By Revenue Contribution

> <img width="400" height="683" alt="Screenshot 2025-09-03 at 6 25 31 PM" src="https://github.com/user-attachments/assets/8ae887e2-2481-4c40-bb93-72f71ba18af1" />

## By Transaction Volume

> <img width="400" height="649" alt="Screenshot 2025-09-03 at 6 29 27 PM" src="https://github.com/user-attachments/assets/42633a90-ff50-4bd5-9d76-b249d73e5d3b" />

## Notes
As one would expect, the more upscale neighborhoods of SF closer to downtown see greater transaction volumes and revenues. However, this brings up an interesting fact about the other end of the spectrum; There are a decent number of neighborhoods which simultaneously contribute less than 1% of the City's transaction count, as well as less than 1% of the City's parking revenue. This raises a question of financial strategy, due to the fact that the parking meters in these low-performing neighborhoods must be serviced and maintained like any others in the fleet. Would the City see greater success trying to divert more pedestrian activity into these areas, or to phase out these low-performing meters due to their negligible impact on the City's bottom line.

## Visualizing the Low-Performing Neighborhoods

In this figure, all neighborhoods below the thick dividing line contribute both less than 1% of revenues as well as transaction volumes.

> <img width="700" height="661" alt="Screenshot 2025-09-03 at 6 50 11 PM" src="https://github.com/user-attachments/assets/699569c4-84d1-4fda-b8fd-0f048077f5d1" />

