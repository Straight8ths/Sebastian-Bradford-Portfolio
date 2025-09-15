# Division Decimals

A catalogue of decimal values arrived at through division.

## Overview

I was curious about which decimal values show up the most (and the least) when conducting division over a large range of integers.

## Process

Standard imports:
```python
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
```

We start with a function that will create a dataframe showing division results for a range of integers up to a *value* that we provide. The columns are given names for each integer in the range.

```python
def div_table(value):
    table = pd.DataFrame(columns=[i for i in range(1, value + 1)])
```

Next, we build the table row by row usinc the .loc() method. Each row will contain a series of division results over our range, and the row itself will be named according to which integer is involved. *(e.g The row named "5" will involve all divisions where 5 is the numerator).* Our final step is to return the table.

```python
    for i in range(1, value + 1):
        table.loc[i] = [round(i / j, 4) for j in range(1, value + 1)]
    return table
```

Let's run the function with an argument of *10*, for instance.

```python
      1    2       3     4    5       6       7      8       9    10
1    1.0  0.5  0.3333  0.25  0.2  0.1667  0.1429  0.125  0.1111  0.1
2    2.0  1.0  0.6667  0.50  0.4  0.3333  0.2857  0.250  0.2222  0.2
3    3.0  1.5  1.0000  0.75  0.6  0.5000  0.4286  0.375  0.3333  0.3
4    4.0  2.0  1.3333  1.00  0.8  0.6667  0.5714  0.500  0.4444  0.4
5    5.0  2.5  1.6667  1.25  1.0  0.8333  0.7143  0.625  0.5556  0.5
6    6.0  3.0  2.0000  1.50  1.2  1.0000  0.8571  0.750  0.6667  0.6
7    7.0  3.5  2.3333  1.75  1.4  1.1667  1.0000  0.875  0.7778  0.7
8    8.0  4.0  2.6667  2.00  1.6  1.3333  1.1429  1.000  0.8889  0.8
9    9.0  4.5  3.0000  2.25  1.8  1.5000  1.2857  1.125  1.0000  0.9
10  10.0  5.0  3.3333  2.50  2.0  1.6667  1.4286  1.250  1.1111  1.0
```

Perfect! Our rows act as numerators, our columns act as denominators, and their intersections show the result of the division.

## Plotting the Values

Let's write a function to display this. We begin with...
```python
def plot_div_table(value):
    table = div_table(value)
```
... which lays the groundwork. Next, take each element in the table, split it by its decimal value, and take only the right-hand result of the split (that is, the decimal digits).

```python
    stripped = table.applymap(lambda x: str(x).split('.')[1] if '.' in str(x) else '0')
```
Now that our data is named *stripped*, we need to wrangle it into a frequency table. We can use the *stack()* method on our dataframe in order to collapse it into a single column, and then run the *value_counts()* method to extract the frequencies of each decimal value. When the data is in this state, it's now referred to by *freqs*.

```python
    freqs = pd.DataFrame(stripped.stack().value_counts()).reset_index()
```
Because of the nature of our dataframe from earlier, our decimals are not sorted numerically, so we run the *sort_values()* method to fix it. We also ensure the columns are given new proper names.

```python
    freqs.columns = ['Decimal Component', 'Frequency']
    freqs = freqs.sort_values(by='Decimal Component').reset_index(drop=True)
```

Finally, we draw up our plot in Seaborn. Hint: A log scale will be our friend here.

```python
    plt.figure(figsize=(18, 6))
    sns.barplot(data=freqs, x='Decimal Component', y='Frequency', color='green')
    plt.yscale('log') # Better visibility with log scale
    plt.xlabel('Decimal Component', color='grey')
    plt.ylabel('Frequency (Log Scale)', color='grey')
    plt.title(f'Frequency of Decimal Components in Division Table up to {value}', fontsize=20, color='black', fontweight='bold', pad=20)
    plt.xticks(rotation=90, color='grey')
    plt.yticks(color='grey')
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.fontfamily = 'monospace'
    plt.show()
```

Let's see what this looks like for values up to 10.

```python
print(plot_div_table(10))
```

> <img width="500" height="474" alt="Screenshot 2025-09-14 at 5 11 23 PM" src="https://github.com/user-attachments/assets/fdc90499-77d4-4edd-b610-bbf44c5bb4ac" />

Hm... alright. What about values up to 100?

```python
print(plot_div_table(100))
```

<img width="1100" height="568" alt="Screenshot 2025-09-14 at 5 12 19 PM" src="https://github.com/user-attachments/assets/6cf8be9b-b7c8-49cc-ad22-b320d81a2404" />

Now we're talking. What I find the most interesting are the *sinkholes* that form around certain high-frequency values like 0.5. Given that our dataframe for n=100 contains **10,000 separate division results**, why is it that a decimal like 0.5 has no close neighbors? 
