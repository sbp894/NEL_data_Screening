clear;
clc;


allDataDir= '/media/parida/DATAPART1/Matlab/ExpData/MatData/';

all_dirs= dir([allDataDir 'SP*AN*']);

for dirVar= 1:length(all_dirs)
    DataDir= all_dirs(dirVar).name;
    ChinID=cell2mat(cellfun(@(x) sscanf(char(x{1}), '-Q%d*'), regexp(DataDir,'(-Q\d+_)','tokens'), 'UniformOutput', 0));
    update_doNANnums(ChinID);
end