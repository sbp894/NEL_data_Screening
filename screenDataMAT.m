% Assumptions: Assumes that the first pic for a track/unit pair is TC.

%
% Note (Important): Since there are no global variables, guidata is used.
% screenDataMAT has to be used in this order.
% guidata(FIG.num, FIG);
% screenDataMAT('callback_fun_name');
% FIG=guidata(FIG.num);
%
% Comments:
% Need to add TCs
% Need to add discard button
% Need to udpate moving by pic-# basis


function screenDataMAT(varIN)
% function allDone=screenDataMAT(varIN)

% allDone=0;



if nargin==0
    error('Argument should be chinID without Q');
end

if isnumeric(varIN)
    % Function is called the very first time. Clear all figure-data.
    close all;
end

CodesDir='/media/parida/DATAPART1/Matlab/Screening/';
MATDataDir='/media/parida/DATAPART1/Matlab/ExpData/MatData/';


ControlParams.FigureNum=1001;
ControlParams.rateColor=[.7 .7 .7];
ControlParams.rasterColor=[.8 .6 .6];


FIG.num=ControlParams.FigureNum;

figure(FIG.num);
FIG=guidata(FIG.num);
FIG.CodesDir=CodesDir;
FIG.checkRASTER=1;

if ~isfield(FIG, 'num')
    FIG.num=ControlParams.FigureNum;
    figure_prop_name = {'PaperPositionMode','units','Position'};
    if FIG.num==100
        figure_prop_val =  { 'auto' ,'inches', [0.05    1.0    18    9]};
    else
        figure_prop_val =  { 'auto' ,'inches', [0.05    1.0    18    9]};
    end
    set(FIG.num,figure_prop_name,figure_prop_val);
end

if isfield(FIG, 'calib_PicNum')
    calibNewNum=FIG.all_calib_picNums(find(FIG.all_calib_picNums<FIG.PICnum, 1, 'last'));
    if calibNewNum~=FIG.calib_PicNum
        FIG.calib_PicNum=calibNewNum;
        fprintf('Using %s as calib file now\n', getFileName(FIG.calib_PicNum));
    end
end


