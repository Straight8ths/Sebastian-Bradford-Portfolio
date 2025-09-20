# Relative Prime Positions

Exploring gaps between primes in standardizable terms.

## Overview

I wanted to study prime gaps in a way that I hadn't yet seen. Rather than looking at the sizes of the gaps between a given prime and the next, I wanted to examine each prime's position relative to its upper and lower neighbors. To standardize these distances for study, I chose to express them as percentages.

## Process

Standard imports:

```python
import pandas as pd
from primePy import primes
import matplotlib.pyplot as plt
import seaborn as sns
```

We only need one workhorse function here. It takes a number as its input, which sets the upper bound for our prime search. We start with creating a dataframe to store the relative positions for each prime we evaluate. We also create our standing list of primes up to our ceiling.

```python
def relative_positions(n):
    positions_table = pd.DataFrame(columns=['position'])
    prime_list = primes.upto(n)
```

Next, we run a for loop to examine the primes in our list. This analysis is concerned with distances between upper and lower prime neighbors, so we need to skip the first and last primes in our list. Each prime's relative position is calculated as a ratio of *(the distance to the lower neighbor)* divided by *(the distance from the lower to the upper neighbor)*. We store each calculated result in our dataframe.

```python
    for i in range(1,len(prime_list)-1):
        lower = prime_list[i-1]
        upper = prime_list[i+1]
        position = (prime_list[i]-lower)/(upper-lower)
        positions_table.loc[i] = round(position,2)
    return positions_table
```
*A note on rounding*: We are electing to round our division results so that we can have meaningful grouping of data as our analysis scales in size. By rounding to two decimal places, we are choosing to examine phenomena at a distance resolution of 1%. Without this rounding, our data would be sparse due to the many unique position ratios that might arise.

Let's see a proof of concept, evaluating the positions for all primes up to 10.

```python
print(relative_positions(10))
```

```python
   position
1      0.33
2      0.50
```

We see the function working as intended. Of the primes up to 10, we are only examining 3 and 5. 3 is indeed a third of the way between 2 and 5, and 5 is halfway between 3 and 7, hence the two position values we see in the dataframe.

## Visualization

We'll plot these results as a frequency table which will be displayed as a bar chart later on. Our plotting function generates a position table from before, and counts the number of occurrences of each decimal value. We also rename our columns for easy graphing.

```python
def plot_relative_positions(n):
    freq_table = relative_positions(n).value_counts().reset_index().sort_values(by='position')
    freq_table.columns = ['position','count']
```

Finally, we tweak our visuals until we are satisfied.

```python
    plt.figure(figsize=(9,9))
    sns.barplot(data=freq_table, x='position', y='count', color='darkorange')
    plt.title(f'Prime Neighbor Positions up to {n}', fontsize=18, pad=20, fontweight='bold')
    plt.xlabel('Percentage Position between Neighboring Primes', color='grey', fontsize=12)
    plt.ylabel('Frequency', color='grey', fontsize=12)
    plt.xticks(rotation=90, color='grey')
    plt.yticks(color='grey')
    plt.show()
```

Let's see how this looks for all primes up to 100.

```python
plot_relative_positions(100)
```

> <img width="500" height="540" alt="Screenshot 2025-09-19 at 9 27 46 PM" src="https://github.com/user-attachments/assets/94412e97-7fb0-44fc-afb9-499d609bc4ab" />

Interesting. Let's expand the range considerably (to 100,000) and see if this behavior holds.

```python
plot_relative_positions(100000)
``` 

> <img width="500" height="520" alt="Screenshot 2025-09-19 at 9 29 04 PM" src="https://github.com/user-attachments/assets/ced96f57-be05-43aa-909c-a01e673727e2" />

Sure enough, it does. Because we elected to ignore the sheer integer values of prime gaps in favor of standardizing them, we see an interesting emergent property with a high degree of symmetry to boot.
