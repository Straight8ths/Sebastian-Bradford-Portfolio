## Intraday Movement vs. Return

Using `yfinance` and `pandas` to make short work of a visualization I used to do in Excel.

## Overview

I was curious about the relationship between a security's intraday price movement **(high-low as a percentage of open price)** and its return for that day.

Imports:
```python
import yfinance as yf
import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator
import seaborn as sns
import pandas as pd
import numpy as np
import calendar
from pandas.tseries.offsets import DateOffset
from initial_tools import download_data # To use my download_data() function from earlier.
```

## A Note on Returns Data

Note: In my *initial-tooling* exhibit, I talked about how the yfinance API was not giving me satisfactory results for getting a stock's open price, and that to compensate, I was using the previous day's close as a stand-in for the current day's open. This exhibit will use the same methodology, because in practice, this method has actually delivered me results that I know to be true.

Consider the date of **May 25, 2023**, when NVDA closed with 24% returns. The day itself is described in [this article](https://www.reuters.com/markets/us/nasdaq-futures-jump-nvidia-leads-ai-driven-rally-2023-05-25/).

Let's call our `download_data` function from the *initial-tooling* exhibit, and get data for NVDA from that date.

```python
data = download_data('NVDA', '2023-05-25', '2023-05-25')
```

```python
Price       Date  Prev_Close       Open      Close  Open_to_Close_Return  Close_to_Close_Return
0     2023-05-25   30.514339  38.493155  37.950577             -0.014095               0.243696
```

Sure enough, a strict open-to-close return measurement actually shows a small loss for that day, whereas the close-to-close return method confirms the data given by the financial press. Let's go back to the exhibit.

## Process

To add the intraday price movement, I went back and modified my `download_data()` function to include a calculation for intraday movement, which I am defining as `(high - low) / prev_close`. For future reference, here is the updated `download_data()` function:

```python
def download_data(ticker, start, end):
    df = yf.download(ticker, pd.Timestamp(start)-DateOffset(days=10), pd.Timestamp(end)+DateOffset(days=1))
    df.columns = df.columns.droplevel(1)
    df.reset_index(inplace=True)
    df['Year'] = df['Date'].dt.year
    df['Month'] = df['Date'].dt.month
    df['Day'] = df['Date'].dt.day
    df['Prev_Close'] = df['Close'].shift(1)
    df['Daily_Return'] = (df['Close'] / df['Prev_Close']) - 1
    df['Intraday_Movement'] = (df['High'] - df['Low']) / df['Prev_Close'] # New column for intraday movement
    df = df[df['Date'] >= start][['Date', 'Year', 'Month', 'Day', 'Prev_Close', 'Open', 'High', 'Low', 'Close', 'Intraday_Movement', 'Daily_Return', 'Volume']] # Adding the new column in the selection
    df.reset_index(drop=True, inplace=True)
    return df
```

## Visualization

We begin with a visualization for one stock. To do our future selves a favor, we will build the function to accept multiple tickers and overlay a scatterplot for each one, but at first we will analyze one only. We start with summoning a figure and axis object to store our data.

```python
def single_year_multi_tickers(year, *tickers):
    fig, ax1 = plt.subplots(figsize=(8, 9))
```

Next, we set up a for loop iterate through our ticker and write each of their scatterplots onto the `ax1` object. Our for loop begins with creating a placeholder variable to store each stock's downloaded data, and then plots the scatterplot before looping again.

```python
 for ticker in tickers:
        df = download_data(ticker, f'{year}-01-01', f'{year}-12-31')
        ax1.scatter(df['Intraday_Movement'], df['Daily_Return'], alpha=0.7, edgecolors='w', s=100)
```

Next, we adjust our aesthetics and layout. Additional conveniences include a horizontal like at y=0 to separate gains from losses, as well as a legend that runs off of a list comprehension to make sure any number of tickers can be represented.

```python
    plt.title(f'Intraday Movement vs. Daily Return for {year}', fontsize=16, fontweight='bold', pad=20)
    plt.xlabel('Intraday Movement', fontsize=14)
    plt.ylabel('Daily Return', fontsize=14)
    plt.xticks(rotation=90, fontsize=10, color='grey')
    ax1.xaxis.set_major_locator(MultipleLocator(0.01))
    plt.yticks(fontsize=10, color='grey')
    plt.axhline(0, color='black', linestyle='--')
    plt.legend([ticker for ticker in tickers], fontsize=12)
    plt.fontfamily = 'monospace'
    plt.show()
```

Let's pick NVDA as our stock of choice, and plot its data for 2023.

```python
print(single_year_multi_tickers(2023, 'NVDA'))
```

Alright, we're off to a good start. It's interesting to observe the fan-shaped distribution, and how, broadly speaking, we can see higher intraday movement bringing higher-magnitude returns, whether positive or negative.

Let's compare this against another stock. To demonstrate the breadth of this measurement, I picked a comparatively tamer stock from a different GICS sector, **UnitedHealth Group**.

Let's take advantage of our multi-ticker capabilities and plot these two against each other for the same year.

```python
print(single_year_multi_tickers(2023, 'NVDA', 'UNH'))
```

As we may have expected, UNH demonstrates far more stability with a more tighly packed distribution.

Let's explore another angle of this idea. Rather than plotting stocks against each other, let's construct a way to examine one stock over multiple years. To do this, we will need to add a Z axis to our scatterplot, select a range of years to measure, and use each year's scatterplot as a different Z-layer.

## The Third Dimension

To make this process more scale-invariant, I went back to my initial `download_data()` function and added a calculation for intraday movement, so that the calculation would be bundled in whenever the function was called. With that in mind, let's begin our plotting function. We first summon a figure and an axis object with a projection parameter of `3d`.

```python
def multi_year_single_ticker(start_year, end_year, ticker):
    fig = plt.figure(figsize=(8, 9))
    ax1 = fig.add_subplot(111, projection='3d')
```

Next, we use a for loop to download and plot the data for each year that was passed in. The first line inside the loop creates a variable with a standard naming convention of `{ticker}_data_{year}`, and the second line plots the scatterplot using the `eval()` function to read each string as an expression. The `globals()` function is used to account for differences in the scope we've established.

```python
for year in range(start_year, end_year + 1):
        globals()[f"{ticker}_data_{year}"] = download_data(ticker, f'{year}-01-01', f'{year}-12-31')
        ax1.scatter(globals()[f"{ticker}_data_{year}"]['Intraday_Movement'], globals()[f"{ticker}_data_{year}"]['Daily_Return'], globals()[f"{ticker}_data_{year}"]['Year'], alpha=0.6, edgecolors='w')
```

Now that the majority of the work is done, we adjust our axes, titling, and legend.

```python
    ax1.set_title(f'Intraday Movement vs. Daily Return for {ticker} - {start_year} to {end_year}', fontsize=12, fontweight='bold', pad=20)
    ax1.set_xlabel('Intraday Movement', fontsize=10, labelpad=10)
    ax1.set_ylabel('Daily Return', fontsize=10, labelpad=10)
    ax1.set_zlabel('Year', fontsize=10, labelpad=10)
    ax1.xaxis.set_major_locator(MultipleLocator(0.01))
    ax1.yaxis.set_major_locator(MultipleLocator(0.01))
    ax1.zaxis.set_major_locator(MultipleLocator(1))
    plt.xticks(rotation=90, fontsize=8, color='grey')
    plt.yticks(fontsize=8, color='grey')
    plt.legend([f"{year}" for year in range(start_year, end_year + 1)], fontsize=10)
    plt.fontfamily = 'monospace'
    plt.show()
```

Let's call this function for multiple years of NVDA data and see what we've got.

```python
print(multi_year_single_ticker(2021, 2023, 'NVDA'))
```

>

Fascinating! Our plots have worked as intended, and now we can see broader trends about the price action and return of this stock. For example, knowing that 2022 was a particularly hard year for NVDA, we can easily spot this in the plotted data by comparing the breadth of the year's clustering to the year before and after.

For reference, here are the **individual** plots for each year, with the same color-coding.

>

>

>