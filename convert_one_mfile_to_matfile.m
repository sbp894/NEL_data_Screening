%%
% Converts a single mfile from NEL to MAT file
% Useful if you want to reset all operations done using screenDataMAT
% function convert_one_mfile_to_matfile(NELDataRepository, MATDataRepository)
%  ------------------------------ or ------------------------------
% function convert_mfiles_to_matfiles(chinsIDs_in_vector)

%%
function convert_one_mfile_to_matfile(varargin)

NELDataRepository='/media/parida/DATAPART1/Matlab/ExpData/NelData/';
MATDataRepository='/media/parida/DATAPART1/Matlab/ExpData/MatData/';
if ~isdir(MATDataRepository)
    mkdir(MATDataRepository);
end


if nargin==0
    DataDir=[uigetdir(NELDataRepository) filesep];
    tempFile= uigetfile(DataDir);
    allFiles.name= tempFile;
elseif isnumeric(varargin{1})
    chinID=varargin{1};
    checkDIR=dir(sprintf('%s*Q%d*',NELDataRepository,chinID));
    if isempty(checkDIR)
        error('No such directory for animal number %d',ChinID);
    elseif length(checkDIR)~=1
        fprintf('Multiple directories found.\n');
        for dirVar= 1:length(checkDIR)
            fprintf('(%d)-%s\n', dirVar, checkDIR(dirVar).name);
        end
        
        chosen_dir_num= input('Which one? \n');
        DataDir=[NELDataRepository checkDIR(chosen_dir_num).name filesep];
    else
        DataDir=[NELDataRepository checkDIR.name filesep];
    end
    
    if nargin==2
        picNums= varargin{2};
        allFiles= repmat( struct('name', ''), length(picNums), 1);
        for picVar= 1:length(picNums)
            tempFile= dir(sprintf('%sp%04d*', DataDir, picNums(picVar)));
            allFiles(picVar).name= tempFile.name;
        end
    elseif nargin==1
        tempFile= uigetfile(DataDir);
        allFiles.name= tempFile;
    end
else
    error('Either pass no argument or chinID as input parameter');
end

CodesDir=pwd;
addpath(CodesDir);

% NELDataRepository='R:\Users\Satya\SP\NELData\';

OutDir=[MATDataRepository DataDir(length(fileparts(DataDir(1:end-2)))+2:end)];

if ~isdir(OutDir)
    mkdir(OutDir);
end

cd(DataDir);

for file_var=1:length(allFiles)
    mfilename=allFiles(file_var).name;
    
    if length(mfilename)>60 % added this line because had some SFR files with really long names that gave trouble while loading. not sure if needed anymore
        disp('wait');
    end
    
    if strcmp(mfilename(end-1:end),'.m') % Copy data
        if strcmp(mfilename(1), 'a') % for average files in FFR
            try
                eval( strcat('data = ',mfilename(1:length(mfilename)-2),';'));
                matfilename=[OutDir mfilename(1:end-1) 'mat'];
                save(matfilename,'data');
            catch
                fprintf('%s is odd\n', mfilename);
            end
        else % else p* files, check if there's an a-file with the same name. Since ffr files are really big, skip these p files that have a-file.
            
            eval( strcat('data = ',mfilename(1:length(mfilename)-2),';'));
            matfilename=[OutDir mfilename(1:end-1) 'mat'];
            save(matfilename,'data');
        end
    end
    fprintf('-----%s is \n \t \t saved in %s\n',[DataDir mfilename], matfilename);
end

cd(CodesDir);
