function FIG=PICviewMAT(FIG, picNum, figNum)
% Edited SP
% --------------------------------------------------------
% Original file details
% ----- below
% File: PICview.m
% M.Heinz 04Jan2005.  Modified from PSTview.m
%
% Plots raster,and rate vs. rep for a generic picture, just to look at it
%
% Usage: PICview(picNum,excludeLines, figNum)
% picNums: picture number
% excludeLines: vector of any lines to be excluded


if(~exist('figNum', 'var'))
    FIG.num = 100;   % default, if not specified.
else
    FIG.num = figNum;
end
FIG.fontSize = 8; % used for axis labelling.

picSearchString = sprintf('p%04d*.mat', picNum);
picMFile = dir(picSearchString);
if ~isempty(picMFile)
    temp=load(picMFile.name);
else
    picSearchString = sprintf('%sp%04d*.mat', FIG.NotUsedDIR, picNum);
    picMFile = dir(picSearchString);
    temp=load([FIG.NotUsedDIR picMFile.name]);
end
PIC.x=temp.data;
PIC.num=picNum;

if isfield(PIC.x, 'bad_data')
    if isequal(FIG.badlines(FIG.PICnum).vals, PIC.x.bad_data.BadLines)
        excludeLines= [];
    else
        excludeLines= PIC.x.bad_data.BadLines;
    end
else
    excludeLines= [];
end


[FIG, PIC]=layoutFigure(FIG, PIC);  % *Keep here
FIG=do_raster(FIG, PIC, excludeLines);     % *Keep here
FIG=do_rate(FIG, PIC, excludeLines);       % *Plot here, calc from Mfile
FIG=do_tuning_curve(FIG);

linkaxes([FIG.handles.rate FIG.handles.raster], 'y')

return;

%%################################################################################################
function [FIG, PIC]=layoutFigure(FIG, PIC)

% figure_prop_name = {'PaperPositionMode','units','Position'};
% figure_prop_val =  { 'auto'            ,'inches', [8.7083    2.20    5.8333    4]};
% if FIG.num==100
% 	figure_prop_val =  { 'auto' ,'inches', [0.05    1.0    18    9]};
% else
% 	figure_prop_val =  { 'auto' ,'inches', [0.05    1.0    18    9]};
% end
FIG.handles.main = figure(FIG.num);
clf;
% set(gcf,figure_prop_name,figure_prop_val);

NameText=sprintf('picture: %04d; filename: %s', PIC.num,getFileName_inDir(FIG));
set(gcf, 'Name', NameText);

% Yshift=0.05;
rateXcorner=0.05; rateYcorner=0.1; rateWidth=0.10; rateHeight=0.8;
rasterXcorner=0.2; rasterYcorner=rateYcorner; rasterWidth=0.4; rasterHeight=rateHeight;
tcXcorner=.65; tcYcorner=.62; tcWidth=.3; tcHeight=.3;
FIG.handles.rate   = subplot('Position',[rateXcorner rateYcorner rateWidth rateHeight]);
FIG.handles.raster = subplot('Position',[rasterXcorner rasterYcorner rasterWidth rasterHeight]);
FIG.handles.TC = subplot('Position',[tcXcorner tcYcorner tcWidth tcHeight]);

figStages.yGap1=.04;
figStages.yGap2=.08;

figStages.yHeight1=.02;
figStages.yHeight2=.04;
figStages.yHeight3=.16;

figStages.yStage1=0.08;
figStages.yStage2= figStages.yStage1 + figStages.yGap2;
figStages.yStage3= figStages.yStage2 + figStages.yGap2;
figStages.yStage4= figStages.yStage3 + figStages.yHeight2;
figStages.yStage5= figStages.yStage4 + figStages.yHeight2;
figStages.yStage6= figStages.yStage5 + figStages.yGap1;
figStages.yStage7= figStages.yStage6 + figStages.yHeight3;

%% Y stage 1

FIG.handles.UndoDiscard=uicontrol('Parent',FIG.num,'Style','pushbutton','enable', 'on', ...
    'String',sprintf('UndoDiscard'),'Units','normalized','Position',[.63 figStages.yStage1 0.05 figStages.yHeight2],...
    'Visible','on', 'Backgroundcolor', [.3 .8 .3], 'callback', 'screenDataMAT(''undo_discard'')');

