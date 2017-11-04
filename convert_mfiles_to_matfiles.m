%%
% Converts mfiles from NEL to MAT files


%%
function convert_mfiles_to_matfiles(NELDataRepository, MATDataRepository)

if nargin==0
    NELDataRepository='/media/parida/DATAPART1/Matlab/ExpData/NelData/';
    MATDataRepository='/media/parida/DATAPART1/Matlab/ExpData/MatData/';
elseif nargin==1
    if ~strcmp(NELDataRepository(end), filesep)
        NELDataRepository=strcat(NELDataRepository, filesep);
    end
    MATDataRepository=[NELDataRepository 'MATData' filesep];
end


CodesDir=pwd;
addpath(CodesDir);

% NELDataRepository='R:\Users\Satya\SP\NELData\';

if ~isdir(MATDataRepository)
    mkdir(MATDataRepository);
end

DataDir=uigetdir(NELDataRepository);
OutDir=[MATDataRepository DataDir(length(fileparts(DataDir))+2:end) filesep];

mkdir(OutDir);

cd(DataDir);
allfiles=dir();

for file_var=1:length(allfiles) 
    mfilename=allfiles(file_var).name;
    
    if strcmp(mfilename(1),'.') % Don't copy system dirs
        %root dirs
    elseif strcmp(mfilename(end-1:end),'.m') % Copy data
        eval( strcat('data = ',mfilename(1:length(mfilename)-2),';'));
        matfilename=[OutDir mfilename(1:end-1) 'mat'];
        save(matfilename,'data');
    elseif allfiles(file_var).isdir  % Copy directories
        copyfile(mfilename,[OutDir mfilename filesep]);
    else % Copy other files
        copyfile(mfilename,OutDir);
    end
end

cd(CodesDir);