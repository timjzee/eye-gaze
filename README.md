## What?

This repo contains some files that were used in a project that looked at the influence of different factors on Floor Transfer Offset (FTO) in the [IFADV corpus](http://www.fon.hum.uva.nl/IFA-SpokenLanguageCorpora/IFADVcorpus/) using a Random Forest analysis.

## Floor Transfer Offset (FTO)

FTO refers to the overlap or pause between two turns-at-talk by different speakers.

![alt text](https://github.com/timjzee/eye-gaze/blob/master/fto_dist.png?raw=true "fto distribution")

*Distribution of FTO (seconds) in the IFADV corpus.*

## Interactions between Eye gaze and processing factors

![alt text](https://github.com/timjzee/eye-gaze/blob/master/gazetree3.png?raw=true "factor interactions")

*A decision tree of the data based on eye gaze patterns and processing. The numbers in the grey boxes represent predicted FTO values in seconds.*

## Relative importance of all factors

![alt text](https://github.com/timjzee/eye-gaze/blob/master/varimp.png?raw=true "fto distribution")

*Variable importance measured as mean increase in prediction error when a variable is randomly permuted. Variables that do not cross the threshold indicated by the red line, do not make an important contribution to the model.*
