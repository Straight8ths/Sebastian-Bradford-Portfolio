# Text Genomes

I was curious about what it would look like to reduce different pieces of text into their most "atomic" components, that is, the structure and distribution of the letters in their words.

## Method

We begin by reading in a piece of text stored in a local TXT or RTF file. We'll be using scaffolding from the *clean_text_file()* function in my *Krzywinski Similarity Numbers* exhibit. In this case, however, we will add some chained calls to the *replace()* function to remove punctuation marks from our source text, given that we are only concerned with letters.

```python
def clean_text_file(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    if content.startswith('{\\rtf'):
        content = rtf_to_text(content)
    content = content.replace('—', ' ').replace("'", "").replace(':', ' ').replace(';', ' ').replace(',', ' ').replace('.', ' ').replace('!', ' ').replace('?', ' ')
    content = ''.join(c for c in content if c.isalpha() or c.isspace())
    cleaned_text = content.split()
    return cleaned_text
```

We'll store our newly loaded and cleaned text in a variable called *source_text*.

```python
source_text = clean_text_file('/Users/me/mypath/source_text.txt')
```

Next, we need to create a dataframe to house one word in each row, with each letter in its own cell. The width of our dataframe will be determined by the length of the longest word in our sample.

```python
def letter_grid(word_list):
    table = pd.DataFrame(columns=range(1, max(len(i) for i in word_list) + 1))
```

Next, we use the *loc()* method to add in our rows on the fly as the computer reads down our list of words. We also use the *list()* function to split each word into its constituent letters, fill them into the row, and fill the remaining spaces with null strings ('').

```python
    for i in range(1, len(word_list) + 1):
        table.loc[i] = list(word_list[i-1]) + [''] * ((max(len(i) for i in word_list) - len(word_list[i-1])))
    return table
```

Let's test our work up to this stage with a source file containing some Shakespeare.

```python
   1  2  3  4  5  6  7
1  S  h  a  l  l      
2  I                  
3  c  o  m  p  a  r  e
4  t  h  e  e         
5  t  o               
6  a                  
7  s  u  m  m  e  r  s
8  d  a  y     
```

Sweet! Now, we create a new dataframe that turns these letters into integers representing their positions in the alphabet. To do this, we turn all of our input to lowercase, and then call on a trick I learned from *The C Programming Language* by Kernighan and Ritchie. We will use the *ord()* function to return the Unicode representation of each letter, subtract the *ord()* value of the letter 'a' from it, and add 1. This will turn 'a' into 1, 'b' into 2, and so on. Moreover, every non-letter (like our null strings from earlier) will be turned into a NaN value so that we can ignore them in our visualizations later on.

```python
def letter_position(letter):
    letter = letter.lower()
    position = ord(letter) - ord('a') + 1 if letter.isalpha() else np.nan
    return position
```

Now comes the fun part. Our plotting function begins by creating our initial grid of letters, and applies a map over the dataframe to arrive at the alphabet positions. We also define a mask to use in our heatmap, which is an array of booleans that is the same size as our source data, with values of True occuring wherever our source data is null. When we pass this mask into Seaborn's heatmap() function, it will ignore these masked cells so that their values do not throw off the color-coding of our graph.

```python
def position_grid(word_list):
    starting_grid = letter_grid(word_list)
    letter_positions = starting_grid.applymap(letter_position)
    mask = letter_positions.isna()
    plt.figure(figsize=(4, 8))
    sns.heatmap(letter_positions, cmap='viridis', cbar_kws={'label': 'Letter Position'}, mask = mask)
    plt.title('Heatmap of Letter Positions in Frankenstein', fontsize=10, color='black', fontweight='bold', pad=20)
    plt.xlabel('Letter Position in Word', labelpad=10)
    plt.ylabel('Word Index', labelpad=10)
    plt.xticks(rotation=90, fontsize=8, color='grey')
    plt.yticks(fontsize=8, color='grey')
    plt.fontfamily = 'monospace'
    plt.show()
```

