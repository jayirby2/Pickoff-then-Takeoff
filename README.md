# Pickoff, Then Takeoff? Predicting Stolen Base Attempts After Pickoff Moves | 2025 SMT Data Challenge Submission

## Overview
I built a tool that predicts steal attempts on a pitch-by-pitch basis, given that a pitcher has already thrown over at least once during the at-bat. 
There are several existing projects that predict stolen base outcomes. This type of framework is valuable, as it provides a reliable estimate of whether a 
runner is likely to be safe given the game circumstances. However, this approach does not attempt to predict if and when a runner is going to steal, nor does it 
focus on runner aggression after pickoff moves. My project fills in both of these gaps. My tool takes into account scenarios where a pitcher has already thrown over,
effectively modeling runner aggression during these conditions. Runners potentially behave differently after pickoff moves. 
By focusing on post-pickoff scenarios, this framework captures a critical and underexplored part of the running game, providing informed decision-making insight for teams. 

Try it [here](https://jayirby2.shinyapps.io/pickoff_or_takeoff/)
