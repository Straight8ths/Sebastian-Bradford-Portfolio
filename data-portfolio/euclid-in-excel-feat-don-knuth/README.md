# Euclid in Excel (feat. Don Knuth)

Overcoming mathematical density with the use of visual calculation.

## Overview

I am continually humbled whenever I read anything written by Donald Knuth. His theoretical density and unrelenting rigor causes my brain to feel like it is running a marathon, uphill, in the mud. However, I discovered early on that I could use visual calculation methods in order to stay sane while reading his material. In this case, we'll be looking at the first section of his book _The Art of Computer Programming, Vol. 1_.

_Material from the text is displayed here for educational and non-commercial use only._

In section 1.2.1, Knuth outlines an extended version of Euclid's famous GDC algorithm. He writes the following:
- "Given two positive integers _m_ and _n_, we compute their greatest common divisor _d_, and we also compute two not-necessarily-positive integers _a_ and _b_ such that _am_ + _bn_ = _d_." (Knuth 13)

Knuth goes on to describe each step in this algorithm, with the inclusion of other variables _c_, _q_, _r_, _t_, _a'_, and _b'_.

- "E1. [Initialize] Set _a'_ <- _b_ <- 1, _a_ <- _b'_ <- 0, _c_ <- _m_, _d_ <- _n_