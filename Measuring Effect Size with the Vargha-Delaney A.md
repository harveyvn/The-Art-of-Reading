# AC3R: Research p-value and A12



- **Statistical significance**: shows an effect exists in a study
- **Practical significance**: shows an effect is large enough to be meaningful
- Statistical significance is denoted by **p-values**, whereas practical significance is represented by **effect sizes**.

# I.  An Introduction to t-tests

## 1.  When to use a t-test

- A t-test is a statistical test that is used to **compare the means of two groups**.
- The t-test is a parametric test of difference, meaning that it makes the same assumptions about your data as other parametric tests. The t-test assumes your data:
    1. are independent
    2. are normally distributed

        ```python
        import numpy as np 
        import pylab 

        stats.probplot(np.array([data]), dist="norm", plot=pylab)
        pylab.show()
        ```

    3. have a same homogeneity of variance

        ```python
        variance = np.array([data]).var(ddof=1)
        ```

## 2.  What type of t-test should I use?

### **One-sample, two-sample, or paired t-test?**

- If the groups come from a single population (e.g. measuring before and after an experimental treatment), perform a **paired t-test**.
- If the groups come from two different populations (e.g. two different species, or people from two separate cities), perform a **two-sample t-test** (a.k.a. **independent t-test**).
- If there is one group being compared against a standard value (e.g. comparing the acidity of a liquid to a neutral pH of 7), perform a **one-sample t-test**.

### **One-tailed or two-tailed t-test?**

- If you only care whether the two populations are different from one another, perform a **two-tailed t-test**.
- If you want to know whether one population mean is greater than or less than the other, perform a **one-tailed t-test.**

## 3.  Performing a t-test

```python
import numpy as np
from scipy import stats, special

a, b = np.array([data]), np.array([data])

# Use scipy.stats.ttest_ind.
t, p = stats.ttest_ind(a, b, equal_var=False)
print("ttest_ind: t = %g  p = %g" % (t, p))

# Compute the descriptive statistics of a and b.
a_mean = a.mean()
a_var = a.var(ddof=1)
a_n = a.size
a_dof = a_n - 1

b_mean = b.mean()
b_var = b.var(ddof=1)
b_n = b.size
b_dof = b_n - 1

# Calculate t-test and p-value
t = (a_mean - b_mean) / np.sqrt(a_var/a_n + b_var/b_n)
dof = (a_var/a_n + b_var/b_n)**2 / (a_var**2/(a_n**2*a_dof) + b_var**2/(b_n**2*b_dof))
p = 2*special.stdtr(dof, -np.abs(t))

print("formula:   t = %g  p = %g" % (t, p))
```

**Sample Conclusion**

The output p-value of 4.79501e-11 is much smaller than 0.05, so we can reject the null hypothesis of no difference and say with a high degree of confidence that the true difference in means is not equal to zero.

# II.  Mann Whitney U Test

## 1.  When to use Mann Whitney U Test

- Mann Whitney U Test is used to test whether two samples are likely to derive from the same population (i.e., **that the two populations have the same shape**).
- When comparing two independent samples when the outcome is **not normally distributed** and the **samples are small**, a nonparametric test is appropriate.
- Some investigators interpret this test as comparing the medians between the two populations.

## 2.  Performing Mann Whitney U Test

- Step 1: Set up hypotheses and determine level of significance
- Step 2: Select the appropriate test statistic
- Step 3: Set up the decision rule
- Step 4: Compute the test statistic
- Step 5: Conclusion

```python
from scipy import stats

d1 = np.array([7500, 8000, 2000, 550, 1250, 1000, 2250, 6800, 3400, 6300, 9100, 970, 1040, 670])
d2 = np.array([400, 250, 800, 1400, 8000, 7400, 1020, 6000, 920, 1420, 2700, 4200, 5200, 4100])
# compare samples
stat, p = stats.mannwhitneyu(a, b)
print('Test Statistics=%.3f, p=%.3f' % (stat, p))
# interpret
alpha = 0.05
if p > alpha:
	print('H0: The two populations are equal versus. Donot reject H0.')
else:
	print('H1: The two populations are different. Reject H0.')
```

# III.  Measuring Effect Size with the Vargha-Delaney A measure

