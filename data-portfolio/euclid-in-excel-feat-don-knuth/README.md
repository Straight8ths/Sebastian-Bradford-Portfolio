# Euclid in Excel (feat. Don Knuth)

Overcoming mathematical density with the use of visual calculation.

## Overview

I am continually humbled whenever I read anything written by Donald Knuth. His theoretical density and unrelenting rigor causes my brain to feel like it is running a marathon, uphill, in the mud. However, I discovered early on that I could use visual calculation methods in order to stay sane while reading his material. In this case, we'll be looking at the first section of his book _The Art of Computer Programming, Vol. 1_.

## Euclid's (Extended) Algorithm

### _Material from the text is displayed here for educational and non-commercial use only._

In section 1.2.1, Knuth outlines an extended version of Euclid's famous GCD algorithm. He writes the following:
- "Given two positive integers _m_ and _n_, we compute their greatest common divisor _d_, and we also compute two not-necessarily-positive integers _a_ and _b_ such that _am_ + _bn_ = _d_." (Knuth 13)

Knuth goes on to describe each step in this algorithm, with the inclusion of other variables _c_, _q_, _r_, _t_, _a'_, and _b'_.

> "E1. [Initialize] Set _a'_ <- _b_ <- 1, _a_ <- _b'_ <- 0, _c_ <- _m_, _d_ <- _n_." (Knuth 14)

> "E2. [Divide] Let _q_ and _r_ be the quotient and remainder, respectively, of _c_ divided by _d_. (We have _c_ = _qd_ + _r_ and 0 ≤ _r_ < _d_.)" (Knuth 14)

> "E3. [Remainder zero?] If r = 0, the algorithm terminates; we have in this case am + bn = d as desired. (Knuth 14)

> "E4. [Recycle] Set c <- d, d <- r, t <- a', a' <- a, a <- t - qa, t <- b', b' <- b, b <- t - qb, and go back to E2." (Knuth 14)

He concludes with an example calculation of the GCD of two integers, and a short table showing the progression of each variable's value as the algorithm continues. Upon seeing this, I wanted to take Knuth's concept farther and make a dynamic calculation tool where the user can see this progression across any GCD calculation.

After reading and rereading the above passage, I made an Excel workbook in the style of Knuth's table, where each variable occupies its own column, and the table progresses downward with reference to the prior row. From there came the tedious portion of writing formulas governing each variable's column, taken from subsection E4.

After that came conditional formatting such that whenever the _r_ variable becomes zero, the surrounding row is highlighted in green, and the cell for variable _d_ is emphasized. I also added IFERROR clauses to each column of formulas to reduce the visual clutter that would otherwise happen as the algorithm peters out.

Finally, I wired the first row of the table to accept input from two cells representing _m_ and _n_. The result is a fully-functional visualization of the algorithm.

<img width="500" height="288" alt="Image" src="https://github.com/user-attachments/assets/d975fca5-d611-46eb-84d7-7f85b4f45528" />

<img width="500" height="288" alt="Image" src="https://github.com/user-attachments/assets/f2a9315b-695a-4356-89e5-9ab49ef0579b" />

<img width="500" height="288" alt="Image" src="https://github.com/user-attachments/assets/1800e8aa-10cb-45f2-9784-697b1d8360b7" />

<img width="500" height="288" alt="Image" src="https://github.com/user-attachments/assets/75cd64df-c950-4d84-bcdd-bafcec02e47f" />

