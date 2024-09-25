%%
% Converts mfiles from NEL to MAT files
% function convert_mfiles_to_matfiles(NELDataRepository, MATDataRepository)
%  ------------------------------ or ------------------------------
% function convert_mfiles_to_matfiles(chinsIDs_in_vector)

%%
function convert_mfiles_to_matfiles_ken()

NELDataRepository='D:\Matlab\KenANFdata_mfiles\';
MATDataRepository='D:\Matlab\KenANFdata_matfiles\';


if ~isfolder(MATDataRepository)
    mkdir(MATDataRepository);
end

skip_pFile_if_aExists= 1;

allDataDir= dir(NELDataRepository);
valid_inds= cellfun(@(x) ~strcmp(x(1), '.'), {allDataDir.name});
allDataDir= allDataDir(valid_inds);
allDataDir= cellfun(@(x) [NELDataRepository x], {allDataDir.name}, 'UniformOutput', false)';
allDataDir= allDataDir(cellfun(@(x) isfolder(x), allDataDir));

% % % if nargin==0
% % %     allDataDir{1}=uigetdir(NELDataRepository);
% % % else
% % %     chinIDs=varargin{1};
% % %     allDataDir=cell(length(chinIDs),1);
% % %     for chinVar=1:length(chinIDs)
% % %         curChinID=chinIDs(chinVar);
% % %         checkDIR=dir(sprintf('%s*Q%d*',NELDataRepository,curChinID));
% % %         if isempty(checkDIR)  
% % %             error('No such directory for animal number %d',ChinID);
% % %         elseif length(checkDIR)~=1
% % %             fprintf('Multiple directories found.\n');
% % %             for dirVar= 1:length(checkDIR)
% % %                 fprintf('(%d)-%s\n', dirVar, checkDIR(dirVar).name);
% % %             end
% % %             
% % %             chosen_dir_num= input('Which one? \n');
% % %             allDataDir{chinVar}=[NELDataRepository checkDIR(chosen_dir_num).name];
% % %         else
% % %             allDataDir{chinVar}=[NELDataRepository checkDIR.name];
% % %         end
% % %     end
% % % end


CodesDir=pwd;
addpath(CodesDir);

% NELDataRepository='R:\Users\Satya\SP\NELData\';

for dirVar=1:length(allDataDir)
    DataDir=allDataDir{dirVar};
    
    OutDir=[MATDataRepository DataDir(length(fileparts(DataDir))+2:end) filesep];
    
    if ~isfolder(OutDir)
        mkdir(OutDir);
    end
    
    cd(DataDir);
    allfiles=dir();
    
    for file_var=1:length(allfiles)
        filename=allfiles(file_var).name;
        if length(filename)>60
            disp('wait');
        end
        
        if strcmp(filename(1),'.') % Don't copy system dirs
            %root dirs
        elseif strcmp(filename(end-1:end),'.m') % Copy data
            matfilename=[OutDir filename(1:end-2) '.mat'];
            if ~exist(matfilename, 'file')
                if strcmp(filename(1), 'a') % for average files in FFR
                    try
                        data= parload(filename);
                        parsave(matfilename, data);
                    catch
                        fprintf('%s is odd\n', filename);
                    end
                else
                    if skip_pFile_if_aExists
                        % else p* files, check if there's an a-file with the same name. Since ffr files are really big, skip these p files that have a-file.
                        picNum= str2double(filename(2:5));
                        if isempty(dir(sprintf('a%04d*', picNum)))
                            data= parload(filename);
                            parsave(matfilename, data);
                        end
                    else
                        data= parload(filename);
                        parsave(matfilename, data);
                        
                    end
                end
            end
        elseif allfiles(file_var).isdir  % Copy directories
            copyfile(filename,[OutDir filename filesep]);
        else % Copy other files
            copyfile(filename, OutDir);
        end
    end
    
    cd(CodesDir);
    fprintf('-----%s is \n \t \t saved in %s\n',DataDir, OutDir);
end
end

function parsave(matfilename, data)
save(matfilename,'data');
end

function data= parload(mfilename) %#ok<STOUT>
eval(strcat('data = ', mfilename(1:length(mfilename)-2),';'));
end