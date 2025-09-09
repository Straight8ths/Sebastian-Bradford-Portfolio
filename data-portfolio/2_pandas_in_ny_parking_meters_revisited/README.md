# Pandas In New York: Parking Meters Revisited

Using pandas and related libraries to explore a different parking meter dataset, this time in NYC.

## Overview

After having so much fun with my first round of parking meter analysis in Excel, I wanted to attack the problem with more robust tooling. I've been fascinated with Python for some time, and *pandas* seemed like a good entry point for this task.

Last time, I used a large spreadsheet of parking meter transaction data from the City of San Francisco. For this iteration, I wanted to switch it up and analyze the meters of a different city (I chose NYC). Rather than 

## The Right Tool for the Job

In my Excel analysis, I used PivotTables as an unorthordox way of constructing a heatmap based around coordinate-centric data. The map used conditional formatting to visually display the dispersion of parking meter income across San Francisco.

While neat, this approach suffered drawbacks
- Performance: The map was difficult to navigate on account of its size, and could only be viewed when fully zoomed out in the workbook.
- Customizability: While Excel does offer great customization for its conditional formatting color schemes, reapllying a new scheme to this map took far to much labor.
- Purity: At the bottom of it, this was a rather impure use of what the PivotTable was designed for, and in my view the above two drawbacks were fully deserved.

In *pandas*, heatmaps of this nature are far easier to construct and customize. The dataset we will use today is not based around meter revenue, and instead just a coordinate-based inventory of the city's meters and their locations.

## Getting Acquainted

I chose standard naming conventions for imports:
```python
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
```

To get acquainted with our new dataset, let's run some lines to see our columns, as well as the head of the table.

```python
print([column for column in df.columns])
```
> ['ObjectID', 'Meter Number', 'Status', 'Pay By Cell Number', 'Meter_Hours', 'Parking_Facility_Name', 'Facility', 'Borough', 'On_Street', 'Side_of_Street', 'From_Street', 'To_Street', 'Latitude', 'Longitude', 'X', 'Y', 'Location']

```python
print(df.head(5))
```
> <img width="1346" height="65" alt="Image" src="https://github.com/user-attachments/assets/2e114885-7beb-484c-a71f-08f516046797" />

