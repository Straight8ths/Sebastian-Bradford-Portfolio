# Intraday Movement vs. Return

Using yfinance to make short work of a visualization I used to do in Excel.

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

To add our intraday price movement, we can use the base data from `download_data()` and add a column for the calculation. Let's stick with NVDA as our example stock.

```python
data = download_data('NVDA', '2023-05-20', '2023-05-30')
data['Intraday_Movement'] = (data['High'] - data['Low']) / data['Prev_Close']
```

Let's see some example data from before and after the blowout data we mentioned earlier.

```python
Price       Date  Year  Month  Day  Prev_Close       Open       High        Low      Close  Daily_Return      Volume  Intraday_Movement
0     2023-05-22  2023      5   22   31.239779  30.877057  31.495579  30.656230  31.151846     -0.002815   372000000           0.026868
1     2023-05-23  2023      5   23   31.151846  30.975983  31.263760  30.607270  30.664225     -0.015653   356253000           0.021074
2     2023-05-24  2023      5   24   30.664225  30.186594  30.583288  29.782908  30.514341     -0.004888   721419000           0.026101
3     2023-05-25  2023      5   25   30.514341  38.493152  39.449411  36.606614  37.950573      0.243696  1543911000           0.093163
4     2023-05-26  2023      5   26   37.950573  37.860647  39.139654  37.520910  38.915829      0.025435   714397000           0.042654
5     2023-05-30  2023      5   30   38.915829  40.563544  41.905502  39.918045  40.079918      0.029913   923401000           0.051071
```

## Visualization

Now, let's expand our time range to the whole year of 2023, and visualize this data as a scatterplot between intraday movement and daily return. After creating our dataframe, we summon a scatterplot from MatPlotLib and make some aesthetic adjustments. These include adding a horizontal line at y=0 for reference, and adjusting the x-axis to show ticks at every 0.01 interval.

```python
data = download_data('NVDA', '2023-01-01', '2023-12-31')
data['Intraday_Movement'] = (data['High'] - data['Low']) / data['Prev_Close']

fig, ax1 = plt.subplots(figsize=(8, 9))
ax1.scatter(data['Intraday_Movement'], data['Daily_Return'], color='purple', alpha=0.6, edgecolors='w', s=100)

plt.title('Intraday Movement vs. Daily Return for NVDA in 2023', fontsize=16, fontweight='bold', pad=20)
plt.xlabel('Intraday Movement', fontsize=14)
plt.ylabel('Daily Return', fontsize=14)
plt.xticks(rotation=90, fontsize=10, color='grey')
ax1.xaxis.set_major_locator(MultipleLocator(0.01))
plt.yticks(fontsize=10, color='grey')
plt.axhline(0, color='black', linestyle='--')
plt.fontfamily = 'monospace'
plt.show()
```

> <img width="600" height="646" alt="Screenshot 2025-09-25 at 8 05 32 AM" src="https://github.com/user-attachments/assets/c797a5a4-6fa6-45cc-be99-7fbd6ff00571" />