Let's call this with the same Shakespeare line from earlier:

> *"Shall I compare thee to a summer's day?"*

```python
print(position_grid(source_text))
```

<img width="400" height="410" alt="Screenshot 2025-09-17 at 11 21 21 PM" src="https://github.com/user-attachments/assets/9ab93d22-7d56-4165-8c59-124c11da4212" />

Brilliant! Let's try the whole sonnet.

> *Shall I compare thee to a summer’s day?*  
> *Thou art more lovely and more temperate:*  
> *Rough winds do shake the darling buds of May,*  
> *And summer’s lease hath all too short a date:*  
> *Sometime too hot the eye of heaven shines,*  
> *And often is his gold complexion dimmed,*  
> *And every fair from fair sometime declines,*  
> *By chance, or nature’s changing course untrimmed:*  
> *But thy eternal summer shall not fade,*  
> *Nor lose possession of that fair thou ow’st,*  
> *Nor shall death brag thou wand'rest in his shade,*  
> *When in eternal lines to time thou grow’st,*  
> *So long as men can breathe or eyes can see,*  
> *So long lives this, and this gives life to thee.*  

<img width="400" height="492" alt="Screenshot 2025-09-17 at 11 23 54 PM" src="https://github.com/user-attachments/assets/3abe49a6-3563-4fda-b678-651a1cc4819a" />


Alrighty. Let's look at some other pieces of text and compare their "genomes."

### Oliver Twist by Charles Dickens - First Paragraph

> *Among other public buildings in a certain town, which for many reasons it will be prudent to refrain from mentioning, and to which I will assign no fictitious name, there is one anciently common to most towns, great or small: to wit, a workhouse; and in this workhouse was born; on a day and date which I need not trouble myself to repeat, inasmuch as it can be of no possible consequence to the reader, in this stage of the business at all events; the item of mortality whose name is prefixed to the head of this chapter.*

<img width="400" height="561" alt="Screenshot 2025-09-17 at 11 25 44 PM" src="https://github.com/user-attachments/assets/1cb8968e-68fd-49f9-92a8-7cc4ebb952e6" />

### Moby Dick by Herman Melville - First Paragraph

> *Call me Ishmael. Some years ago—never mind how long precisely—having little or no money in my purse, and nothing particular to interest me on shore, I thought I would sail about a little and see the watery part of the world. It is a way I have of driving off the spleen and regulating the circulation. Whenever I find myself growing grim about the mouth; whenever it is a damp, drizzly November in my soul; whenever I find myself involuntarily pausing before coffin warehouses, and bringing up the rear of every funeral I meet; and especially whenever my hypos get such an upper hand of me, that it requires a strong moral principle to prevent me from deliberately stepping into the street, and methodically knocking people’s hats off—then, I account it high time to get to sea as soon as I can. This is my substitute for pistol and ball. With a philosophical flourish Cato throws himself upon his sword; I quietly take to the ship. There is nothing surprising in this. If they but knew it, almost all men in their degree, some time or other, cherish very nearly the same feelings towards the ocean with me.*

<img width="400" height="547" alt="Screenshot 2025-09-17 at 11 27 53 PM" src="https://github.com/user-attachments/assets/3bbfdef5-2f86-4cff-bddf-6d701767a3b1" />

### Frankenstein by Mary Shelley - First Paragraph

> *I am by birth a Genevese, and my family is one of the most distinguished of that republic. My ancestors had been for many years counsellors and syndics, and my father had filled several public situations with honour and reputation. He was respected by all who knew him for his integrity and indefatigable attention to public business. He passed his younger days perpetually occupied by the affairs of his country; a variety of circumstances had prevented his marrying early, nor was it until the decline of life that he became a husband and the father of a family.*

<img width="400" height="588" alt="Screenshot 2025-09-17 at 11 44 03 PM" src="https://github.com/user-attachments/assets/44dd5a29-04db-4810-8e2c-67514f551c71" />
