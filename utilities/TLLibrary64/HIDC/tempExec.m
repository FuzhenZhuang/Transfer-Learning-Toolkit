clear all;
Train_Data = 'Train_Data.txt';
Test_Data = 'Test_Data.txt';
Parameter_Setting = 'Parameter_Setting.txt';
[Results_TTL, Gt_TTL] = GenerativeTriTL(Train_Data,Test_Data,Parameter_Setting);

% Train_Data = 'Train_Data.txt';
% Test_Data = 'Test_Data.txt';
% Parameter_Setting = 'Parameter_SettingDTLGen.txt';
% [Results_TTL, Gt_TTL] = GenerativeDTL(Train_Data,Test_Data,Parameter_Setting);