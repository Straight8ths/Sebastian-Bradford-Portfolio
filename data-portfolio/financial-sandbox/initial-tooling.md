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
import numpy as np
import calendar
```

We first build our root-level function to download historical data. We start with a DataFrame to hold the default output from the YahooFinance API.

```python
def download_data(ticker, start, end):
    df = yf.download(ticker, start=start, end=end)
```

At this point, we have a philosophical decision to make: The API returns a multi-indexed DataFrame to account for cases where we might query multiple tickers at once.

```python
print(download_data('AAPL', '2023-01-01', '2023-01-15'))
```

```python
Price            Close        High         Low        Open     Volume
Ticker            AAPL        AAPL        AAPL        AAPL       AAPL
Date                                                                 
2023-01-03  123.330650  129.079567  122.443165  128.468194  112117500
2023-01-04  124.602707  126.870724  123.340509  125.125335   89113600
2023-01-05  123.281319  125.993074  123.024940  125.361975   80962700
2023-01-06  127.817390  128.478071  123.153174  124.257601   87754700
2023-01-09  128.339996  131.554669  128.083618  128.655553   70790800
2023-01-10  128.911911  129.434539  126.338208  128.448446   63896200
2023-01-11  131.633545  131.653256  128.645685  129.424691   69458900
2023-01-12  131.554657  132.392827  129.612053  132.018122   71379600
2023-01-13  132.885895  133.043673  129.829015  130.193865   57809700
```

Although I appreciate the density of this, I would rather build this first function with *maximum simplicity in mind*, so I elected to strip out the multi-indexing and process only one ticker's data at a time. When this function is implemented in later projects, I personally see it as a fair trade to have to call a simple function multiple times, as opposed to delicately chopping up a more complex DataFrame. Let's call `droplevel()` on the DataFrame and make the change.

```python
    df.columns = df.columns.droplevel(1)
    df.reset_index(inplace=True)
```

This change leaves us with a cleaner, flatter DataFrame:

```python
print(download_data('AAPL', '2023-01-01', '2023-01-15'))
```

```python
Price       Date       Close        High         Low        Open     Volume
0     2023-01-03  123.330635  129.079551  122.443150  128.468178  112117500
1     2023-01-04  124.602707  126.870724  123.340509  125.125335   89113600
2     2023-01-05  123.281342  125.993097  123.024963  125.361998   80962700
3     2023-01-06  127.817360  128.478040  123.153145  124.257571   87754700
4     2023-01-09  128.339996  131.554669  128.083618  128.655553   70790800
5     2023-01-10  128.911942  129.434570  126.338238  128.448477   63896200
6     2023-01-11  131.633575  131.653286  128.645715  129.424721   69458900
7     2023-01-12  131.554672  132.392842  129.612068  132.018137   71379600
8     2023-01-13  132.885864  133.043643  129.828986  130.193835   57809700
```

Now, we add other columns of our choosing onto this output. I saw it fit to add a set of columns to numerically display the components of each date (for easier filtering later on), as well as a column showing the previous day's closing price.

```python
    df['Year'] = df['Date'].dt.year
    df['Month'] = df['Date'].dt.month
    df['Day'] = df['Date'].dt.day
    df['Prev_Close'] = df['Close'].shift(1)
```

Let's see what that looks like:

```python
print(download_data('AAPL', '2023-01-01', '2023-01-15'))
```

```python
Price       Date       Close        High         Low        Open     Volume  Year  Month  Day  Prev_Close
0     2023-01-03  123.330643  129.079559  122.443158  128.468186  112117500  2023      1    3         NaN
1     2023-01-04  124.602715  126.870731  123.340517  125.125343   89113600  2023      1    4  123.330643
2     2023-01-05  123.281342  125.993097  123.024963  125.361998   80962700  2023      1    5  124.602715
3     2023-01-06  127.817368  128.478048  123.153152  124.257579   87754700  2023      1    6  123.281342
4     2023-01-09  128.339966  131.554638  128.083587  128.655523   70790800  2023      1    9  127.817368
5     2023-01-10  128.911942  129.434570  126.338238  128.448477   63896200  2023      1   10  128.339966
6     2023-01-11  131.633575  131.653286  128.645715  129.424721   69458900  2023      1   11  128.911942
7     2023-01-12  131.554672  132.392842  129.612068  132.018137   71379600  2023      1   12  131.633575
8     2023-01-13  132.885895  133.043673  129.829015  130.193865   57809700  2023      1   13  131.554672
```

Our final step is to reorder the columns so that the date-related colums are grouped together, and the previous day's close is directly next to the current day's open. We close out by returning the DataFrame.

```python
    df = df[['Date', 'Year', 'Month', 'Day', 'Prev_Close', 'Open', 'High', 'Low', 'Close', 'Volume']]
    return df
