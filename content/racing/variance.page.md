# Quantifying motorsport competitiveness

It's no secret that some motorsport disciplines are more competitive than others, but I've pretty much based my assessment of this on what I see on on-screen action and the sentiment of Reddit comments. In looking for a way to make these opinions more evidence-based I found [this paper](https://www.econstor.eu/obitstream/10419/51362/1/672457962.pdf) by Krauskopf, Langen, and Bünger that looked at measuring the competitiveness of Formula One over time. One of their key measurements was particularly interesting as a way to directly compare different motorsports and their seasons: the Gini coefficient.

![A pictorial representation of the Gini coefficient (by Reidpath, Wikimedia Commons)](/racing/gini.png)
*A pictorial representation of the Gini coefficient (by Reidpath, Wikimedia Commons)*

Invented by Corrado Gini, it seeks to determine the inequality of a population, by comparing the ideal distribution (uniform, represented by the *line of equality*) with the actual distribution (the *Lorenz curve*). The value of the coefficient is equal to the area marked *A*, divided by the total area (i.e. the area differing from the ideal distribution). The lower the coefficient, the more equal the distribution [1].

Using the Gini coefficient, the authors were able to quantify competitiveness over time. Applying their method, I extended the analysis to include comparisons between different motorsports.

## Method

First, I scraped data for the last ten seasons of the following motorsports from Wikipedia:

* Formula One
* Formula Two / GP2
* Formula Three / GP3
* Formula E
* Australian Supercars

Coincidentally, these happen to be the exact series I watch. I had a theory that the less experienced the drivers in the series, the more competitive it would be, hence the inclusion of the top three single-seater formulas. Although, since F2 and F3 are spec series, it's not a super fair comparison.

I predicted that Formula One would be the least competitive series, having sat through a turbo-hybrid era absolutely dominated by Mercedes and Lewis Hamilton, and the new Formula E the most competitive based on its on-track unpredictability.

Following the paper's method I then normalised the data to ensure that cross-comparison was fair. Instead of the series-assigned points, I recalculated the points for each race. For a race with N drivers, the winner received N points, the driver in second N - 1, and so on. All DNFs were excluded from that race. To remove outliers I deleted all drivers with less than 5 races in the season from the final distribution (particularly important in Supercars due to the co-drivers for endurance events).

Then, for each season I summed the total points per driver and calculated the Gini coefficient of the population with [numpy](https://numpy.org/).

## Results

![Comparison of Gini coefficients across racing series (lower is better)](/racing/giniplot.png)
*Comparison of Gini coefficients across racing series (lower is better)*

There are some clear trends in the results graph. As expected, with few exceptions F2 and F3 are more competitive than F1. The most competitive of all, since its second season, is Formula E. Obviously this is a very small sample size but it matches up with what I've judged the racing to be like so far. Supercars, sadly, seems to be getting worse in terms of competitiveness and sits well above the open-seater series.

This is a very quick analysis, and the standardised data could be used for much more. The inspiration paper also used the score difference between the first- and second-positioned drivers in the championship to quantify "topfield" competitivness, which would be cool to compare across series. I'd also like to split the data into frontrunners, midfield and backmarkers and compare the competitiveness of each (because let's be honest, a competitive race at the top end is much more exciting than two Williams fighting for second-last).

I've uploaded all the standardised data as CSV files [here](/racing/MotorsportsStandard.zip), so feel free to download and play around with the data yourself!

[1]: [Gini coefficient on Wikipedia](https://en.wikipedia.org/wiki/Gini_coefficient)