FIG.handles.PrevPicPB=uicontrol('Parent',FIG.num,'Style','pushbutton','enable', 'on', ...
    'String','prev picture (<<)','Units','normalized','Position',[0.7 figStages.yStage1 0.067 figStages.yHeight2],...
    'Visible','on', 'Backgroundcolor', [.7 .7 .7], 'callback', 'screenDataMAT(''PrevPic_PBcallback'')');

FIG.handles.RefreshPicPB=uicontrol('Parent',FIG.num,'Style','pushbutton',...
    'String','(Refresh)','Units','normalized','Position',[0.767 figStages.yStage1 0.067 figStages.yHeight2],...
    'Visible','on', 'Backgroundcolor', [.7 .7 .7], 'callback', 'screenDataMAT(''RefreshPic_PBcallback'')');

FIG.handles.NextPicPB=uicontrol('Parent',FIG.num,'Style','pushbutton',...
    'String','next picture (>>)','Units','normalized','Position',[0.834 figStages.yStage1 0.067 figStages.yHeight2],...
    'Visible','on', 'Backgroundcolor', [.7 .7 .7], 'callback', 'screenDataMAT(''NextPic_PBcallback'')');

FIG.handles.closeGUI=uicontrol('Parent',FIG.num,'Style','pushbutton',...
    'String','Close','Units','normalized','Position',[.92 figStages.yStage1 0.04 figStages.yHeight2],...
    'Visible','on', 'Backgroundcolor', [1 .2 .2], 'callback', 'screenDataMAT(''closeGUI'')');

%% Y stage 2

FIG.handles.discard=uicontrol('Parent',FIG.num,'Style','pushbutton','enable', 'on', ...
    'String',sprintf('Discard'),'Units','normalized','Position',[.63 figStages.yStage2 0.05 figStages.yHeight2],...
    'Visible','on', 'Backgroundcolor', [1 .2 .2], 'callback', 'screenDataMAT(''discard'')', 'fontweight', 'bold');

FIG.handles.badLinesRemoveAction=uicontrol('Parent',FIG.num,'Style','pushbutton','enable', 'on', ......
    'String',sprintf('Risky-DO-NAN'),'Units','normalized','Position',[0.7 figStages.yStage2 0.1 figStages.yHeight2],...
    'Visible','on', 'Backgroundcolor', [.3 0.647 0.841], 'callback', 'screenDataMAT(''badLinesRemoveAction'')');

FIG.handles.censor_refractory=uicontrol('Parent',FIG.num,'Style','pushbutton','enable', 'on', ...
    'String',sprintf('remove < refractory'),'Units','normalized','Position',[0.8 figStages.yStage2 0.1 figStages.yHeight2],...
    'Visible','on', 'Backgroundcolor', [.3 0.647 0.841], 'callback', 'screenDataMAT(''censor_refractory'')');

FIG.handles.closeGUI=uicontrol('Parent',FIG.num,'Style','pushbutton',...
    'String','TCedit','Units','normalized','Position',[.92 figStages.yStage2 0.04 figStages.yHeight2],...
    'Visible','on', 'Backgroundcolor', [1 .4 .4], 'callback', 'screenDataMAT(''TCedit'')');

%% Y stage 3

FIG.handles.GoToPicTxt=uicontrol('Parent',FIG.num,'Style','text',...
    'String','Go To Pic #','Units','normalized','Position',[0.63 figStages.yStage3+figStages.yHeight2 0.05 figStages.yHeight1],...
    'Visible','on', 'Backgroundcolor', [.5 .5 .8]);

FIG.handles.GoToPicEdit=uicontrol('Parent',FIG.num,'Style','edit',...
    'String','','Units','normalized','Position',[0.63 figStages.yStage3 0.05 figStages.yHeight2],...
    'Visible','on', 'Backgroundcolor', [.6 .6 .8], 'callback', 'screenDataMAT(''GoToPicEdit'')');

FIG.handles.badLinesRemoveReset=uicontrol('Parent',FIG.num,'Style','pushbutton',...
    'String','Reset','Units','normalized','Position',[0.7 figStages.yStage3 0.1 figStages.yHeight2],...
    'Visible','on', 'Backgroundcolor', [.7 .7 .7], 'callback', 'screenDataMAT(''badLinesRemoveReset'')');