if isnumeric(varIN)
    warning on;
    % function that runs when screendataMAT is called the very first time
    ChinID=varIN;
    FIG.ChinID=ChinID;
    
    addpath(FIG.CodesDir);
    
    checkDIR=dir(sprintf('%s*Q%d*',MATDataDir,ChinID));
    if isempty(checkDIR)
        error('No such directory for animal number %d',ChinID);
    elseif length(checkDIR)~=1
        error('Multiple directories. Change!');
    else
        FIG.DataDir=[MATDataDir checkDIR.name];
    end
    FIG.NotUsedDIR=strcat(FIG.DataDir, filesep, 'NotUsedDIR', filesep);
    if ~isdir(FIG.NotUsedDIR)
        mkdir(FIG.NotUsedDIR);
    end
    
    
    addpath(FIG.DataDir);
    addpath(FIG.DataDir);
    
    cd (FIG.NotUsedDIR);
    allFiles_notused=[dir('*tc*'); dir('*SR*'); dir('*RLV*'); dir('*SNR*'); dir('*PST*')];
    cd(FIG.DataDir);
    allFiles_used=[dir('*tc*'); dir('*SR*'); dir('*RLV*'); dir('*SNR*'); dir('*PST*')];
    allFiles=[allFiles_used; allFiles_notused];
    
    picNums=cellfun(@(x) getPicNum(x), {allFiles.name});
    [sortedPicNums, sortPicInds]=sort(picNums, 'ascend');
    
    
    FIG.picFILES2GoThrough={allFiles(sortPicInds).name}';
    FIG.picNUMs2GoThrough=sortedPicNums;
    
    FIG.OutputDir=strcat(FIG.DataDir, filesep, 'ScreeningOutput', filesep);
    if ~isdir(FIG.OutputDir)
        mkdir(FIG.OutputDir);
    end
    
    all_AN_picFiles=dir([FIG.DataDir filesep 'p*.mat']);
    maxPicNUM=getPicNum(all_AN_picFiles(end).name);
    %     if ~exist([FIG.OutputDir 'ScreeningSummary.mat'], 'file')
    FIG.ScreeningSummary=repmat(struct('filename', '---' ,'percentRefractoryViolation', nan, 'trigger', '---', 'comments', '---'), maxPicNUM, 1);
    %     else
    %         temp=load([FIG.OutputDir 'ScreeningSummary.mat']);
    %         FIG.ScreeningSummary=temp.xlsSummaryData;
    %     end
    
    %
    
    FIG.progress.picsDone=1;
    FIG.progress.picsTotal=length(FIG.picNUMs2GoThrough);
    
    FIG.PICnum=FIG.picNUMs2GoThrough(FIG.progress.picsDone);
    TrackUnitNum = getTrackUnit(FIG.picFILES2GoThrough(FIG.progress.picsDone));
    FIG.TrackNum=TrackUnitNum(1);
    FIG.UnitNum=TrackUnitNum(2);
    
    calibFile=dir('*calib*');
    FIG.all_calib_picNums=cellfun(@(x) getPicNum(x), {calibFile.name});
    FIG.calib_PicNum=FIG.all_calib_picNums(find(FIG.all_calib_picNums<FIG.PICnum, 1, 'last'));
    
    if FIG.progress.picsDone < FIG.progress.picsTotal
        if contains(getFileName(FIG.PICnum), 'tc')
            FIG.tcPicNum=FIG.PICnum;
            guidata(FIG.num, FIG);
            screenDataMAT('NextPic_PBcallback');
            FIG=guidata(FIG.num);
        else
            error('first file should be a TC. If not why? change logic');
        end
    else
        warning('Hit the end already');
    end
    
    % % %     if length(calibFile)~=1
    % % %         fprintf('Multiple calib files. Using the last one ---%s\n', getFileName(FIG.calib_PicNum));
    % % %     end
    
    
    
    % % % % %     FIG.picList=findPics('*',[FIG.TrackNum, FIG.UnitNum]);
    % % % % %     if isempty(FIG.picList) % No units in track-1, go to track-2 with checkStop=1
    % % % % %         FIG.TrackNum=FIG.TrackNum+1;
    % % % % %         FIG.UnitNum=1;
    % % % % %         FIG.CheckStop=1;
    % % % % %     else % Do track-1, unit-1
    % % % % %         FIG.PICnum=FIG.picList(1);
    % % % % %         if contains(getFileName(FIG.PICnum), 'tc')
    % % % % %             FIG.numPICsdone=1; % to skip tuning curve, else should initialize to 0
    % % % % %             FIG.tcPicNum=FIG.PICnum;
    % % % % %         else
    % % % % %             FIG.numPICsdone=0; %if somehow tc is not the first file
    % % % % %             warning('TC is not the first picture?????? May result in an error. ');
    % % % % %         end
    % % % % %         FIG=ReviewUnitTriggeringMAT(FIG);
    % % % % %         if ~isempty(FIG.badlines(FIG.PICnum).vals)
    % % % % %             set(FIG.handles.BadLineEdit, 'string', num2str(FIG.badlines(FIG.PICnum).vals));
    % % % % %             guidata(FIG.num, FIG);
    % % % % %             screenDataMAT('Badlines_Editcallback');
    % % % % %             FIG=guidata(FIG.num);
    % % % % %         end
    % % % % %     end
    
