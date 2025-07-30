# Pickoff, Then Takeoff? Predicting Stolen Base Attempts After Pickoff Moves | 2025 SMT Data Challenge Submission

## Overview
As part of new Major League Baseball (MLB) rule changes (Castrovince, 2023), pitchers are limited to two disengagements (pickoff attempt or step-offs) per plate appearance before a third unsuccessful disengagement allows the runner to advance. This rule has heavily impacted baserunning philosophy and defensive strategies. This paper explores runner behavior after pickoff moves. Specifically, I built a tool that predicts pitch-by-pitch steal attempts, given that a pitcher has already thrown over at least once during the at-bat. The figure below displays the tool’s interactive Shiny App interface. The model is built using an XGBoost classifier trained and tested on pre-rule change MiLB player tracking data, with feature engineering designed to capture key elements of runner dynamics. The analysis highlights patterns and situations that indicate when a runner is likely to attempt a steal, providing decision-making insights for defenses. 

Try it [here](https://jayirby2.shinyapps.io/pickoff_or_takeoff/)
