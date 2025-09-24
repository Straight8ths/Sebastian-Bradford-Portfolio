# Initial Tooling

How I approach the yfinance library to construct base-level tools for later projects.

## Overview

Functionalities to build:
- Downloading stock data
- Calculating monthly returns
- Introducing return comparisons
- Calculating and comparing betas

## Downloading Stock Data

Standard imports, with the addition of the `calendar` module to make time series construction easier:

```python
import yfinance as yf
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from pandas.tseries.offsets import DateOffset
import numpy as np
import calendar
```

We first build our root-level function to download historical data. We start with a DataFrame to hold the default output from the YahooFinance API.

```python
def download_data(ticker, start, end):
    # Download data from Yahoo Finance
    df = yf.download(ticker, pd.Timestamp(start)-DateOffset(days=10), pd.Timestamp(end)+DateOffset(days=1))
```

The reason for the date adjustments is to ensure that our `start` and `end` dates are **inclusive** in the function call. That is to say, if you call the function and pass in the start and end dates of a given month, then intuitively, the full month's range is what you should get.

A second reason for the change has to do with return calculations. Later on, we will add a column to the DataFrame that shows daily returns, and I am choosing to use a close-to-close measurement for calculation. That is, the return of a given trading day is taken between the close of the previous day and the close of the current day. I do this because the yfinance API gives the adjusted closing prices by default, and a close-to-close calculation makes sure we are always keeping that adjustment in mind. Additionally, I noticed anomalies between the open prices listed by the API compared to those on the YahooFinance website. However, I saw that the adjusted close prices were always in agreement.

In our table, we offset our start date backward by 10 days to ensure that we can access the prior trading day (and account for any long weekends or holidays), and grab the close price of that day. Later on in the function, we will trim out these irrelevant dates.

Next, we come to a philosophical choice to make: Even though the `download()` function is capable of handling multiple tickers' worth of data, I am choosing to make this root-level function as simple and flat as possible, and restrict it to **one ticker at a time.** When it comes time to do analysis later on, I see it as a fair trade-off to have to call this simpler function multiple times, rather than wrestling with a more dense DataFrame.

To make these flattening adjustments, we use `droplevel()` to remove the index of ticker names, and reset the index.

```python
    df.columns = df.columns.droplevel(1)
    df.reset_index(inplace=True)
```

Now, we add more columns that will be useful to us later on. We add a series of columns for the components of each date, as well as a column for each day's prior close, and the resulting daily return of that day.

```python
    df['Year'] = df['Date'].dt.year
    df['Month'] = df['Date'].dt.month
    df['Day'] = df['Date'].dt.day
    df['Prev_Close'] = df['Close'].shift(1)
    df['Daily_Return'] = (df['Close'] / df['Prev_Close']) - 1
```

Now, to return our final DataFrame, we filter our dates so that they match the range we passed in, and rearrange our columns into a more linear order.

```python
    df = df[df['Date'] >= start][['Date', 'Year', 'Month', 'Day', 'Prev_Close', 'Open', 'High', 'Low', 'Close', 'Daily_Return', 'Volume']]
    df.reset_index(drop=True, inplace=True)
    return df
```

Let's see the final result;

```python
Price       Date  Year  Month  Day  Prev_Close        Open        High         Low       Close  Daily_Return     Volume
0     2023-01-03  2023      1    3  128.123062  128.468194  129.079567  122.443165  123.330650     -0.037405  112117500
1     2023-01-04  2023      1    4  123.330650  125.125343  126.870731  123.340517  124.602715      0.010314   89113600
2     2023-01-05  2023      1    5  124.602715  125.361998  125.993097  123.024963  123.281342     -0.010605   80962700
3     2023-01-06  2023      1    6  123.281342  124.257594  128.478063  123.153167  127.817383      0.036794   87754700
4     2023-01-09  2023      1    9  127.817383  128.655569  131.554685  128.083633  128.340012      0.004089   70790800
5     2023-01-10  2023      1   10  128.340012  128.448446  129.434539  126.338208  128.911911      0.004456   63896200
6     2023-01-11  2023      1   11  128.911911  129.424721  131.653286  128.645715  131.633575      0.021113   69458900
7     2023-01-12  2023      1   12  131.633575  132.018152  132.392858  129.612083  131.554688     -0.000599   71379600
8     2023-01-13  2023      1   13  131.554688  130.193850  133.043658  129.829000  132.885880      0.010119   57809700
9     2023-01-17  2023      1   17  132.885880  132.954905  135.380685  132.264643  134.049469      0.008756   63646600
10    2023-01-18  2023      1   18  134.049469  134.917261  136.682361  133.152146  133.329651     -0.005370   69672800
11    2023-01-19  2023      1   19  133.329651  132.215356  134.355176  131.909670  133.388809      0.000444   58280400
12    2023-01-20  2023      1   20  133.388809  133.398630  136.100529  132.353374  135.952606      0.019220   80223600
```

