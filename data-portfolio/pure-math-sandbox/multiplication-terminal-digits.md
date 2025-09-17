# Multiplication Terminal Digits

A companion piece to *Division Decimals*, exploring the final digits from various multiplication operations.

## Overview

Although I understood intuitively that repeated multiplication over a large range of numbers yielded more numeric repetition than decimal divisions, I wanted to see what the landscape was like regardless. Specifically, I was concerned with how the final digits from each multiplication operation would be represented.

## Process

Standard imports:

```python
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
```

Our first function builds a multiplication dataframe, which borrows the skeleton of the division function from *Division Decimals*.

```python
def mult_table(value):
    table = pd.DataFrame(columns=[i for i in range(1, value + 1)])
    for i in range(1, value + 1):
        table.loc[i] = [(i * j) for j in range(1, value + 1)]
    return table
```

We first create our named list of columns, then insert each named row along with the results of each series of multiplications.

If we run this with an input of 10, the shape of the data should look familiar, although the content is different.

```python
print(mult_table(10))
```

```
    1   2   3   4   5   6   7   8   9   10
1    1   2   3   4   5   6   7   8   9   10
2    2   4   6   8  10  12  14  16  18   20
3    3   6   9  12  15  18  21  24  27   30
4    4   8  12  16  20  24  28  32  36   40
5    5  10  15  20  25  30  35  40  45   50
6    6  12  18  24  30  36  42  48  54   60
7    7  14  21  28  35  42  49  56  63   70
8    8  16  24  32  40  48  56  64  72   80
9    9  18  27  36  45  54  63  72  81   90
10  10  20  30  40  50  60  70  80  90  100
```

Excellent. Now, we need to map a function over the dataframe which clips off the final digit of each entry.

```python
def stripped_mult_table(value):
    table = mult_table(value)
    stripped = table.applymap(lambda x: int(str(x)[-1]))
    return stripped
```
At this point, we can use the same plotting function from *Division Decimals* to visualize the results.

```python
def plot_stripped_mult_table(value):
    table = stripped_mult_table(value).sort_index(ascending=False)
    plt.figure(figsize=(10, 8))
    sns.heatmap(table, cmap='inferno', cbar_kws={'label':'Terminal Digit'})
    plt.title(f'Heatmap of Terminal Digits in Multiplication Table up to {value}', fontsize=16, color='black', fontweight='bold', pad=20)
    plt.xlabel('Multiplicand', labelpad=10)
    plt.ylabel('Multiplier', labelpad=10)
    plt.xticks(rotation=90, fontsize=8, color='grey')
    plt.yticks(fontsize=8, color='grey')
    plt.fontfamily = 'monospace'
    plt.show()
```

Let's see the visualization for integers up to 10, from earlier.

```python
plot_stripped_mult_table(10)
```

