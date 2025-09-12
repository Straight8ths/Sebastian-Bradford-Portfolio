# Krzywinski Similarity Numbers in Python

Using Python to explore the quirks of irrational numbers.

Please visit (and support) Martin Krzywinski's blog. I'm not an affiliate, just a supporter who loves his work.

## Concept

I first saw Martin outline this concept on [this blog page](https://mk.bcgsc.ca/pi/art/accidental-similarity/method.mhtml#l2home). He puts forth an interesting process by which to examine multiple irrational numbers next to each other, and compare the positions where the given digit is the same, for all numbers being compared.

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
e = clean_text_file('/Users/me/my_file_path/e_million.rtf')

pi = clean_text_file('/Users/me/my_file_path/pi_million.rtf')
```

The variables of choice are put into a list for easy unpacking later on.

```python
var_stack = [e, pi]
```

Now the real work starts. We make a dictionary that will hold digit positions, and the digit itself which is identical across all numbers. Our list of variables is unpacked element-wise, zipped, and checked for member-wide equality. If so, the dictionary is updated.

```python
similar = {}

for ix, (a, b) in enumerate(zip(*var_stack)):
    if a == b and a == c:
        similar[ix] = a
```

I wrote the equality checking line the way I did so that as more variables are added, the test is allowed to fail (and the code to continue) as early as possible when all digits are not the same.

Now we can print our results as a clean sentence, and optionally save our work to a CSV with the same columns of "Index" and "Digit".

print(f"These {len(var_stack)} numbers have {len(similar)} same digits at identical indices.")

```python
df = pd.DataFrame(similar.items(), columns=['Index', 'Digit'])
df.to_csv('similar_digits.csv', index=False)
```