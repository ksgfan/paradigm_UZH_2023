## This folder contains experimental code for the replication of Vogel, E. K., & Machizawa, M. G. (2004). Neural activity predicts individual differences in visual working memory capacity. Nature, 428(6984), 748–751.

## IMPORTANT!
1. Ensure that the paths in master.m are correct.
2. Verify that the screen resolution and refresh rate are set correctly in /funs/screenParams.m.
3. Double-check that dist_cm and monitorwidth_cm are set correctly in /funs/screenParams.m.
4. Confirm that equipment.viewDist and equipment.ppm are set correctly in /funs/EEGManyLabs_CDA_18_7_2022.m.
5. Verify the proper configuration for sending EEG and ET triggers in /eyemovement_update/eyeMovementMeasure_2.m, /funs/EEGManyLabs_CDA_18_7_2022.m and /funs/Resting_EEG.m.
6. Please note that subject IDs MUST consist of 2 numbers (e.g., 01, 02, …, 10, 11, etc.)


## Triggers for eye movement measure:

* 9 - start trigger
* 89 - end trigger
* 101 - left 6 degree saccade
* 102 - left 3 degree saccade
* 103 - right 3 degree saccade
* 104 - right 6 degree saccade
* 55 - response (spacebar)

## Triggers for Resting EEG

10 - start trigger
90 - end trigger
20 - eyes open
30 - eyes closed

Triggers for CDA task:

TASK_START = 11/12/13/14/15;
TASK_END = 91/92/93/94/95;
CUE_LEFT = 3;
CUE_RIGHT = 7;
SETSIZE2 = 21;
SETSIZE4 = 41;
SETSIZE6 = 61;
RETENTION = 50;
TEST2 = 22;
TEST4 = 42;
TEST6 = 62;
RESP_SAME_CORR = 76;
RESP_DIFF_CORR = 77;
RESP_SAME_INCORR = 78;
RESP_DIFF_INCORR = 79;

Timing for CDA task (all in seconds):
timing.cue = .2;                    % Duration of arrow cue
timing.minSOA = .3;                 % Minimum stimulus onset asynchrony
timing.maxSOA = .4;                 % Maximum stimulus onset asynchrony
timing.memoryArray = .1;            % Duration of memory array
timing.retentionInterval = 0.9;     % Duration of blank retention interval
timing.testArray = 2;               % Duration of test array                 
timing.minITI = .3;                 % Duration of the inter-trial interval     
timing.maxITI = .4;                 % Duration of the inter-trial interval
