# Krzywinski Similarity Numbers in Python

Using Python to explore the quirks of irrational numbers.

**Please visit (and support) Martin Krzywinski's blog. I'm not an affiliate, just a supporter who loves his work.**

## Concept

I first saw Martin outline this concept on [this blog page](https://mk.bcgsc.ca/pi/art/accidental-similarity/method.mhtml#l2home). He puts forth an interesting process by which to examine the decimal components from multiple irrational numbers simultaneously, and look for places where all the irrationals share the *same digit* at the *same position*.

I wanted to put forward my personal process for achieving this in Python.

## Process

Imports:

```python
import pandas as pd
from striprtf.striprtf import rtf_to_text
```

I chose to source my numbers and store them in text files to be read from. There is a cleaning function which assumes TXT input, but can handle RTF too.

```python
def clean_text_file(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    if content.startswith('{\\rtf'):
        content = rtf_to_text(content)
    cleaned_text = ''.join(content.split())
    return cleaned_text
```

The files are loaded, cleaned, and stored in descriptive variables.
```python
euler = clean_text_file('/Users/me/my_file_path/e_million.rtf')

pi = clean_text_file('/Users/me/my_file_path/pi_million.rtf')
```

The variables of choice are put into a list for easy unpacking later on.

```python
var_stack = [euler, pi]
```

Now the real work starts. We make a dictionary that will hold digit positions, and the digit itself which is identical across all numbers. Our list of variables is unpacked element-wise, zipped, and checked for member-wide equality. If so, the dictionary is updated.

```python
similar = {}

for ix, (a, b) in enumerate(zip(*var_stack)):
    if a == b:
        similar[ix] = a
```

I wrote the equality checking line the way I did so that as more variables are added, the test is allowed to fail (and the code to continue) as early as possible when all digits are not the same.

Now we can print our results as a clean sentence...

```python
print(f"These {len(var_stack)} numbers have {len(similar)} same digits at identical indices.")
```

... and save our work to a CSV with the same columns of "Index" and "Digit".

```python
df = pd.DataFrame(similar.items(), columns=['Index', 'Digit'])
df.to_csv('similar_digits.csv', index=False)
```

## Interesting Findings

Let's check the amount of similar digits we end up with, as a function of how many source numbers we choose to compare. We'll use 1,000,000 digits from each of our first two irrationals (pi and e) and then add more irrationals to examine.

### Two Irrationals (pi, e)

```python
These 2 numbers have 99984 same digits at identical indices.
```

### Three Irrationals (pi, e, sqrt_2)

```python
These 3 numbers have 10111 same digits at identical indices.
```

### Four Irrationals (pi, e, sqrt_2, sqrt_3)

```python
These 4 numbers have 1030 same digits at identical indices.
```

### Five Irrationals (pi, e, sqrt_2, sqrt_3, sqrt_5)

```python
These 5 numbers have 109 same digits at identical indices.
```

### Scaling Phenomenon
We can observe a scaling down by a factor of 10 each time a new number is added, which effectively represents a new probabilistic hurdle that must be passed for the similarity to continue to hold (i.e. drawing the "correct" next digit out of the possible 10).

Let's add a function to check the frequency distribution for the digits of each of our irrationals, to ensure that these numbers satisfy the definition of *normal numbers*, at least enough for our purposes.

Given that our input files contain (almost exactly) 1,000,000 digits each, we should be seeing close to 100,000 of each digit.

```python
def value_table(v):
    value_tab = pd.Series(list(v)).value_counts().sort_index()
    value_tab['Sum'] = value_tab.sum()
    value_tab.index.name = 'Digit'
    value_tab.name = 'Frequency'
    return value_tab
```
## Pi Digits and Frequencies
```python
.            1
0        99959
1        99758
2       100026
3       100230
4       100230
5       100359
6        99548
7        99800
8        99985
9       100106

Sum    1000002
```

## e Digits and Frequencies
```python
.            1
0        99425
1       100136
2        99848
3       100231
4       100390
5       100089
6       100481
7        99913
8        99816
9        99692

Sum    1000022
```

## sqrt_2 Digits and Frequencies
```python
.            1
0        99830
1        98938
2       100454
3       100203
4       100043
5       100171
6        99897
7       100024
8       100459
9       100138

Sum    1000158
```

## sqrt_3 Digits and Frequencies
```python
.            1
0       100238
1        99591
2        99814
3        99820
4        99900
5       100261
6       100560
7        99924
8       100057
9        99860

Sum    1000026
```

## sqrt_5 Digits and Frequencies
```python
.            1
0        99385
1       100492
2        99855
3       100471
4        99798
5        99898
6       100485
7        99589
8        99804
9       100248

Sum    1000026
```

Because the zip function stops at the end of the shortest iterable that is fed into it, it's alright that some of our irrationals come with more than 1,000,000 digits exactly. The pi file acts as the hard stop, with exactly the right amount once you subtract two digits for the initial 3 and the decimal.