FIG.handles.badLinesRemoveLabel=uicontrol('Parent',FIG.num,'Style','pushbutton',...
    'String','Label','Units','normalized','Position',[0.8 figStages.yStage3 0.1 figStages.yHeight2],...
    'Visible','on', 'Backgroundcolor', [.7 .7 .7], 'callback', 'screenDataMAT(''badLinesRemoveLabel'')');

%% Y stage 4
FIG.handles.BadLineEdit=uicontrol('Parent',FIG.num,'Style','edit',...
    'String','','Units','normalized','Position',[0.7 figStages.yStage4 0.2 figStages.yHeight2],...
    'Visible','on', 'Backgroundcolor', [.6 .8 .6], 'callback', 'screenDataMAT(''Badlines_Editcallback'')');

%% Y stage 5
FIG.handles.BadLineText=uicontrol('Parent',FIG.num,'Style','text',...
    'String','add comma/space separated badlines  below','Units','normalized','Position',[0.7 figStages.yStage5 0.2 figStages.yHeight1],...
    'Visible','on', 'Backgroundcolor', [.5 .7 .5]);

%% Y stage 6
FIG.handles.Comments=uicontrol('Parent',FIG.num,'Style','text',...
    'String','','Units','normalized','Position',[0.65 figStages.yStage6 0.3 figStages.yHeight3],...
    'Visible','on', 'Backgroundcolor', .9*ones(3,1));

%% Y stage 7
FIG.handles.CommentsOUTPUT=uicontrol('Parent',FIG.num,'Style','text',...
    'String',sprintf('OUTPUTs (Q%d)', FIG.ChinID),'Units','normalized','Position',[0.7 figStages.yStage7 0.2 figStages.yHeight1],...
    'Visible','on', 'Backgroundcolor', .8*ones(3,1));