## 1.  When to use VDA

- We have two sets of non-paired numbers, and we wanted to know if they were different, and if so, how different they were.
- To that, we used Mann Whitney U Test / t-test, which told us they were different (we got a significant p-value). To understand how different they were (the effect size), we used VDA.
- The A measure is good technique because it is: agnostic to the underlying distribution of the data; easy to interpret; fast and easy to compute; and compatible with real numbers (continuous or not) and ordinal data.

## 2.  Performing VDA

```python
import itertools as it

from bisect import bisect_left
from typing import List

import numpy as np
import pandas as pd
import scipy.stats as ss

from pandas import Categorical

def VD_A(treatment: List[float], control: List[float]):
    m = len(treatment)
    n = len(control)

    if m != n:
        raise ValueError("Data d and f must have the same length")

    r = ss.rankdata(treatment + control)
    r1 = sum(r[0:m])

    # Compute the measure
    # A = (r1/m - (m+1)/2)/n # formula (14) in Vargha and Delaney, 2000
    A = (2 * r1 - m * (m + 1)) / (2 * n * m)  # equivalent formula to avoid accuracy errors

    levels = [0.147, 0.33, 0.474]  # effect sizes from Hess and Kromrey, 2004
    magnitude = ["negligible", "small", "medium", "large"]
    scaled_A = (A - 0.5) * 2

    magnitude = magnitude[bisect_left(levels, abs(scaled_A))]
    estimate = A

    return estimate, magnitude

# negligible
F = [0.8236111111111111, 0.7966666666666666, 0.923611111111111, 0.8197222222222222, 0.7108333333333333]
G = [0.8052777777777779, 0.8172222222222221, 0.8322222222222223, 0.783611111111111, 0.8141666666666666]
print(VD_A(G, F))

# small
A = [0.478515625, 0.4638671875, 0.4638671875, 0.4697265625, 0.4638671875, 0.474609375, 0.4814453125, 0.4814453125,
      0.4697265625, 0.4814453125, 0.474609375, 0.4833984375, 0.484375, 0.44921875, 0.474609375, 0.484375,
      0.4814453125, 0.4638671875, 0.484375, 0.478515625, 0.478515625, 0.45703125, 0.484375, 0.419921875,
      0.4833984375, 0.478515625, 0.4697265625, 0.484375, 0.478515625, 0.4638671875]
B = [0.4814453125, 0.478515625, 0.44921875, 0.4814453125, 0.4638671875, 0.478515625, 0.474609375, 0.4638671875,
      0.474609375, 0.44921875, 0.474609375, 0.478515625, 0.478515625, 0.474609375, 0.4697265625, 0.474609375,
      0.45703125, 0.4697265625, 0.478515625, 0.4697265625, 0.4697265625, 0.484375, 0.45703125, 0.474609375,
      0.474609375, 0.4638671875, 0.45703125, 0.474609375, 0.4638671875, 0.4306640625]

print(VD_A(A, B))

# medium
C = [0.9108333333333334, 0.8755555555555556, 0.900277777777778, 0.9274999999999999, 0.8777777777777779]
E = [0.8663888888888888, 0.8802777777777777, 0.7816666666666667, 0.8377777777777776, 0.9305555555555556]
print(VD_A(C, E))

# Large
D = [0.7202777777777778, 0.77, 0.8544444444444445, 0.7947222222222222, 0.7577777777777778]
print(VD_A(C, D))
```

VDA  tells us how often, on average, one population outperforms the other. When applied to two populations, the A measure is a value between 0 and 1: 

- A = 0.5: two populations are equal
- A < 0.5: the first population is better
- A > 0.5: the second population is better

The closer to 0.5, the smaller the difference between the populations; the farther from 0.5, the larger the difference.

# IV.  References

[Mann Whitney U Test (Wilcoxon Rank Sum Test)](https://sphweb.bumc.bu.edu/otlt/mph-modules/bs/bs704_nonparametric/bs704_nonparametric4.html)

[Measuring effect size with the Vargha-Delaney A measure](http://doofussoftware.blogspot.com/2012/07/measuring-effect-size-with-vargha.html#appendix)

[mtorchiano/effsize](https://github.com/mtorchiano/effsize/blob/master/R/VD_A.R)