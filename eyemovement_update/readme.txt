Note by Yong

A simple experiment where participants make saccades to targets that appear left or right side of the fixation mark.
Currently 3 and 6 degrees left/right, totaling 4 conditions. 15 trials per condition, 60 trials total.
Depending on your set up, you may have to implement the codes differently. Here's a quick description of what each function does.

eyeMovementMeasure_2
	- Main experiment function.
Initialize
	- This starts up the screen and collect participant information. Somewhat analogous to dialogID.

Perferences
	- This defines various information about the experimental set up.

initializePort & sendEventCode
	- These are functions that send event codes to our EEG system (BrainVision). Please change these to your experimental set-up.

We have 15 trials for each left/right and 3/6 degrees condition. We can do a simple ERP analysis of the HEOG channel response collapsing the left/right sides, and find the mean amplitude of the specific saccade magnitude.

Event codes are sent at the onset of the saccade target, and we ask participants to move their eyes as soon as possible. Another event code is sent when participants press space bar, reporting that they are now fixating on the new (red) saccade target. After the space-bar participants are told to move their eyes back to the center fixation until the next saccade target shows up.

Current event codes: 
101 - left 6 degree saccade
102 - left 3 degree saccade
103 - right 3 degree saccade
104 - right 6 degree saccade
