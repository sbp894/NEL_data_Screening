%%
% Converts mfiles from NEL to MAT files
% function convert_mfiles_to_matfiles(NELDataRepository, MATDataRepository)
%  ------------------------------ or ------------------------------
% function convert_mfiles_to_matfiles(chinsIDs_in_vector)

%%
function convert_mfiles_to_matfiles(varargin)

NELDataRepository='/media/parida/DATAPART1/Matlab/ExpData/NelData/';
MATDataRepository='/media/parida/DATAPART1/Matlab/ExpData/MatData/';
if ~isdir(MATDataRepository)
    mkdir(MATDataRepository);
end


if nargin==0
    allDataDir{1}=uigetdir(NELDataRepository);
else
    chinIDs=varargin{1};
    allDataDir=cell(length(chinIDs),1);
    for chinVar=1:length(chinIDs)
        curChinID=chinIDs(chinVar);
        checkDIR=dir(sprintf('%s*Q%d*',NELDataRepository,curChinID));
        if isempty(checkDIR)
            error('No such directory for animal number %d',ChinID);
        elseif length(checkDIR)~=1
            fprintf('Multiple directories found.\n');
            for dirVar= 1:length(checkDIR)
                fprintf('(%d)-%s\n', dirVar, checkDIR(dirVar).name);
            end
            
            chosen_dir_num= input('Which one? \n');
            allDataDir{chinVar}=[NELDataRepository checkDIR(chosen_dir_num).name];
        else
            allDataDir{chinVar}=[NELDataRepository checkDIR.name];
        end
    end
end


CodesDir=pwd;
addpath(CodesDir);

% NELDataRepository='R:\Users\Satya\SP\NELData\';

for dirVar=1:length(allDataDir)
    DataDir=allDataDir{dirVar};
    
    OutDir=[MATDataRepository DataDir(length(fileparts(DataDir))+2:end) filesep];
    
    mkdir(OutDir);
    
    cd(DataDir);
    allfiles=dir();
    
    for file_var=1:length(allfiles)
        mfilename=allfiles(file_var).name;
        if length(mfilename)>60
            disp('wait');
        end
        
        if strcmp(mfilename(1),'.') % Don't copy system dirs
            %root dirs
        elseif strcmp(mfilename(end-1:end),'.m') % Copy data
            if strcmp(mfilename(1), 'a') % for average files in FFR
                try
                    eval( strcat('data = ',mfilename(1:length(mfilename)-2),';'));
                    matfilename=[OutDir mfilename(1:end-1) 'mat'];
                    save(matfilename,'data');
                catch
                    fprintf('%s is odd\n', mfilename);
                end
            else % else p* files, check if there's an a-file with the same name. Since ffr files are really big, skip these p files that have a-file.
                picNum= str2double(mfilename(2:5));
                if isempty(dir(sprintf('a%04d*', picNum)))
                    eval( strcat('data = ',mfilename(1:length(mfilename)-2),';'));
                    matfilename=[OutDir mfilename(1:end-1) 'mat'];
                    save(matfilename,'data');
                end
            end
        elseif allfiles(file_var).isdir  % Copy directories
            copyfile(mfilename,[OutDir mfilename filesep]);
        else % Copy other files
            copyfile(mfilename,OutDir);
        end
    end
    
    cd(CodesDir);
    fprintf('-----%s is \n \t \t saved in %s\n',DataDir, OutDir);
end