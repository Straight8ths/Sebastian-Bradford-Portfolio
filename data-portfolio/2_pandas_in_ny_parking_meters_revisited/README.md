# Pandas In New York: Parking Meters Revisited

Using pandas and related libraries to explore a different parking meter dataset, this time in NYC.

## Overview

After having so much fun with my first round of parking meter analysis in Excel, I wanted to attack the problem with more robust tooling. I've been fascinated with Python for some time, and pandas seemed like a good entry point for this task.

Last time, I used a large spreadsheet of parking meter transaction data from the City of San Francisco. For this iteration, I wanted to switch it up and analyze the meters of a different city (I chose New York City). Rather than analyzing revenue trends, this dataset is a regular inventory of all the city's meters and their locations.

## The Right Tool for the Job

In my Excel analysis, I used PivotTables as an unorthordox way of constructing a heatmap based around coordinate-centric data. The map used conditional formatting to visually display the dispersion of parking meter income across San Francisco.

While neat, this approach suffered drawbacks
- **Performance:** The map was difficult to navigate on account of its size, and could only be viewed when fully zoomed out in the workbook.
- **Customizability:** While Excel does offer great customization for its conditional formatting color schemes, reapllying a new scheme to this map took far to much labor.
- **Purity:** At the bottom of it, this was a rather impure use of what the PivotTable was designed for, and in my view the above two drawbacks were fully deserved.

In pandas, heatmaps of this nature are far easier to construct and customize.

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

## Creating a Heatmap

Let's watch pandas make short work of our heatmap issues from earlier.

To give our heatmap an acceptable resolution, let's take the values from the *Latitude* and *Longitude* columns and put them into bins via the *cut* method. I opted for 500 bins, so that the meters are grouped into geographic regions of moderate size, in order to get the full range of conditional formatting colors later on. If we had made too many bins, each bin would have contained fewer meters, and we would see a narrower range of color in the heatmap.

```python
df["lat_bin"] = pd.cut(df["Latitude"], bins=500).apply(lambda x: x.left)
df["lon_bin"] = pd.cut(df["Longitude"], bins=500).apply(lambda x: x.left)
```

The *apply* lambda method tacked onto each line makes it so that each latitude is displayed by the **start** of its respective bin, which will allow for more sensible heatmap axes later on.

Next, we create our pivot table. Just as before, we will want the latitudes of our meters as the rows of our table, and longitudes as the columns. Our original dataframe, *df*, is now a pivot table named *pv*.

In pandas, the aggfunc parameter functions just like Excel's "values" parameter when constructing a pivot table.

```python
pv = df.pivot_table(
    values="ObjectID", 
    index="lat_bin", 
    columns="lon_bin", 
    aggfunc="count",
    fill_value=0
)
```

Next, we sort the axes corresponding to our coordinate bins. We sort the longitude values (columns) by specifying a value of 1 for the *axis* argument. We also run the same line without the argument to sort the rows (latitudes) in descending order.

```python
pv = pv.sort_index(axis=1, ascending=True)
pv = pv.sort_index(ascending=False)
```

We build our initial heatmap using the *Seaborn* library, and name it *hm*.

```python
plt.figure(figsize=(10, 8))
hm = sns.heatmap(pv, cmap="hot", cbar_kws={'label':'Meter count')
```

Finally, we fiddle with layout, spacing, and typography until we are satisfied. I chose grey axes and a monospaced typeface to even out the visual flow of the plot.

```python
plt.title("Parking Meter Density", fontsize=22, fontweight="bold", color="Black", pad=10)
plt.xlabel("Longitude", fontsize=14, color="grey")
plt.ylabel("Latitude", fontsize=14, color="grey")
plt.xticks(fontsize=6, rotation=90, color="grey")
plt.yticks(fontsize=6, color="grey")
plt.tight_layout()
plt.rcParams['font.family'] = 'monospace'
```

Let's see our result:

> <img width="750" height="648" alt="Image" src="https://github.com/user-attachments/assets/068423f5-1733-4abd-95bd-c45e1660292b" />

Not too shabby!

Also, as an additional learning I had along the way: When working with integer-centric data like this (there can be no half-meters), we have the ability to access our plot's colorbar element and force it to display only integer labels, if for some reason it doesn't in the first place.

```python
colorbar = hm.collections[0].colorbar
colorbar.locator = mtc.MaxNLocator(integer=True)
colorbar.update_ticks()
```
