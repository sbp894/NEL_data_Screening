

%
% Note (Important): Since there are no global variables, guidata is used.
% screenDataMAT has to be used in this order.
% guidata(FIG.num, FIG);
% screenDataMAT('callback_fun_name');
% FIG=guidata(FIG.num);
%
% Comments:


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


if isnumeric(varIN)
    % function that runs when screendataMAT is called the very first time
    ChinID=varIN;
    
    
    addpath(CodesDir);
    
    checkDIR=dir(sprintf('%s*Q%d*',MATDataDir,ChinID));
    if isempty(checkDIR)
        error('No such directory for animal number %d',ChinID);
    elseif length(checkDIR)~=1
        error('Multiple directories. Change!');
    else
        FIG.DataDir=[MATDataDir checkDIR.name];
    end
    
    cd(FIG.DataDir);
    
    %
    FIG.TrackNum=1;
    FIG.UnitNum=1;
    FIG.Stopflag=0;
    FIG.checkRASTER=1;
    FIG.ChinID=ChinID;
    FIG.CheckStop=0;
    
    FIG.picList=findPics('*',[FIG.TrackNum, FIG.UnitNum]);
    if isempty(FIG.picList) % No units in track-1, go to track-2 with checkStop=1
        FIG.TrackNum=FIG.TrackNum+1;
        FIG.UnitNum=1;
        FIG.CheckStop=1;
    else % Do track-1, unit-1
        FIG.PICnum=FIG.picList(1);
        FIG.numPICsdone=1; % to skip tuning curve, else should initialize to 0
        FIG=ReviewUnitTriggeringMAT(FIG);
        if ~isempty(FIG.badlines(FIG.PICnum).vals)
            set(FIG.handles.BadLineEdit, 'string', num2str(FIG.badlines(FIG.PICnum).vals));
            guidata(FIG.num, FIG);
            screenDataMAT('Badlines_Editcallback');
            FIG=guidata(FIG.num);
        end
    end
    datacursormode(FIG.num);
    
    