elseif ischar(varIN)
    subfunName=varIN;
    if strcmp(subfunName, 'PrevPic_PBcallback')
        
        if FIG.progress.picsDone== 1
            fprintf('This is the first unit\n');
            return;
            
        else
            FIG.progress.picsDone=FIG.progress.picsDone-1;
            FIG.PICnum= FIG.picNUMs2GoThrough(FIG.progress.picsDone);
        end
        
        if contains(getFileName(FIG.PICnum), 'tc')
            FIG.tcPicNum=FIG.PICnum;
            guidata(FIG.num, FIG);
            screenDataMAT('PrevPic_PBcallback');
            FIG=guidata(FIG.num);
        else
            guidata(FIG.num, FIG);
            screenDataMAT('RefreshPic_PBcallback');
            FIG=guidata(FIG.num);
        end
        
        %%
        % % % % %         FIG.picList=findPics('*',[FIG.TrackNum,FIG.UnitNum]);
        % % % % %
        % % % % %         if FIG.numPICsdone > 2 % Simply case of reducing numPICsdone by 1
        % % % % %             FIG.numPICsdone = FIG.numPICsdone-1;
        % % % % %             FIG.PICnum=FIG.picList(FIG.numPICsdone);
        % % % % %
        % % % % %             % All set to call RefreshPic_PBcallback
        % % % % %             guidata(FIG.num, FIG);
        % % % % %             screenDataMAT('RefreshPic_PBcallback');
        % % % % %             FIG=guidata(FIG.num);
        % % % % %
        % % % % %         else % Either a (same track & new unit) OR (new track)
        % % % % %             if FIG.TrackNum==1 && FIG.UnitNum==1
        % % % % %                 warning('No previous picture');
        % % % % %                 FIG.numPICsdone = 2;
        % % % % %                 guidata(FIG.num, FIG);
        % % % % %             else
        % % % % %                 FIG.PICnum=FIG.picList(1)-1;
        % % % % %                 filename=getFileName(FIG.PICnum);
        % % % % %                 TrackUnitNum=getTrackUnit(filename);
        % % % % %
        % % % % %                 while contains(filename, 'tc')
        % % % % %                     %                     warning('Should throw weird results when only TC is saved for a unit.');
        % % % % %                     FIG.tcPicNum=FIG.PICnum;
        % % % % %                     unit_files=dir([FIG.DataDir filesep 'Unit*.mat']);
        % % % % %                     unit_files={unit_files.name};
        % % % % %                     track_unit_mat=cell2mat(cellfun(@(x) sscanf(x, 'Unit_%d_%02d.mat'), unit_files, 'UniformOutput', false))';
        % % % % %                     ind_cur= find(ismember(track_unit_mat, TrackUnitNum, 'rows'));
        % % % % %                     FIG.PICnum=FIG.PICnum-1;
        % % % % %                     FIG.TrackNum=track_unit_mat(ind_cur-1, 1);
        % % % % %                     FIG.UnitNum=track_unit_mat(ind_cur-1, 2);
        % % % % %                     FIG.picList=findPics('*',[FIG.TrackNum,FIG.UnitNum]);
        % % % % %                     filename=getFileName(FIG.picList(end));
        % % % % %                     TrackUnitNum=getTrackUnit(filename);
        % % % % %                 end
        % % % % %
        % % % % %                 FIG.TrackNum=TrackUnitNum(1);
        % % % % %                 FIG.UnitNum=TrackUnitNum(2);
        % % % % %                 FIG.picList=findPics('*',[FIG.TrackNum,FIG.UnitNum]);
        % % % % %                 FIG.numPICsdone=length(FIG.picList);
        % % % % %
        % % % % %                 % All set to call RefreshPic_PBcallback
        % % % % %                 guidata(FIG.num, FIG);
        % % % % %                 screenDataMAT('RefreshPic_PBcallback');
        % % % % %                 FIG=guidata(FIG.num);
        % % % % %
        % % % % %             end
        % % % % %         end
        
    elseif strcmp(subfunName, 'RefreshPic_PBcallback') % (Probably) a useless callback
        
        FIG=ReviewUnitTriggeringMAT(FIG);
        if ~isempty(FIG.badlines(FIG.PICnum).vals)
            set(FIG.handles.BadLineEdit, 'string', MakeInputPicString(FIG.badlines(FIG.PICnum).vals));
            guidata(FIG.num, FIG);
            screenDataMAT('Badlines_Editcallback');
            FIG=guidata(FIG.num);
        end
        
    elseif strcmp(subfunName, 'NextPic_PBcallback')
        
        % runs in two cases. (1) when you hit next picture. (2) As of now
        % TC is not plotted and when p00* is a TC, next picture callback is
        % used. Discussed with MH: Need to plot TC too.
        
        if FIG.progress.picsDone== FIG.progress.picsTotal
            fprintf('all units are screened for this unit\n');
            close(FIG.num);
            cd(FIG.CodesDir);
            rmpath(FIG.DataDir);
            return;
            
        else
            FIG.progress.picsDone=FIG.progress.picsDone+1;
            FIG.PICnum= FIG.picNUMs2GoThrough(FIG.progress.picsDone);
        end
        
        if contains(getFileName(FIG.PICnum), 'tc')
            FIG.tcPicNum=FIG.PICnum;
            guidata(FIG.num, FIG);
            screenDataMAT('NextPic_PBcallback');
            if ishandle(ControlParams.FigureNum)
                FIG=guidata(FIG.num);
            else
                return;
            end
        else
            guidata(FIG.num, FIG);
            screenDataMAT('RefreshPic_PBcallback');
            FIG=guidata(FIG.num);
        end
        
        % % % % %         if ~FIG.Stopflag % Go on till there is either units or tracks left. Else stop.
        % % % % %             FIG.picList=findPics('*',[FIG.TrackNum,FIG.UnitNum]);
        % % % % %             if isempty(FIG.picList) % No pics in current track & unit
        % % % % %                 if FIG.CheckStop % Checkstop is yes means all units of last track are done
        % % % % %                     FIG.Stopflag=1; % ^ and no unit for current. We have hit the end of the directory.
        % % % % %                 else % Current track ended
        % % % % %                     FIG.TrackNum=FIG.TrackNum+1;
        % % % % %                     FIG.UnitNum=1;
        % % % % %                     FIG.CheckStop=1;
        % % % % %
        % % % % %                     guidata(FIG.num, FIG);
        % % % % %                     screenDataMAT('NextPic_PBcallback');
        % % % % %                     FIG=guidata(FIG.num);
        % % % % %                 end
        % % % % %
        % % % % %
        % % % % %             else % There are pics for this track & unit. Check whether hit the end or not
        % % % % %                 if FIG.numPICsdone<length(FIG.picList) % Pics left for this track & unit
        % % % % %                     FIG.numPICsdone=FIG.numPICsdone+1;
        % % % % %                     FIG.PICnum=FIG.picList(FIG.numPICsdone);
        % % % % %                     FIG=ReviewUnitTriggeringMAT(FIG);
        % % % % %                     if ~isempty(FIG.badlines(FIG.PICnum).vals)
        % % % % %                         set(FIG.handles.BadLineEdit, 'string', num2str(FIG.badlines(FIG.PICnum).vals));
        % % % % %                         guidata(FIG.num, FIG);
        % % % % %                         screenDataMAT('Badlines_Editcallback');
        % % % % %                         FIG=guidata(FIG.num);
        % % % % %                     end
        % % % % %
        % % % % %                 else % Start of a new unit, because all pics for old unit are done
        % % % % %                     FIG.numPICsdone=1; % No need to include TC (assumed that TC is the first file)
        % % % % %                     FIG.UnitNum=FIG.UnitNum+1;
        % % % % %                     FIG.CheckStop=0;
        % % % % %
        % % % % %                     guidata(FIG.num, FIG);
        % % % % %                     screenDataMAT('NextPic_PBcallback');
        % % % % %                     FIG=guidata(FIG.num);
        % % % % %                 end
        % % % % %             end
        % % % % %
        % % % % %         else
        % % % % %             fprintf('all units are screened for this unit\n');
        % % % % %             close(FIG.num);
        % % % % %             %             allDone=1;
        % % % % %         end
        
    elseif strcmp(subfunName, 'Badlines_Editcallback')
        picStr=get(FIG.handles.BadLineEdit, 'string');
        if sum(isstrprop(picStr,'digit'))
            tempVals=ParseInputString2Num(picStr);
            FIG.badlines(FIG.PICnum).vals=tempVals;
            
            if isfield(FIG.badlines(FIG.PICnum),'han1')
                for lNum=1:length(FIG.badlines(FIG.PICnum).han1)
                    if isgraphics(FIG.badlines(FIG.PICnum).han1(lNum).lineHan)
                        set(FIG.badlines(FIG.PICnum).han1(lNum).lineHan, 'Visible','off');
                    end
                end
                FIG.badlines(FIG.PICnum).han1=[];
            end
            if isfield(FIG.badlines(FIG.PICnum),'han2')
                for lNum=1:length(FIG.badlines(FIG.PICnum).han2)
                    if isgraphics(FIG.badlines(FIG.PICnum).han2(lNum).lineHan)
                        set(FIG.badlines(FIG.PICnum).han2(lNum).lineHan, 'Visible','off');
                    end
                end
                FIG.badlines(FIG.PICnum).han2=[];
            end
            
            FIG.badlines(FIG.PICnum).han1=fill_badlines(FIG.handles.rate, tempVals, ControlParams.rateColor);
            FIG.badlines(FIG.PICnum).han2=fill_badlines(FIG.handles.raster, tempVals, ControlParams.rasterColor);
            
        else
            FIG.badlines(FIG.PICnum).vals=nan;
        end
        
        
    elseif strcmp(subfunName, 'badLinesRemoveLabel')
        FIG.badlines=label_1pic_badline(FIG.ChinID, FIG.PICnum, FIG.badlines, MATDataDir);
        
        % Refresh the plot ----------------
        guidata(FIG.num, FIG);
        screenDataMAT('RefreshPic_PBcallback');
        FIG=guidata(FIG.num);
        % ---------------------------------
        
        
    elseif strcmp(subfunName, 'badLinesRemoveReset')
        if isfield(FIG.badlines(FIG.PICnum),'han1')
            for lNum=1:length(FIG.badlines(FIG.PICnum).han1)
                if isgraphics(FIG.badlines(FIG.PICnum).han1(lNum).lineHan)
                    set(FIG.badlines(FIG.PICnum).han1(lNum).lineHan, 'Visible','off');
                end
            end
            FIG.badlines(FIG.PICnum).han1=[];
        end
        if isfield(FIG.badlines(FIG.PICnum),'han2')
            for lNum=1:length(FIG.badlines(FIG.PICnum).han2)
                if isgraphics(FIG.badlines(FIG.PICnum).han2(lNum).lineHan)
                    set(FIG.badlines(FIG.PICnum).han2(lNum).lineHan, 'Visible','off');
                end
            end
            FIG.badlines(FIG.PICnum).han2=[];
        end
        FIG.badlines=label_1pic_badline(FIG.ChinID, FIG.PICnum, FIG.badlines, MATDataDir);
        set(FIG.handles.BadLineEdit, 'string', '');
        
        
    elseif strcmp(subfunName, 'badLinesRemoveAction')
        FIG.badlines=label_1pic_badline(FIG.ChinID, FIG.PICnum, FIG.badlines, MATDataDir);
        FIG.badlines=remove_1pic_badline(FIG.ChinID, FIG.PICnum, FIG.badlines, MATDataDir);
        
        % Refresh the plot ----------------
        guidata(FIG.num, FIG);
        screenDataMAT('RefreshPic_PBcallback');
        FIG=guidata(FIG.num);
        % ---------------------------------
        
        
    elseif strcmp(subfunName, 'censor_refractory')
        
        picSearchString = sprintf('p%04d*.mat', FIG.PICnum);
        curFile = dir(picSearchString);
        
        temp=load(curFile.name);
        data=temp.data;
        abs_refractory=.6e-3; % Absolute Refractory Period
        
        isi=[inf; diff(data.spikes{1}(:,2))];
        new_line_index=[1;1+find(diff(data.spikes{1}(:,1))==1)];
        isi(new_line_index)=inf;
        abs_refractory_violation_index= (isi<=abs_refractory);
        
        if ~isfield(data, 'percent_less_than_refractory')
            data.percent_less_than_refractory=100*sum(abs_refractory_violation_index)/size(data.spikes{1}, 1);
        end
        
        data.spikes{1}(abs_refractory_violation_index,:)=nan;
        save(curFile.name, 'data');
        if exist([FIG.NotUsedDIR FIG.picFILES2GoThrough{FIG.picNUMs2GoThrough == FIG.PICnum}], 'file')
            fprintf('this file is discarded\n');
        end
        
        fprintf('Removed spikes violating absolute refractory period for file named %s\n', curFile.name);
        
        % Refresh the plot ----------------
        guidata(FIG.num, FIG);
        screenDataMAT('RefreshPic_PBcallback');
        FIG=guidata(FIG.num);
        % ---------------------------------
        %         fprintf('Ready\n');
        
        
    elseif strcmp(subfunName, 'GoToPicEdit')
        
        tempNum2Go=get(FIG.handles.GoToPicEdit, 'string');
        if sum(isstrprop(tempNum2Go,'digit'))
            if isnan(str2double(tempNum2Go))
                error('Enter a single pic value');
            else
                closestINd=dsearchn(FIG.picNUMs2GoThrough', str2double(tempNum2Go));
                FIG.PICnum=FIG.picNUMs2GoThrough(closestINd);
            end
        else
            error('input should be numeric');
        end
        
        
        filename=FIG.picFILES2GoThrough{FIG.picNUMs2GoThrough == FIG.PICnum};
        FIG.progress.picsDone=find(strcmp(FIG.picFILES2GoThrough, filename)==1);
        
        TrackUnitNum = getTrackUnit(FIG.picFILES2GoThrough{FIG.progress.picsDone});
        FIG.TrackNum=TrackUnitNum(1);
        FIG.UnitNum=TrackUnitNum(2);
        
        tcfName=dir(sprintf('p*_u%d_%02d_tc.mat', FIG.TrackNum, FIG.UnitNum));
        tcfName=tcfName.name;
        FIG.tcPicNum=getPicNum(tcfName);
        
        if FIG.progress.picsDone <= FIG.progress.picsTotal
            if contains(getFileName(FIG.PICnum), 'tc')
                guidata(FIG.num, FIG);
                screenDataMAT('NextPic_PBcallback');
                if ishandle(ControlParams.FigureNum)
                    FIG=guidata(FIG.num);
                else
                    return;
                end
            else
                guidata(FIG.num, FIG);
                screenDataMAT('RefreshPic_PBcallback');
                FIG=guidata(FIG.num);
            end
        else
            error('not possible');
        end
        
        
        % % % % %         filename=getFileName(FIG.PICnum);
        % % % % %         while contains(filename, 'tc')
        % % % % %             FIG.PICnum=FIG.PICnum+1;
        % % % % %             FIG.tcPicNum=FIG.PICnum;
        % % % % %             filename=getFileName(FIG.PICnum);
        % % % % %         end
        % % % % %         TrackUnitNum=getTrackUnit(filename);
        % % % % %         FIG.TrackNum=TrackUnitNum(1);
        % % % % %         FIG.UnitNum=TrackUnitNum(2);
        % % % % %         FIG.picList=findPics('*',[FIG.TrackNum,FIG.UnitNum]);
        % % % % %         FIG.numPICsdone=find(FIG.picList==FIG.PICnum);
        % % % % %
        % % % % %         % All set to call RefreshPic_PBcallback
        % % % % %         guidata(FIG.num, FIG);
        % % % % %         screenDataMAT('RefreshPic_PBcallback');
        % % % % %         FIG=guidata(FIG.num);
        
    elseif strcmp(subfunName, 'discard')
        %         fprintf('working in discard\n%s', pwd);
        
        movefile(getFileName(FIG.PICnum), [FIG.NotUsedDIR getFileName(FIG.PICnum)]);
        fprintf('file moved to %s \n', FIG.NotUsedDIR);
        
    elseif strcmp(subfunName, 'undo_discard')
        %         fprintf('working in undo_discard\n');
        if exist([FIG.NotUsedDIR getFileName(FIG.PICnum)], 'file')
            movefile([FIG.NotUsedDIR FIG.picFILES2GoThrough{FIG.picNUMs2GoThrough == FIG.PICnum}], FIG.picFILES2GoThrough{FIG.picNUMs2GoThrough == FIG.PICnum});
        end
        
    elseif strcmp(subfunName, 'closeGUI')
        cd(FIG.CodesDir);
        rmpath(FIG.DataDir);
        close(FIG.num);
        return;
    end
end

if ~ishandle(FIG.num)
    if isfield(FIG,'badlines')
        %         badLines=FIG.badlines; %#ok<NASGU>
        %         save('reviewOUTPUT.mat', 'badLines');
    end
else
    datacursormode(FIG.num);
    guidata(FIG.num, FIG);
    figure(FIG.num);
end


curPicInd=FIG.picNUMs2GoThrough(FIG.progress.picsDone);
FIG.ScreeningSummary(curPicInd).filename=getFileName(curPicInd);

if isfield(FIG, 'percent_less_than_refractory')
    FIG.ScreeningSummary(curPicInd).percentRefractoryViolation=FIG.percent_less_than_refractory;
end
FIG.ScreeningSummary(curPicInd).trigger=FIG.trigger;
FIG.ScreeningSummary(curPicInd).comments=FIG.comment_in_pic;
if ishandle(FIG.num)
    guidata(FIG.num, FIG);
end

% xlsSummaryData=[ {FIG.ScreeningSummary.filename}', cellstr(num2str([FIG.ScreeningSummary.percentRefractoryViolation]')), {FIG.ScreeningSummary.trigger}' ];
% xlswrite([FIG.OutputDir 'ScreeningSummary'], xlsSummaryData(:,:));
xlsSummaryData=FIG.ScreeningSummary; %#ok<NASGU>
save([FIG.OutputDir 'ScreeningSummary' num2str(FIG.ChinID) '.mat'], 'xlsSummaryData');