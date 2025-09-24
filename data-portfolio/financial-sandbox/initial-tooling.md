# Initial Tooling

How I approach the yfinance library to construct base-level tools for later projects.

## Overview

Functionalities to build:
- Downloading stock data
- Calculating monthly returns
- Introducing return comparisons
- Calculating and comparing betas

## Downloading Stock Data

Standard imports, with the addition of the calendar module to make time series construction easier:

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


