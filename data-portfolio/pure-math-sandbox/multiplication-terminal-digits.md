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

> <img width="600" height="547" alt="Screenshot 2025-09-16 at 9 13 26 PM" src="https://github.com/user-attachments/assets/4ba170c1-456b-4a6f-b014-2dc972369419" />

Interesting! It almost looks like a flower. Because we are working with base-10 multiplication, this heatmap can be thought of as a "cell" which will be tesselated over and over if we choose to expand the range of our map. Let's call the plotting function with range of 50, for instance.

```python
plot_stripped_mult_table(50)
```

> <img width="600" height="546" alt="Screenshot 2025-09-16 at 9 17 10 PM" src="https://github.com/user-attachments/assets/c80bef91-88a9-4ce0-9c6b-ccce4432eb8d" />

As a funny byproduct of this expansion, we get a neat optical illusion that looks as if our cells are being diagonally sheared.

Let's press on and expand our search. That is, let's examine the heatmaps for larger amounts of terminal digits, rather than just 1.

## Taking Multiple Terminal Digits

To prevent any headaches later on, we need to re-tool our earlier functions to accomplish this. Firstly, we need to allow for explicit starting and ending values for our multiplication table. Secondly, we have to have a parameter for how many final digits we want to keep.

Let's review the improved versions of our three functions.

### Producing the Multiplication Table

```python
def mult_table_any(min_term, max_term):
    table = pd.DataFrame(columns=[i for i in range(min_term, max_term + 1)])
    for i in range(min_term, max_term + 1):
        table.loc[i] = [(i * j) for j in range(min_term, max_term + 1)]
    return table
```

The main adjustment here is the inclusion of *min_term* and *max_term*, which sets the bounds of our table accordingly.

### Stripping the Final Digits

```python
def stripped_mult_table_any(min_term, max_term, n):
    table = mult_table_any(min_term, max_term)
    stripped = table.applymap(lambda x: int(str(x)[-n:]) if len(str(x))>=n else 0)
    return stripped
```

Our key change here is the lambda function, which includes a **very** important colon which sets our slice and allows us to grab the final *n* digits from our entries.

### Plotting a Heatmap

```python
def plot_stripped_mult_table_any(min_term, max_term, n):
    table = stripped_mult_table_any(min_term, max_term, n).sort_index(ascending=False)
    plt.figure(figsize=(10, 8))
    sns.heatmap(table, cmap='inferno', cbar_kws={'label':'Terminal Digit'})
    plt.title(f'Heatmap of Terminal {n} Digits in Multiplication Table from {min_term} to {max_term}', fontsize=16, color='black', fontweight='bold', pad=20)
    plt.xlabel('Multiplicand', labelpad=10)
    plt.ylabel('Multiplier', labelpad=10)
    plt.xticks(rotation=90, fontsize=8, color='grey')
    plt.yticks(fontsize=8, color='grey')
    plt.fontfamily = 'monospace'
    plt.show()
```

There are no substantial changes here, only a modification of our f-string in the map's title which will stay flexible as we play with different series of arguments.

## Testing Our New Functions

Let's see how our heatmap holds up. To recreate our very first heatmap, we call our plotting function with parameters of 1, 10, and 1. This will evaluate products over a range of 1 to 10, and keep the single final digit.

```python
print(plot_stripped_mult_table_any(1,10,1))
```

> <img width="600" height="528" alt="Screenshot 2025-09-16 at 9 50 41 PM" src="https://github.com/user-attachments/assets/740ade3a-ede8-4f7d-b5bf-d26c4f6e0e1d" />

Awesome! To make our second heatmap showing the tesselated pattern, we call the function with parameters of 1, 50, and 1.

```python
print(plot_stripped_mult_table_any(1,50,1))
```

> <img width="600" height="529" alt="Screenshot 2025-09-16 at 11 02 41 PM" src="https://github.com/user-attachments/assets/040e75ac-6d0e-4000-b0ea-388dd1ec7085" />


Sweet! Now, let's get fancy. Let's take a range of 10 to 100, and keep the final two digits.

```python
print(plot_stripped_mult_table_any(10,100,2))
```

> <img width="600" height="511" alt="Screenshot 2025-09-16 at 11 03 36 PM" src="https://github.com/user-attachments/assets/774ac56d-2b75-4579-ba5f-086b5710e79c" />

Woah! How does this new behavior change if we expand our range. Let's try it again, but with 300 as our upper bound.

```python
print(plot_stripped_mult_table_any(10,300,2))
```
> <img width="600" height="512" alt="Screenshot 2025-09-16 at 11 04 24 PM" src="https://github.com/user-attachments/assets/e1ccb2d0-b1d0-4cc9-80e8-27dbde08e359" />

Just as we thought: We've arrived at a new tesselated pattern.

How about stepping it up to *three* final digits? Let's use our same range from earlier so we can maintain our visual context.

```python
print(plot_stripped_mult_table_any(10,300,3))
```

> <img width="600" height="512" alt="Screenshot 2025-09-16 at 11 05 30 PM" src="https://github.com/user-attachments/assets/008cd2b5-1cb6-4772-9d20-6cee03810d30" />

Oooooh, I get it. We're seeing the edge of an even larger fractal pattern, with even more inner turbulence. How neat!

Finally, let's push to 4 terminal digits, and take a look at a larger range of 100 to 500.

```python
print(plot_stripped_mult_table_any(100,500,4))
```
> <img width="600" height="530" alt="Screenshot 2025-09-16 at 11 07 03 PM" src="https://github.com/user-attachments/assets/fddb8d5f-1e88-4817-aed7-484e41b0e2ff" />

Fascinating. I'll close out this exhibit with some particularly beautiful maps (and sections of maps) produced by various input parameters.

> <img width="400" height="397" alt="Screenshot 2025-09-16 at 11 09 33 PM" src="https://github.com/user-attachments/assets/a2d20e5a-8119-4953-b11b-c525598f30fd" />
> <img width="400" height="398" alt="Screenshot 2025-09-16 at 11 11 48 PM" src="https://github.com/user-attachments/assets/71921f55-bf7e-46ff-b66f-a03ca28ec792" />
> <img width="400" height="398" alt="Screenshot 2025-09-16 at 11 13 42 PM" src="https://github.com/user-attachments/assets/642332b0-1761-475b-9ee9-cb1783a34885" />
> <img width="400" height="397" alt="Screenshot 2025-09-16 at 11 14 57 PM" src="https://github.com/user-attachments/assets/659099c1-608e-412e-bf55-c63a03d0244d" />
> <img width="400" height="397" alt="Screenshot 2025-09-16 at 11 17 38 PM" src="https://github.com/user-attachments/assets/932b4429-cf4c-4daa-afa4-a06175e909e0" />
> <img width="400" height="397" alt="Screenshot 2025-09-16 at 11 21 42 PM" src="https://github.com/user-attachments/assets/5f9ad630-ccbf-498d-824c-dcae50a8085b" />

