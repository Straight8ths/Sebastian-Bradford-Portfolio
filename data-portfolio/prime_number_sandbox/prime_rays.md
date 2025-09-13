# Prime Rays

Using Python and Pandas for a visualization that I couldn't get out of my head.

## Overview

Prime numbers and their properties are my favorite mental chew toy. In this case, I was having thoughts about a very particular table I wanted to make, showing a large range of integers and their prime factors. This table wouldn't be concerned with the *frequency* of an integer's factors (e.g. How many *3's* and *5's* it takes to get to *75*), but merely showing which prime factors were present in a number or not?

## Process

We begin with standard import conventions, along with an extra one to silence an error that Pandas will throw later on.

```python
from primePy import primes
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import warnings

warnings.simplefilter(action='ignore', category=pd.errors.PerformanceWarning)
```

Next, let's make our table as a dataframe. We create a column called *Number* which will hold our ascending range of integers, up to the upper bound we define in the function call.

```python
def prime_factor_table(upper_bound):
    factor_table = pd.DataFrame(columns=['Number'])
    factor_table['Number'] = range(1, upper_bound + 1)
```

Next, we want to add one column to our dataframe for each prime that there is within our range of integers. Along with that, we initialize all columns to an unobtrusive placeholder character, like a hyphen.

```python
    prime_factors = primes.upto(upper_bound)
    for prime in prime_factors:
        factor_table[prime] = "-"
```

For the key feature of our table, we'll place an X in each integer's row wherever we encounter a prime factor. Using iterrows(), we grab each row one at a time and hone in on the single cell containing our integer (which is indexed by the "Number" column). We check divisibility against all primes up to the number in question, which shaves off a great deal of overhead compared to checking against primes which are larger than the integer itself. Finally, for all instances where our integer is evenly divided by a given prime factor, we plot an "X" at their intersection. Lastly, we close out by returning our table.

```python
    for index, row in factor_table.iterrows():
        number = row['Number']
        for prime in primes.upto(number):
            if number % prime == 0:
                factor_table.at[index, prime] = "X"

    return factor_table
```

Let's see this for all integers up to 20, for instance.

```python
print(prime_factor_table(20))

    Number  2  3  5  7 11 13 17 19
0        1  -  -  -  -  -  -  -  -
1        2  X  -  -  -  -  -  -  -
2        3  -  X  -  -  -  -  -  -
3        4  X  -  -  -  -  -  -  -
4        5  -  -  X  -  -  -  -  -
5        6  X  X  -  -  -  -  -  -
6        7  -  -  -  X  -  -  -  -
7        8  X  -  -  -  -  -  -  -
8        9  -  X  -  -  -  -  -  -
9       10  X  -  X  -  -  -  -  -
10      11  -  -  -  -  X  -  -  -
11      12  X  X  -  -  -  -  -  -
12      13  -  -  -  -  -  X  -  -
13      14  X  -  -  X  -  -  -  -
14      15  -  X  X  -  -  -  -  -
15      16  X  -  -  -  -  -  -  -
16      17  -  -  -  -  -  -  X  -
17      18  X  X  -  -  -  -  -  -
18      19  -  -  -  -  -  -  -  X
19      20  X  -  X  -  -  -  -  -
```

Nice! Now, let's do this more justice with a proper visualization.

The function to make the graph begins by creating the underlying dataframe specified by the call. We then do some tidying and value-replacing to make the data more graphable.

```python
def plot_prime_factor_heatmap(upper_bound):
    factor_table = prime_factor_table(upper_bound)
    heatmap_data = factor_table.set_index('Number').replace("-", 0).replace("X", 1)
```

Next, we make the heatmap in Seaborn and fiddle with layout, spacing, and typography.
```python
    plt.figure(figsize=(12, 8))
    sns.heatmap(heatmap_data, cmap="binary", cbar=False)
    plt.title(f'Prime Factor Heatmap up to {upper_bound}', fontsize=16, color='black', fontweight='bold', pad=20)
    plt.xlabel('Prime Factors', fontsize=12, color='grey')
    plt.ylabel('Numbers', fontsize=12, color='grey')
    plt.fontfamily = 'monospace'
    plt.xticks(color='grey')
    plt.yticks(color='grey')
    plt.show()
```

Now, let's take a gander at a larger range of integers, say up to 1,000.

```python
print(plot_prime_factor_heatmap(1000))
```