```

Let's see the final result:

```python
print(download_data('AAPL', '2023-01-01', '2023-01-15'))
```

```python
Price       Date  Year  Month  Day  Prev_Close        Open        High         Low       Close     Volume
0     2023-01-03  2023      1    3         NaN  128.468194  129.079567  122.443165  123.330650  112117500
1     2023-01-04  2023      1    4  123.330650  125.125335  126.870724  123.340509  124.602707   89113600
2     2023-01-05  2023      1    5  124.602707  125.361991  125.993089  123.024955  123.281334   80962700
3     2023-01-06  2023      1    6  123.281334  124.257557  128.478025  123.153130  127.817345   87754700
4     2023-01-09  2023      1    9  127.817345  128.655553  131.554669  128.083618  128.339996   70790800
5     2023-01-10  2023      1   10  128.339996  128.448461  129.434554  126.338223  128.911926   63896200
6     2023-01-11  2023      1   11  128.911926  129.424706  131.653271  128.645700  131.633560   69458900
7     2023-01-12  2023      1   12  131.633560  132.018122  132.392827  129.612053  131.554657   71379600
8     2023-01-13  2023      1   13  131.554657  130.193850  133.043658  129.829000  132.885880   57809700
```

This layout is very reminiscent of how I would set up a spreadsheet for analyzing data by hand, with an eye toward linearity and flatness over nesting. Besides providing for easier operations in `pandas` later on, any CSV exports of this function will be easy to interpret.

Let's move on to our next tool: Monthly returns.

## Monthly Returns - Single Ticker

I chose to build this function with a one-year scope, with optional improvements later on. Our first line creates a DataFrame using the `download_data()` function we just built, except with a timescale encompassing the year passed into the function.

```python
def monthly_return_single(year, ticker):
    df = download_data(ticker, f'{year-1}-12-01', f'{year}-12-31')
```

**A note:** I am electing to use calculate returns on a close-to-close basis, so in effect, the final closing price of a given month will be treated as the open price for next month's return calculation. In order to accomplish this for a year spanning January to December, we need to include data from December of the previous year to make sure we get our first value for January.

My main reason for this adjustment was the fact that the yfinance API uses the *adjusted close price* for each security by default, so by comparing two adjusted close prices, we can keep the scale of our analysis accurate.

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

When building this function, I ran multiple sanity checks by consulting YahooFinance data by hand, and in all cases I saw consensus with the function.

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

Perfect. At this point, I chose to add some optional functionality of comparing the returns present in the table. For research projects that involve analyzing multiple securities, it may be helpful to see at a glance which securities were the top performers of each month.

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

Now, we insert each pair of values we find into the new columns we created earlier.

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

From this, we've set our DataFrame into an optimally flexible state for later analysis. For example, we can quickly analyze ticker frequencies, calculate cumulative products of each ticker's performance, and more.

## Calculating Beta

Let's make a function to get the beta of one ticker against another over a one-year period, using daily returns data. It should be noted that using daily return values can create more statistical noise in the end-product, but I wanted to challenge myself to make a more microscopic version of this calculation.

The function accepts a year, a ticker, and a benchmark ticker. We begin by downloading the daily price data for each ticker, and adding column on each of the two DataFrames which will use the `pct_change()` method to calculate daily returns.

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
