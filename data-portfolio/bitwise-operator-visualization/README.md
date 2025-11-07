# Bitwise Operator Visualization

I was curious about how bitwise operations could be understood visually, and if they possessed any internal patterns that could be coaxed out graphically.

## Process

Standard import conventions:

```python
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator
import numpy as np
import pandas as pd
import seaborn as sns
```

We begin with creating a `DataFrame` to house a range of integers of our choosing, mimicking a cartesian grid. Our function will take in two arguments for a minimum and maximum value, and a third for the operation to perform.

```python
def bitwise_table(min_term, max_term, operation):
    table = pd.DataFrame(columns=[i for i in range(min_term, max_term + 1)])
    operation = operation.lower()
```

Note that the `operation` argument is immediately converted to lowercase. This will allow our table-builder to handle word arguments as well as symbol arguments all in a standardized way.

The table is then populated with a `match`-`case` tree. For each x-y pair, the results of their bitwise operation is stored at their intersection in the `DataFrame`.

```python
    match operation:
        case '&' | 'and':
            for i in range(min_term, max_term + 1):
                table.loc[i] = [(i & j) for j in range(min_term, max_term + 1)]
        case '|' | 'or':
            for i in range(min_term, max_term + 1):
                table.loc[i] = [(i | j) for j in range(min_term, max_term + 1)]
        case '^' | 'xor':
            for i in range(min_term, max_term + 1):
                table.loc[i] = [(i ^ j) for j in range(min_term, max_term + 1)]
        case _:
            print("Unsupported operation. Use one of the following: '&/and', '|/or', '^/xor'.")
    return table
```

The function yields the following, for example:

```python
print(bitwise_table(0, 5, '&'))
```

```python
   0  1  2  3  4  5
0  0  0  0  0  0  0
1  0  1  0  1  0  1
2  0  0  2  2  0  0
3  0  1  2  3  0  1
4  0  0  0  0  4  4
5  0  1  0  1  4  5
```

Now we can turn our visualization into a heatmap using `seaborn`.

## Making a Heatmap

Our heatmap function begins by generating a table using our function from earlier. We set `sort_index` to descending order so that our heatmap has the same orientation as a cartesian grid.

```python
def plot_bitwise_table(min_term, max_term, operation):
    table = bitwise_table(min_term, max_term, operation).sort_index(ascending=False)
```

After that, it's mostly gravy with some simple formatting and labeling.

```python
    fig = plt.figure()
    ax = fig.add_subplot(111)
    sns.heatmap(table, cmap='inferno', cbar_kws={'label':f'Bitwise {operation.upper()} Result'}, ax=ax)
    ax.set_title(f'Heatmap of Bitwise {operation.upper()} Operations from {min_term} to {max_term}', fontsize=14, color='black', fontweight='bold', pad=20)
    ax.set_xlabel('Operand 1', labelpad=10)
    ax.set_ylabel('Operand 2', labelpad=10)
    ax.tick_params(axis='x', rotation=90, labelsize=8, colors='grey')
    ax.tick_params(axis='y', labelsize=8, color='grey')
    plt.fontfamily = 'monospace'
    
    plt.show()
    return
```

Let's see what we have so far, and generate a heatmap covering the range 0 to 100 with an AND operation.

```python
print(plot_bitwise_table(0, 100, '&'))
```

RESULT:

Fascinating! Given that fractals are seemingly baked into binary's nature, it's not surprising that we see another self-similar pattern here. However, one has to admire the sheer beauty of it regardless.

Let's see how the other two operations look when visualized this way. Let's do OR next.

```python
print(plot_bitwise_table(0, 100, '|'))
```

RESULT:

Interesting... Due to OR being a more "permissive" operation than AND, we see many more high spots on our graph which persist as we ascend through larger and larger integers.

Finally, let's see XOR.

```python
print(plot_bitwise_table(0, 100, '^'))
```

RESULT:

This set is my personal favorite. We would expect XOR to be the most "particular" about how its resulting bits are set, but in this visualization we see a neat "saddle" effect with a diagonal ridge running from low-x/high-y to high-x/low-y. In many of these cases, we see a high value produced from these pairings because one of the two operands lives on an entirely different power of two than the other, which means that the highest-order bits in the result are nearly guaranteed to be set due to the lack of overlap.

For example:
```
111110100 (500)
000001011 (11)
-----XOR------
111111111 (511)
```

To round out this exhibit, let's take this visualization into 3D.

## 3D Visualization

We'll first set up the skeleton of our 3D plot by creating a variable to hold our `DataFrame` of results. We also need to set up the 3D plot itself.

```python
def three_d_plot(min_term, max_term, operation):
    data = bitwise_table(min_term, max_term, operation).sort_index(ascending=True).values
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
```

Next, we create the three arrays that will be plotted as one 3D surface. We create a range of ascending integers for our `x` and `y` values, and then make a `meshgrid` of the two. This means we will be left with two larger arrays that, taken together, produce every possible combination of (`x`,`y`) values we will need for our plot. Finally, we call the `plot_surface` method, and supply it with our additional z data, which are the values from our `DataFrame` from earlier.

```python
    x = np.arange(min_term, max_term + 1)
    y = np.arange(min_term, max_term + 1)
    X, Y = np.meshgrid(x, y)
    ax.plot_surface(X, Y, data, cmap='inferno')
```

We also set our axis labels, and adjust them to only display integer values.

```python
    ax.set_xlabel('Operand 1', fontsize=10, labelpad=10)
    ax.set_ylabel('Operand 2', fontsize=10, labelpad=10)
    ax.set_zlabel('Result', fontsize=10, labelpad=10)

    ax.xaxis.set_major_locator(MaxNLocator(integer=True))
    ax.yaxis.set_major_locator(MaxNLocator(integer=True))
    ax.zaxis.set_major_locator(MaxNLocator(integer=True))

    plt.show()
    return
```

Let's see the finished product, and graph the `AND` operation over the range of 0 to 500.

RESULT:

Dang! Who'd have thought we would get a Sierpinski-like structure out of this?

How does `OR` look by comparison?

RESULT:

Interesting. As we might have predicted, `OR` allows for a result set with generally higher values than `AND`, which means we will ascend to higher z-values more quickly, and stay there.

How about the 3D graph for `XOR`?

RESULT:

Sure enough, we see a 3D view of the saddle shape we saw earlier.

Despite the relative simplicity of bitwise operations, it's fascinating how quickly we can encounter complex behavior.