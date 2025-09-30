# Stock Skylines

Visualizing stock return trends in a peculiar way.

## Overview

I was curious about visualizing many years of stock data in various condensed forms. One way that came to mind was to plot returns on a three-dimensional chart, where the x-component of the data was the twelve months of the year, the y-component was an ascending range of years, and the z-component was the monthly return for the intersection of each particular month and year. When viewed with multiple years' worth of data, the figures begin to resemble a city.

## Method

We begin with some earlier functions that I wrote to find out monthly return data, and build from there. Our first function, `monthly_return_single_year`, takes a given year and ticker, and creates a 12-row dataframe showing the point-to-point returns for that month.

```python
def monthly_returns_single_year(year, ticker):
    # Get data from January of the current year to December of the current year.
    df = download_data(ticker, f'{year}-01-01', f'{year}-12-31')
    # Make a new DataFrame to hold monthly returns
    returns = pd.DataFrame(columns=['Year', 'Month_Number', 'Month_Name', ticker])
    for month in range(1, 13):
        # Isolate the data for the month
        monthly_data = df[(df['Month'] == month) & (df['Year'] == year)]
        # Take the first day's previous close and the last day's  close to calculate the return
        start_price = round(monthly_data.iloc[0]['Prev_Close'], 2)
        end_price = round(monthly_data.iloc[-1]['Close'], 2)
        monthly_ret = ((end_price / start_price) - 1)
        # Insert the data into the "returns" DataFrame
        returns.loc[month] = [year, month, calendar.month_name[month], monthly_ret]
    return returns
```

When we call this function, we see something like the following:

```python
print(monthly_returns_single_year(2023, 'NVDA'))
```

```python
    Year  Month_Number Month_Name      NVDA
1   2023             1    January  0.336986
2   2023             2   February  0.188012
3   2023             3      March  0.197068
4   2023             4      April -0.001081
5   2023             5        May  0.363145
6   2023             6       June  0.118254
7   2023             7       July  0.104802
8   2023             8     August  0.056103
9   2023             9  September -0.118613
10  2023            10    October -0.062342
11  2023            11   November  0.146712
12  2023            12   December  0.059050
```

With that in mind, we can use this function as a building block for finding multi-year returns data. In keeping with our naming conventions, this function will be called `monthly_returns_multi_year`. This function calls the single-year function on each year in our supplied range, and concatenates the results together.

```python
def monthly_returns_multi_year(start_year, end_year, ticker):
    # Create a DataFrame to hold all returns
    all_returns = pd.DataFrame()
    # Get monthly returns for each year and merge them into a single DataFrame
    for year in range(start_year, end_year + 1):
        returns = monthly_returns_single_year(year, ticker)
        if all_returns.empty:
            all_returns = returns
        else:
            all_returns = pd.concat([all_returns, returns], ignore_index=True)
    return all_returns
```

Let's see this applied to NVDA over two consecutive years.

```python
    Year  Month_Name Month_Number      NVDA
0   2023           1      January  0.336986
1   2023           2     February  0.188012
2   2023           3        March  0.197068
3   2023           4        April -0.001081
4   2023           5          May  0.363145
5   2023           6         June  0.118254
6   2023           7         July  0.104802
7   2023           8       August  0.056103
8   2023           9    September -0.118613
9   2023          10      October -0.062342
10  2023          11     November  0.146712
11  2023          12     December  0.059050
12  2024           1      January  0.242424
13  2024           2     February  0.285691
14  2024           3        March  0.142153
15  2024           4        April -0.043738
16  2024           5          May  0.268874
17  2024           6         June  0.126939
18  2024           7         July -0.052717
19  2024           8       August  0.020089
20  2024           9    September  0.017431
21  2024          10      October  0.093155
22  2024          11     November  0.041365
23  2024          12     December -0.028580
```

Alrighty. This function will serve as the foundation for our plotting stage. We first create a DataFrame containing the range of monthly returns for our chosen ticker and years.

```python
def plot_monthly_returns(start_year, end_year, ticker):
    # Get the monthly returns data
    df = monthly_returns_multi_year(start_year, end_year, ticker)
```

Next, we initialize our figure and subplot, and configure it to be a `bar3d` plot. When we configure the barplot itself, we specify the relative size of our bars in the x and y axis, which I've chosen as 0.75 and 0.3, respectively. The height of our bars is set to show the monthly return from the `returns` column of our source DataFrame.

```python
    fig = plt.figure(figsize=(8, 3))
    ax1 = fig.add_subplot(111, projection='3d')
    ax1.bar3d(df['Month_Number'], df['Year'], np.zeros(len(df)), 0.75, 0.3, df[ticker]*100, color='lightsteelblue', shade=True)
```

Finally, we add labels and specify the labeling of our axes how we desire.

```python
    ax1.set_xlabel('Month')
    ax1.set_ylabel('Year')
    ax1.set_zlabel('Monthly Return (%)')
    ax1.set_xticks(range(1, 13))
    ax1.yaxis.set_major_locator(MultipleLocator(1))
    ax1.set_title(f'Monthly Returns for {ticker} from {start_year} to {end_year}', fontweight='bold', pad=20)
    ax1.set_xticklabels([calendar.month_abbr[m] for m in range(1, 13)])
    plt.show()
```

Let's run this for NVDA over a few years and see what we have.

```python
print(plot_monthly_returns(2020, 2023, 'NVDA'))
```
> <img width="500" height="497" alt="Screenshot 2025-09-30 at 1 34 07 AM" src="https://github.com/user-attachments/assets/691b778d-a15f-4ac4-9600-002eb8ca3f69" />

> <img width="500" height="598" alt="Screenshot 2025-09-30 at 1 18 57 AM" src="https://github.com/user-attachments/assets/680d7975-e75e-45d8-98ca-d3558432b450" />

> <img width="500" height="511" alt="Screenshot 2025-09-30 at 1 19 42 AM" src="https://github.com/user-attachments/assets/3d635972-5856-4060-8142-dcf18f3db5ed" />

Interesting! Now that we have a visualization in front of us that looks very much like a grid of skyscrapers in a city, we can take this metaphor farther and examine this stock's behavior through a new, if unconventional, lens. For example, we could choose to compare the "skyline" of two different stocks and extract trends about their volatility and momentum, given the heights and positions of each "building" with respect to its neighbors.

Let's see the skyline for AGG.

```python
print(plot_monthly_returns(2020, 2023, 'AGG'))
```

> <img width="500" height="504" alt="Screenshot 2025-09-30 at 1 25 08 AM" src="https://github.com/user-attachments/assets/4646ee12-3715-4ae5-939f-2c01c9172cbd" />

> <img width="500" height="498" alt="Screenshot 2025-09-30 at 1 25 35 AM" src="https://github.com/user-attachments/assets/fd6098cd-1922-48bb-8b94-9fa668f10228" />

What I find most interesting about this "skyline" is the consistent challenges of the months of August through October, even over the span of **four years.**

> <img width="500" height="636" alt="Screenshot 2025-09-30 at 1 26 05 AM" src="https://github.com/user-attachments/assets/b1c8a2b7-4364-40b6-8b0b-133f1a77b5f1" />
