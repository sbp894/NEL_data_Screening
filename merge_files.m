% function merge_files(chinID, picNums)

function merge_files(chinID, picNums)

MATDataRepository='/media/parida/DATAPART1/Matlab/ExpData/MatData/';

if nargin==0
    DataDir=uigetdir(MATDataRepository);
    if ~strcmp(DataDir(end), filesep)
        DataDir=strcat(DataDir, filesep);
    end
    picNums(1)= input('First files to merge?');
    picNums(2)= input('Second files to merge?');
elseif nargin==1
    DataDir=dir(sprintf('%s*%d*', MATDataRepository, chinID));
    picNums(1)= input('First file to merge?');
    picNums(2)= input('Second file to merge?');
else 
    temp=dir(sprintf('%s*%d*AN*', MATDataRepository, chinID));
    DataDir=[MATDataRepository temp.name filesep];
end

CodesDir=pwd;
addpath(CodesDir);

NotUsedDIR=strcat(DataDir, 'NotUsedDIR', filesep);
if ~isdir(NotUsedDIR)
   mkdir(NotUsedDIR); 
end

%%
fName1=dir(sprintf('%sp%04d*', DataDir, picNums(1)));
fName1=fName1.name;
fName2=dir(sprintf('%sp%04d*', DataDir, picNums(2)));
fName2=fName2.name;
[~,name,ext] = fileparts(fName1) ;
fNameOut=[name '_merged' ext];

cd(DataDir);
x1=load([DataDir fName1]);
x1=x1.data;
x2=load([DataDir fName2]);
x2=x2.data;

%% Start merging
data=x1;
data.Stimuli.repetitions=x1.Stimuli.repetitions+x2.Stimuli.repetitions;
data.Stimuli.nlines=x1.Stimuli.nlines+x2.Stimuli.nlines;
data.Stimuli.fully_presented_stimuli=x1.Stimuli.fully_presented_stimuli+x2.Stimuli.fully_presented_stimuli;
data.Stimuli.fully_presented_lines=x1.Stimuli.fully_presented_lines+x2.Stimuli.fully_presented_lines;

fAttenStructNames=fieldnames(x1.Line.attens);
data.Line.attens.list=[[x1.Line.attens.(fAttenStructNames{1})] ; [x2.Line.attens.(fAttenStructNames{1})]];
if isfield(x1.Line, 'file')
    data.Line.file=[x1.Line.file, x2.Line.file];
end
if isfield(x1.Line, 'playback_sampling_rate')
    data.Line.playback_sampling_rate=[x1.Line.playback_sampling_rate, x2.Line.playback_sampling_rate];
end
data.spikes{1,1}=[x1.spikes{1,1}; [x2.spikes{1,1}(:,1)+max(x1.spikes{1,1}(:,1)), x2.spikes{1,1}(:,2)]];

%%
movefile([DataDir fName1], [NotUsedDIR fName1]);
movefile([DataDir fName2], [NotUsedDIR fName2]);
save([DataDir fNameOut],'data');

cd(CodesDir);