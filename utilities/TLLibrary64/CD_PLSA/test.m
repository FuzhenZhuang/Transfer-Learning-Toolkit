
% This is an example to show how to use our software
% If you come across the problem 'out of memory ...', refer to the readme
% file again.

Train_Data = 'Train_Data.txt';
Test_Data = 'Test_Data.txt';
Parameter_Setting = 'Parameter_Setting.txt';

[Results, pzd] = CD_PLSA(Train_Data,Test_Data,Parameter_Setting);