elseif ischar(varIN)
    subfunName=varIN;
    if strcmp(subfunName, 'PrevPic_PBcallback')
        % Will add later
        cd(FIG.DataDir);
        FIG.picList=findPics('*',[FIG.TrackNum,FIG.UnitNum]);
        
        if FIG.numPICsdone > 2 % Simply case of reducing numPICsdone by 1
            FIG.numPICsdone = FIG.numPICsdone-1;
            FIG.PICnum=FIG.picList(FIG.numPICsdone);
            
            % All set to call RefreshPic_PBcallback
            guidata(FIG.num, FIG);
            screenDataMAT('RefreshPic_PBcallback');
            FIG=guidata(FIG.num);
            
        else % Either a (same track & new unit) OR (new track)
            if FIG.TrackNum==1 && FIG.UnitNum==1
                warning('No previous picture');
                FIG.numPICsdone = 2;
                guidata(FIG.num, FIG);
            else
                FIG.PICnum=FIG.picList(1)-1;
                filename=getFileName(FIG.PICnum);
                TrackUnitNum=getTrackUnit(filename);

                while contains(filename, 'tc')
                    %                     warning('Should throw weird results when only TC is saved for a unit.');
                    unit_files=dir([FIG.DataDir filesep 'Unit*.mat']);
                    unit_files={unit_files.name};
                    track_unit_mat=cell2mat(cellfun(@(x) sscanf(x, 'Unit_%d_%02d.mat'), unit_files, 'UniformOutput', false))';
                    ind_cur= find(ismember(track_unit_mat, TrackUnitNum, 'rows'));
                    FIG.PICnum=FIG.PICnum-1;
                    FIG.TrackNum=track_unit_mat(ind_cur-1, 1);
                    FIG.UnitNum=track_unit_mat(ind_cur-1, 2);
                    FIG.picList=findPics('*',[FIG.TrackNum,FIG.UnitNum]);
                    filename=getFileName(FIG.picList(end));
                    TrackUnitNum=getTrackUnit(filename);
                end
                
                FIG.TrackNum=TrackUnitNum(1);
                FIG.UnitNum=TrackUnitNum(2);
                FIG.picList=findPics('*',[FIG.TrackNum,FIG.UnitNum]);
                FIG.numPICsdone=length(FIG.picList);
                
                % All set to call RefreshPic_PBcallback
                guidata(FIG.num, FIG);
                screenDataMAT('RefreshPic_PBcallback');
                FIG=guidata(FIG.num);
                
                
            end
        end
        
        
    elseif strcmp(subfunName, 'RefreshPic_PBcallback') % (Probably) a useless callback
        cd(FIG.DataDir);
        FIG=ReviewUnitTriggeringMAT(FIG);
        if ~isempty(FIG.badlines(FIG.PICnum).vals)
            set(FIG.handles.BadLineEdit, 'string', num2str(FIG.badlines(FIG.PICnum).vals));
            guidata(FIG.num, FIG);
            screenDataMAT('Badlines_Editcallback');
            FIG=guidata(FIG.num);
        end
        
    elseif strcmp(subfunName, 'NextPic_PBcallback')
        % runs in two cases. (1) when you hit next picture. (2) As of now
        % TC is not plotted and when p00* is a TC, next picture callback is
        % used. Discussed with MH: Need to plot TC too.
        cd(FIG.DataDir);
        if ~FIG.Stopflag % Go on till there is either units or tracks left. Else stop.
            FIG.picList=findPics('*',[FIG.TrackNum,FIG.UnitNum]);
            if isempty(FIG.picList) % No pics in current track & unit
                if FIG.CheckStop % Checkstop is yes means all units of last track are done
                    FIG.Stopflag=1; % ^ and no unit for current. We have hit the end of the directory.
                else % Current track ended
                    FIG.TrackNum=FIG.TrackNum+1;
                    FIG.UnitNum=1;
                    FIG.CheckStop=1;
                    
                    guidata(FIG.num, FIG);
                    screenDataMAT('NextPic_PBcallback');
                    FIG=guidata(FIG.num);
                end
                
                
            else % There are pics for this track & unit. Check whether hit the end or not
                if FIG.numPICsdone<length(FIG.picList) % Pics left for this track & unit
                    FIG.numPICsdone=FIG.numPICsdone+1;
                    FIG.PICnum=FIG.picList(FIG.numPICsdone);
                    FIG=ReviewUnitTriggeringMAT(FIG);
                    if ~isempty(FIG.badlines(FIG.PICnum).vals)
                        set(FIG.handles.BadLineEdit, 'string', num2str(FIG.badlines(FIG.PICnum).vals));
                        guidata(FIG.num, FIG);
                        screenDataMAT('Badlines_Editcallback');
                        FIG=guidata(FIG.num);
                    end
                    
                else % Start of a new unit, because all pics for old unit are done
                    FIG.numPICsdone=1; % No need to include TC (assumed that TC is the first file)
                    FIG.UnitNum=FIG.UnitNum+1;
                    FIG.CheckStop=0;
                    
                    guidata(FIG.num, FIG);
                    screenDataMAT('NextPic_PBcallback');
                    FIG=guidata(FIG.num);
                end
            end
            datacursormode(FIG.num);
        else
            fprintf('all units are screened for this unit\n');
            close(FIG.num);
        end
        
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
        datacursormode(FIG.num);
        
    elseif strcmp(subfunName, 'badLinesRemoveLabel')
        FIG.badlines=label_1pic_badline(FIG.ChinID, FIG.PICnum, FIG.badlines, CodesDir, MATDataDir);
        
        % Refresh the plot ----------------
        FIG.numPICsdone=FIG.numPICsdone-1;
        guidata(FIG.num, FIG);
        screenDataMAT('NextPic_PBcallback');
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
        FIG.badlines=label_1pic_badline(FIG.ChinID, FIG.PICnum, FIG.badlines, CodesDir, MATDataDir);
        set(FIG.handles.BadLineEdit, 'string', '');
    
    
    elseif strcmp(subfunName, 'badLinesRemoveAction')
        FIG.badlines=label_1pic_badline(FIG.ChinID, FIG.PICnum, FIG.badlines, CodesDir, MATDataDir);
        FIG.badlines=remove_1pic_badline(FIG.ChinID, FIG.PICnum, FIG.badlines, CodesDir, MATDataDir);
        
        % Refresh the plot ----------------
        FIG.numPICsdone=FIG.numPICsdone-1;
        guidata(FIG.num, FIG);
        screenDataMAT('NextPic_PBcallback');
        % ---------------------------------
        
    end
end

if ~ishandle(FIG.num)
    if isfield(FIG,'badlines')
        %         badLines=FIG.badlines; %#ok<NASGU>
        %         save('reviewOUTPUT.mat', 'badLines');
    end
else
    guidata(FIG.num, FIG);
    figure(FIG.num);
    datacursormode(FIG.num);
end

cd(CodesDir);