This layout is very reminiscent of how I would set up a spreadsheet for analyzing data by hand, with an eye toward linearity and flatness over nesting. Besides providing for easier operations in `pandas` later on, any CSV exports of this function will be easy to interpret.

Let's move on to our next tool: Monthly returns.

## Monthly Returns - Single Ticker

I chose to build this function with a one-year scope, with optional improvements later on. Our first line creates a DataFrame using the `download_data()` function we just built, except with a timescale that encompasses the full range of the year passed into the function.

```python
def monthly_return_single(year, ticker):
    # Get data from January of the current year to December of the current year.
    df = download_data(ticker, f'{year}-01-01', f'{year}-12-31')
```

Next, we create a DataFrame that will hold the monthly return values, with columns for year, month, and return, as we would expect.

```python
    returns = pd.DataFrame(columns=['Year', 'Month', ticker])
```

To fill in this new table, we will repeatedly isolate each month from our pool of downloaded data, calculate the close-to-close return, and insert the calculation into the table by way of the `loc()` method.

```python
    for month in range(1, 13):        
        monthly_data = df[(df['Month'] == month) & (df['Year'] == year)]
        start_price = round(monthly_data.iloc[0]['Prev_Close'], 2)
        end_price = round(monthly_data.iloc[-1]['Close'], 2)
        monthly_ret = ((end_price / start_price) - 1)
        returns.loc[month] = [year, calendar.month_name[month], monthly_ret]
    return returns
```

Let's test it out:

```python
print(monthly_return_single(2023, 'AAPL'))
```

```python
    Year      Month      AAPL
1   2023    January  0.110521
2   2023   February  0.023194
3   2023      March  0.118629
4   2023      April  0.029045
5   2023        May  0.046008
6   2023       June  0.094358
7   2023       July  0.012772
8   2023     August -0.042362
9   2023  September -0.088686
10  2023    October -0.002595
11  2023   November  0.113831
12  2023   December  0.013538
```

When building this function, I ran multiple checks using YahooFinance web data, and calculated the return values by hand. In all cases, I saw consensus with the function.

## Monthly Returns - Multiple Tickers

Let's build on our work from earlier and build a function to compare multiple tickers' monthly returns. The operation is fairly simple due to our earlier choice of dealing with tickers one at a time.

Once we have our input year and list of tickers, we create a blank DataFrame and fill it with the monthly returns data from the first ticker in our list. From there onward, now that our DataFrame is no longer empty, we take the `else()` leg of our conditional and merge the next ticker's data into the DataFrame.

```python
def monthly_return_multi(year, *tickers):
    all_returns = pd.DataFrame()
    for ticker in tickers:
        returns = monthly_return_single(year, ticker)
        if all_returns.empty:
            all_returns = returns
        else:
            all_returns = all_returns.merge(returns, on=['Year', 'Month'])
```

Let's test it out:

```python
print(monthly_return_multi(2023, 'AAPL', 'MSFT', 'GOOGL'))
```

```python
    Year      Month      AAPL      MSFT     GOOGL
0   2023    January  0.110521  0.033325  0.120164
1   2023   February  0.023194  0.008990 -0.088835
2   2023      March  0.118629  0.155890  0.151834
3   2023      April  0.029045  0.065771  0.034751
4   2023        May  0.046008  0.071102  0.144747
5   2023       June  0.094358  0.037016 -0.025813
6   2023       July  0.012772 -0.013591  0.108765
7   2023     August -0.042362 -0.022227  0.026022
8   2023  September -0.088686 -0.036638 -0.039042
9   2023    October -0.002595  0.070822 -0.051785
10  2023   November  0.113831  0.122940  0.068084
11  2023   December  0.013538 -0.007566  0.054019
```

Perfect. At this point, I chose to add some optional functionality for comparing the returns in the table. For research projects that involve analyzing multiple securities, it may be helpful to see at a glance which securities were the top performers of each month.

