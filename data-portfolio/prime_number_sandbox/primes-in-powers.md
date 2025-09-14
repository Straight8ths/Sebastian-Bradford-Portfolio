# Primes in Powers

Using Python and Pandas to analyze prime distribution by exponents.

## Overview

I was curious as to how primes are concentrated when analyzed with respect to exponents. For example, how would we expect primes to appear within the range of 10 - 100, compared to the range of 100 - 1,000, or 1,000 to 10,000? More broadly, what do we think would happen as we changed our base to something besides 10?

## Process

Standard import conventions:

```python
import primePy.primes as primes
import pandas as pd
import matplotlib.pyplot as plt
```

In order to get maximum flexibility for analysis, we'll construct a function that can take any base, and any exponent which serves as a ceiling. We first make a dataframe with three columns: The floor and ceiling of each range, and the number of primes therein.

```python
def primes_in_powers(base, max_exponent):
    powers = pd.DataFrame(columns=['Lower (inc.)', 'Upper (exc.)', '# of primes'])
```

Now we use the primePy module to count primes between each floor and ceiling as we ascend through the exponents. We set our floor and ceiling, run the primes.between() method on the range, and store our values in a single-row dataframe which is then appended onto the initial one we created. This repeats for ascending exponents up to the *max_exponent* we provided.

```python
    for exponent in range(1, max_exponent + 1):
        lower = base ** (exponent - 1)
        upper = base ** exponent
        prime_count = len(primes.between(lower, upper))
        powers = pd.concat([powers, pd.DataFrame({'Lower (inc.)': [lower], 'Upper (exc.)': [upper], '# of primes': [prime_count]})], ignore_index=True)
```

**A note on the primePy module**: The primes.between() method seems to behave *inclusively* for its given lower bound, but *exclusively* for its given upper bound. For example, when I run this:
```python
print(primes.between(5,17))
```
I get this:
```python
[5, 7, 11, 13]
```

Our function concludes by returning our table now that all concatenations are finished.

```python
    return powers
```

Let's call this function with a base of 10, up to an exponent of 6, and see what we find.

```python
print(primes_in_powers(10, 6))
```

```python
  Lower (inc.) Upper (exc.) Prime Count
             1           10           4
            10          100          21
           100         1000         143
          1000        10000        1061
         10000       100000        8363
        100000      1000000       68906
```

How about a base of 7 and a max power of 8?

```python
print(primes_in_powers(7, 8))
```

```python
  Lower (inc.) Upper (exc.) Prime Count
             1            7           3
             7           49          12
            49          343          53
           343         2401         289
          2401        16807        1582
         16807       117649        9159
        117649       823543       54587
        823543      5764801      332079
```

Interesting. Let's graph it.

Our plotting function takes the same inputs, and immediately creates a dataframe as before.

```python
def plot_primes_in_powers(base, max_exponent):
    df = primes_in_powers(base, max_exponent)
```

Once we establish our labels and layout, we also need to make sure to change our plt.yscale attribute to "log".

```python
    plt.figure(figsize=(8, 8))
    plt.bar(df.index, df['Prime Count'], color='skyblue')
    plt.yscale('log')
    plt.xticks(df.index, [f"{base}^{i}" for i in range(1, max_exponent + 1)], color='grey')
    plt.xlabel(f'Range (Powers of {base})', color='grey')
    plt.yticks(color='grey')
    plt.ylabel('Number of Primes (Log Scale)', color='grey')
    plt.title(f'Number of Primes in Powers of {base} up to {base}^{max_exponent}', fontsize=14, color='black', fontweight='bold', pad=20)
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.fontfamily = 'monospace'
    plt.show()
```

Let's run this and graph our two tables from earlier.

```python
print(plot_primes_in_powers(10,6))
```



```python
print(plot_primes_in_powers(7,8))
```

