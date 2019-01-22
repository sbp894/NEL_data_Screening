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


function screenDataMAT(varIN)

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
FIG.verbose= false;

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
        if length(checkDIR)>1
            checkDIR= checkDIR(contains({checkDIR.name}', '_AN_'));
            FIG.DataDir=[MATDataDir checkDIR.name filesep];
        else
            error('What''s going on?');
        end
        
    else
        FIG.DataDir=[MATDataDir checkDIR.name filesep];
    end
    FIG.NotUsedDIR=strcat(FIG.DataDir, 'NotUsedDIR', filesep);
    if ~isdir(FIG.NotUsedDIR)
        mkdir(FIG.NotUsedDIR);
    end
    
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
    
    FIG.OutputDir=strcat(FIG.DataDir, 'ScreeningOutput', filesep);
    if ~isdir(FIG.OutputDir)
        mkdir(FIG.OutputDir);
    end
    
    all_AN_picFiles=dir([FIG.DataDir 'p*.mat']);
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
        
        if contains(getFileName_inDir(FIG), 'tc')
            tcfiles= dir('*tc*.mat');
            FIG.tcPicNum=getPicNum(tcfiles(find(cellfun(@(x) getPicNum(x), {tcfiles.name}')<FIG.PICnum, 1, 'last')).name);
            guidata(FIG.num, FIG);
            screenDataMAT('PrevPic_PBcallback');
            FIG=guidata(FIG.num);
        else
            guidata(FIG.num, FIG);
            screenDataMAT('RefreshPic_PBcallback');
            FIG=guidata(FIG.num);
        end
        
    elseif strcmp(subfunName, 'RefreshPic_PBcallback')
        
        FIG=ReviewUnitTriggeringMAT(FIG);
        if ~isempty(FIG.badlines(FIG.PICnum).vals)
            set(FIG.handles.BadLineEdit, 'string', MakeInputPicString(FIG.badlines(FIG.PICnum).vals));
            guidata(FIG.num, FIG);
            screenDataMAT('Badlines_Editcallback');
            FIG=guidata(FIG.num);
        else
            set(FIG.handles.BadLineEdit, 'string', '');
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
        
        if contains(getFileName_inDir(FIG), 'tc')
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
        
    elseif strcmp(subfunName, 'Badlines_Editcallback')
        % This function is for shading badlines. In order to save these
        % lines, you have to use the 'Label' button <tips>
        
        picStr=get(FIG.handles.BadLineEdit, 'string'); % reads new line numbers
        
        % removes shading for old badlines
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
            
            % fills new badlines
            FIG.badlines(FIG.PICnum).han1=fill_badlines(FIG.handles.rate, tempVals, ControlParams.rateColor);
            FIG.badlines(FIG.PICnum).han2=fill_badlines(FIG.handles.raster, tempVals, ControlParams.rasterColor);
            
        else
            FIG.badlines(FIG.PICnum).vals=[];
        end
        
        
    elseif strcmp(subfunName, 'badLinesRemoveLabel')
        % Once edit_badlines has been called, this subroutine can be used.
        FIG.badlines= label_1pic_badline(FIG);
        
        % Refresh the plot ----------------
        guidata(FIG.num, FIG);
        screenDataMAT('RefreshPic_PBcallback');
        FIG=guidata(FIG.num);
        % ---------------------------------
        
        
    elseif strcmp(subfunName, 'badLinesRemoveReset')
        % first clear all shadings.
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
        
        % then update badlines with an empty array.
        FIG.badlines(FIG.PICnum).vals=[];
        
        % and save it
        FIG.badlines= label_1pic_badline(FIG);
        set(FIG.handles.BadLineEdit, 'string', '');
        
        
    elseif strcmp(subfunName, 'badLinesRemoveAction')
        FIG.badlines= label_1pic_badline(FIG);
        FIG.badlines= remove_1pic_badline(FIG);
        
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
        
        if ~data.screening.refract_check_tag % this is initialized to false in ReviewUnitTriggeringMAT
            
            % Need to do this once
            data.screening.refract_check_tag= true;
            data.screening.refract_violate_percent=100*sum(abs_refractory_violation_index)/size(data.spikes{1}, 1);
            data.spikes{1}(abs_refractory_violation_index,:)=nan;
            save(curFile.name, 'data');
            
        else
            fprintf('Violations already removed! \n');
            return;
        end
        
        if exist([FIG.NotUsedDIR FIG.picFILES2GoThrough{FIG.picNUMs2GoThrough == FIG.PICnum}], 'file')
            fprintf('this file is discarded\n');
        end
        
        fprintf('Removed spikes violating absolute refractory period for file named %s\n', curFile.name);
        
        % Refresh the plot ----------------
        guidata(FIG.num, FIG);
        screenDataMAT('RefreshPic_PBcallback');
        FIG=guidata(FIG.num);
        % ---------------------------------
        
        
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
            if contains(getFileName_inDir(FIG), 'tc')
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
        
    elseif strcmp(subfunName, 'discard')
        %         fprintf('working in discard\n%s', pwd);
        
        movefile(getFileName(FIG.PICnum), [FIG.NotUsedDIR getFileName(FIG.PICnum)]);
        fprintf('file moved to %s \n', FIG.NotUsedDIR);
        
        % Refresh the plot ----------------
        guidata(FIG.num, FIG);
        screenDataMAT('RefreshPic_PBcallback');
        FIG=guidata(FIG.num);
        % ---------------------------------
        
    elseif strcmp(subfunName, 'undo_discard')
        %         fprintf('working in undo_discard\n');
        if exist([FIG.NotUsedDIR getFileName_inDir(FIG)], 'file')
            movefile([FIG.NotUsedDIR FIG.picFILES2GoThrough{FIG.picNUMs2GoThrough == FIG.PICnum}], FIG.picFILES2GoThrough{FIG.picNUMs2GoThrough == FIG.PICnum});
        end
        
        % Refresh the plot ----------------
        guidata(FIG.num, FIG);
        screenDataMAT('RefreshPic_PBcallback');
        FIG=guidata(FIG.num);
        % ---------------------------------
        
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
    %     datacursormode(FIG.num);
    guidata(FIG.num, FIG);
    figure(FIG.num);
    zoom on;
end

FIG.ScreeningSummary(FIG.PICnum).filename=getFileName_inDir(FIG);

% if isfield(FIG, 'percent_less_than_refractory')
%     FIG.ScreeningSummary(FIG.PICnum).percentRefractoryViolation=FIG.percent_less_than_refractory;
% end
FIG.ScreeningSummary(FIG.PICnum).discardedTag=FIG.discardedTag;
FIG.ScreeningSummary(FIG.PICnum).badlines =FIG.badlines(FIG.PICnum).vals;
FIG.ScreeningSummary(FIG.PICnum).trigger=FIG.trigger;
FIG.ScreeningSummary(FIG.PICnum).comments=FIG.comment_in_pic;

if ishandle(FIG.num)
    guidata(FIG.num, FIG);
end

% xlsSummaryData=[ {FIG.ScreeningSummary.filename}', cellstr(num2str([FIG.ScreeningSummary.percentRefractoryViolation]')), {FIG.ScreeningSummary.trigger}' ];
% xlswrite([FIG.OutputDir 'ScreeningSummary'], xlsSummaryData(:,:));
xlsSummaryData=FIG.ScreeningSummary; %#ok<NASGU>
save([FIG.OutputDir 'ScreeningSummary' num2str(FIG.ChinID) '.mat'], 'xlsSummaryData');