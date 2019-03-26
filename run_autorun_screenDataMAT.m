clear;
close all;
clc;

allfiles= dir('/media/parida/DATAPART1/Matlab/SNRenv/n_mr_env_corr_uRate/mr_corr_OUTPUT/InData/DanishData/*.mat');
fileNames= {allfiles.name}';
allChinIDs= cell2mat( cellfun(@(x) str2double(x(2:4)), fileNames, 'uniformoutput', false));

for chinVar= 1:length(allChinIDs)
    chinID= allChinIDs(chinVar);
    autorun_screenDataMAT(chinID);
end