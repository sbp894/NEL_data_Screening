function allFiles_1= update_doNANnums(chinID)

CodesDir='/media/parida/DATAPART1/Matlab/Screening/';
MATDataDir='/media/parida/DATAPART1/Matlab/ExpData/MatData/';
BadLine_OutDir= '/media/parida/DATAPART1/Matlab/GeneralOutput/BADlines_org/';

valid_fPostFix= {'_SR', '_RLF', '_SNRenv'};


addpath(CodesDir);

checkDIR=dir(sprintf('%s*Q%d*',MATDataDir,chinID));
if isempty(checkDIR)
    error('No such directory for animal number %d',chinID);
    
elseif length(checkDIR)~=1
    if length(checkDIR)>1
        checkDIR= checkDIR(contains({checkDIR.name}', '_AN_'));
        DataDir=[MATDataDir checkDIR.name filesep];
    else
        error('What''s going on?');
    end
    
else
    DataDir=[MATDataDir checkDIR.name filesep];
end

ChinDirName_out= checkDIR.name;

allFiles_1= dir([DataDir 'p*.mat']);
NotUsedDIR=strcat(DataDir, 'NotUsedDIR', filesep);
allFiles_2= [];
if isdir(NotUsedDIR)
    allFiles_2= dir([NotUsedDIR 'p*.mat']);
end

badLinesStruct= repmat(struct('badlines', nan), length(allFiles_1)+length(allFiles_2), 1);

for fileVar= 1:length(allFiles_1)
    cur_fName= allFiles_1(fileVar).name;
    picNum= getPicNum(cur_fName);
    if any(contains(cur_fName, valid_fPostFix))
        % start loading and saving
        x= load([DataDir cur_fName]);
        x= x.data;
        badLinesStruct(picNum).badlines= x.Stimuli.bad_lines;
    end
end

if ~isempty(allFiles_2)
    for fileVar= 1:length(allFiles_2)
        cur_fName= allFiles_2(fileVar).name;
        picNum= getPicNum(cur_fName);
        if any(contains(cur_fName, valid_fPostFix))
            % start loading and saving
            x= load([NotUsedDIR cur_fName]);
            x= x.data;
            badLinesStruct(picNum).badlines= x.Stimuli.bad_lines;
        end
    end
end
fName2Save= [BadLine_OutDir ChinDirName_out '.mat'];
save(fName2Save, 'badLinesStruct');

cd(CodesDir);