# **Conditional Formatting as an Art Engine**

A quirky take on algorithmic art.

## Overview

_"Conditional Formatting" hereafter referred to as "CF"_

After years of using Excel as my daily driver, I am continually impressed by the strength of the program's conditional formatting engine. This capability allows the user to change the appearance of cells in their workbook only if the cells in question meet certain criteria. Often, we might hardcode a certain number value as a formatting rule, and change the fill color of cells that are above or below that value.

However, the CF engine has strengths far beyond this, and we can implement more versatility both on the _rules_ side as well as the _appearance_ side. We can create rules based on hardcoded numbers, group averages, and even fully-fledged custom formulas if we wish. In terms of cell appearances, we can alter a cell's border colors, give it a patterned fill, change the color of the text inside it, and more. 

Therefore, because we simultaneously have a palette of rule styles to choose from, as well as multiple types of visual modifications to make based on those rules, _we now have a decent engine by which to make "algorithmic art"._

Following are my chosen steps to making art with CF. This not any kind of "optimal" method, and the user can follow any steps they wish. The steps below are merely here for inspiration.

- Disable gridlines to create blank space
    - "View" ribbon menu -> Toggle "Gridlines" off.

- Create the "canvas"
    - Section off a block of blank cells by adding an "outside" border to that range.

- Implement randomness
    - I highly recommend using Excel's randomness capabilities in conjunction with CF, because random-based formulas will recalculate every time the sheet is refreshed. This means that the user can motion and animation to their art to make it dynamically responsive.
    - Apply the RANDBETWEEN function over any desired ranges of cells you want, so that these cells will consistently produce new values in your chosen range every time the sheet is refreshed.

- Prevent the numbers from appearing inside the cells
    - Select your range of cells, move to the "Home" ribbon menu, and open the menu of cell formats to apply a custom format.
    - When the custom-format dialogue box opens, type three semicolons (;;;) as your format code. This will prevent the cells from displaying their numerical values, although they will continue to be calculated behind the scenes.

- Implement CF rules
    - 