To do this, we create two new columns in our DataFrame to hold the name of the top-performing ticker, as well as its return value.

```python
    all_returns['Best_Ticker'] = ''
    all_returns['Max_Return'] = 0.0
```

Now, we loop through each of our 12 months, filter this DataFrame to isolate each month, and use a combination of `iloc()`, `max()`, and `idxmax()` to find the maximum return from each group, and the tickers they belong to.

```python
    for month in range(1, 13):
        month_data = all_returns[all_returns['Month'] == calendar.month_name[month]]
        max_return = month_data.iloc[:, 2:-2].max(axis=1).values
        best_ticker = month_data.iloc[:, 2:-2].idxmax(axis=1).values
```

Now, we insert each pair of values we find into the new columns that we created earlier.

```python
        all_returns.loc[all_returns['Month'] == calendar.month_name[month], 'Max_Return'] = max_return
        all_returns.loc[all_returns['Month'] == calendar.month_name[month], 'Best_Ticker'] = best_ticker
    return all_returns
```

Let's see this added functionality in the table:

```python
print(monthly_return_multi(2023, 'AAPL', 'MSFT', 'GOOGL'))
```

```python
    Year      Month      AAPL      MSFT     GOOGL Best_Ticker  Max_Return
0   2023    January  0.110521  0.033325  0.120164       GOOGL    0.120164
1   2023   February  0.023194  0.008990 -0.088835        AAPL    0.023194
2   2023      March  0.118629  0.155890  0.151834        MSFT    0.155890
3   2023      April  0.029045  0.065771  0.034751        MSFT    0.065771
4   2023        May  0.046008  0.071102  0.144747       GOOGL    0.144747
5   2023       June  0.094358  0.037016 -0.025813        AAPL    0.094358
6   2023       July  0.012772 -0.013591  0.108765       GOOGL    0.108765
7   2023     August -0.042362 -0.022227  0.026022       GOOGL    0.026022
8   2023  September -0.088686 -0.036638 -0.039042        MSFT   -0.036638
9   2023    October -0.002595  0.070822 -0.051785        MSFT    0.070822
10  2023   November  0.113831  0.122940  0.068084        MSFT    0.122940
11  2023   December  0.013538 -0.007566  0.054019       GOOGL    0.054019
```

At this point, we've set our DataFrame up in an optimally flexible state for later analysis. For example, we can quickly analyze ticker frequencies, calculate cumulative products of each ticker's performance, and so on.

## Calculating Beta

Let's make a function to get the beta of one ticker against another over a one-year period, using daily returns data. It should be noted that using daily return values can create more statistical noise in the end-product, but I wanted to challenge myself to make a more microscopic version of this calculation. As my dad used to say, *"Measure twice, cut once."*

Our function accepts a year, a ticker, and a benchmark ticker. We begin by downloading the daily price data for each ticker, and adding a column onto each of the two DataFrames which will use the `pct_change()` method to calculate daily returns.

```python
def beta_comparison(year, ticker_1, ticker_2):
    df1 = download_data(ticker_1, f'{year}-01-01', f'{year}-12-31')
    df2 = download_data(ticker_2, f'{year}-01-01', f'{year}-12-31')
    df1['Return'] = df1['Close'].pct_change()
    df2['Return'] = df2['Close'].pct_change()
```

Next, we merge these two DataFrames together by their dates, and use `dropna()` to remove the very first row of our data, which has a NaN value for its daily return.

```python
    merged = pd.merge(df1[['Date', 'Return']], df2[['Date', 'Return']], on='Date', suffixes=(f'_{ticker_1}', f'_{ticker_2}')).dropna()
```

Finally, we calculate the covariance between our return columns, as well as the variance of our benchmark's returns. We then divide these values and return the result.

```python
    covariance = np.cov(merged[f'Return_{ticker_1}'], merged[f'Return_{ticker_2}'])[0][1]
    variance = np.var(merged[f'Return_{ticker_2}'])
    beta = covariance / variance
    return beta
```

Let's give this a test:

```python
print("Beta value:", beta_comparison(2023, 'QQQ', 'SPY'))
```

```python
Beta value: 1.2570235860336603
```

To verify this result, I did a manual calculation of this value in Excel using YahooFinance's web data, and got the same result to within 0.005.

> <img width="700" height="228" alt="Screenshot 2025-09-23 at 9 18 31 PM" src="https://github.com/user-attachments/assets/1a11793e-5a09-413f-b167-8ce8090fd721" />