if isfield(PIC.x.Stimuli, 'description')
    titleString = sprintf('picture %s recorded on %s\n%s', ...
        mat2str(PIC.num),...
        PIC.x.General.date, ...
        strrep(PIC.x.Stimuli.description{1}, '\', '|'));
else
    titleString='nothing to show, L122 in PICviewMAT';
end
titleString = strrep(titleString, '_', '\_');
FIG.handles.figBox = axes('Position',[0 0 1 1],'Visible','off');
text(0.5, 1, titleString, 'Units', 'normalized', 'FontSize', FIG.fontSize+3,...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');

return;

%% ################################################################################################

function FIG=do_raster(FIG, PIC, excludeLines)


abs_refractory=.6e-3; % Absolute Refractory Period

%%
subplot(FIG.handles.raster);
spikes= PIC.x.spikes{1};
spikes(isnan(spikes(:,1)), :)= 0;
SpikeINDs=~ismember(spikes(1:end,1)',excludeLines)';

isi=[inf; diff(spikes(:,2))];
[lineNum, new_line_index]= unique(spikes(:,1));
new_line_index(lineNum==0)= [];
isi(new_line_index)=inf;
abs_refractory_violation_index= (isi<=abs_refractory);

% To-Do: incomplete
% now take care of the case when ISI violation is in line and you don't
% have to remove all spikes. Example. Say a dot= less than refractory
% period and one | is a spike. So ..|..| is valid, but ..|.| is not. 
% For the case ..|.|.|, we should remove only the second | not both the
% second and third spike. Have to do this in a loop. 

% Adjacent violations. 
ajd_violations= find( abs_refractory_violation_index(2:end)  ==  abs_refractory_violation_index(1:end-1)+1, 1);
% while ~isempty(ajd_violations)
%     
%     ajd_violations= find( abs_refractory_violation_index(2:end)  ==  abs_refractory_violation_index(1:end-1)+1, 1);
% end

abs_refractory_violation_index2plot= abs_refractory_violation_index & SpikeINDs;


plot(spikes(SpikeINDs,2),spikes(SpikeINDs,1), 'k.', 'MarkerSize', 4);
hold on;
plot(spikes(abs_refractory_violation_index2plot,2),spikes(abs_refractory_violation_index2plot,1), 'rd', 'MarkerSize', 3);
percent_less_than_refractory=100*sum(abs_refractory_violation_index2plot)/sum(SpikeINDs);

co= get(gca, 'ColorOrder'); % 1 is blue, 2 is red, 5 is green
if ~PIC.x.screening.refract_check_tag
    title(sprintf('Not Censored. %d spikes before refractory (%.2f%%)', sum(abs_refractory_violation_index2plot), percent_less_than_refractory), 'Color', co(2,:));
    FIG.ScreeningSummary(FIG.PICnum).percentRefractoryViolation=percent_less_than_refractory;
else
    title(sprintf('Censored. Before censoring, it was %.2f%%', PIC.x.screening.refract_violate_percent), 'Color', co(1,:));
    FIG.ScreeningSummary(FIG.PICnum).percentRefractoryViolation=PIC.x.screening.refract_violate_percent;
end

FIG.raster.xmax = (PIC.x.Hardware.Trigger.StmOn + PIC.x.Hardware.Trigger.StmOff) / 1000;
FIG.raster.ymax = max([max(spikes(:,1)) PIC.x.Stimuli.fully_presented_stimuli])+.5;
% FIG.raster.ymax = ceil(max(spikes(SpikeINDs,1))/10)*10;
xlim([0 FIG.raster.xmax]);
ylim([0 FIG.raster.ymax]);
set(gca, 'FontSize', FIG.fontSize);
FIG.raster.hx=xlabel('time (sec)');
% set(FIG.raster.hx,'units','norm','pos',[0.4926   -0.01         0])
% set(gca,'YTick',0:10:FIG.raster.ymax)
set(gca, 'TickDir', 'out');

axes(FIG.handles.raster);
zoom(1);
set(findall(FIG.handles.raster,'-property','FontSize'),'FontSize', 16);
return;

%% ################################################################################################
function FIG=do_rate(FIG, PIC, excludeLines)

PIC=calcRatePerLine(PIC);  % Uses driv=[10,410],spont=[600,1000]

% NaN excluded lines
dRateExcludeINDs = intersect(excludeLines,1:length(PIC.RatePerLine.driv));
PIC.RatePerLine.driv(dRateExcludeINDs)=NaN;
sRateExcludeINDs = intersect(excludeLines,1:length(PIC.RatePerLine.spont));
PIC.RatePerLine.spont(sRateExcludeINDs)=NaN;

set(FIG.handles.Comments, 'string', sprintf('MEAN DRIV RATE = %.f sp/sec\n',mean(PIC.RatePerLine.driv)));

subplot(FIG.handles.rate);
plot(PIC.RatePerLine.driv,1:length(PIC.RatePerLine.driv),'r','LineWidth',2)
hold on
plot(PIC.RatePerLine.spont,1:length(PIC.RatePerLine.spont),'g','LineWidth',2)
hold off
ylim([0 FIG.raster.ymax]);
set(gca, 'FontSize', FIG.fontSize);
set(gca,'XDir','reverse')
% set(gca,'YTick',0:10:FIG.raster.ymax)
ylabel('Rep Number');
FIG.rate.hx=xlabel('Rate (sp/s)');
% set(FIG.rate.hx,'units','norm','pos',[-0.2   -0.018         0])
axes(FIG.handles.rate);
zoom(1);
set(findall(FIG.handles.rate,'-property','FontSize'),'FontSize', 16);

return;

function FIG=do_tuning_curve(FIG)

figure(FIG.num);
subplot(FIG.handles.TC);

[~,~,~,~, allTCdata]= plotTCs(FIG.tcPicNum, FIG.calib_PicNum);

%%
unit_data= load(sprintf('Unit_%d_%02d.mat', FIG.TrackNum, FIG.UnitNum));
unit_data= unit_data.data;
hold on;
plot(unit_data.BFmod, unit_data.Thresh_dB, 'ro');
hold off;

FIG.TCdata.all_freq_kHz= allTCdata.freqkHz;
FIG.TCdata.all_thresh_dB= allTCdata.TCdata;
FIG.TCdata.Thresh_dBSPL=unit_data.Thresh_dB;
FIG.TCdata.BF_kHz=unit_data.BFmod;
FIG.TCdata.Q10=unit_data.Q10_mod;

axes(FIG.handles.TC); % this and the next line required to enable zoom
zoom(1); % zoom by a factor of 1, dummy value 1 to enable zoom
xlim([.1 16]);
grid on;