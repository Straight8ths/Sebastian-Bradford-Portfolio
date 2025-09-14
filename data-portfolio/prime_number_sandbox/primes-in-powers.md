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