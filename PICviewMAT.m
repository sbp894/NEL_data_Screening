function FIG=PICviewMAT(FIG, picNum,excludeLines, figNum)
% File: PICview.m
% M.Heinz 04Jan2005.  Modified from PSTview.m 
%
% Plots raster,and rate vs. rep for a generic picture, just to look at it
%
% Usage: PICview(picNum,excludeLines, figNum)
% picNums: picture number
% excludeLines: vector of any lines to be excluded

if ~exist('excludeLines','var')
   excludeLines=[];
end

if(~exist('figNum', 'var'))
   FIG.num = 100;   % default, if not specified.
else
   FIG.num = figNum;
end
FIG.fontSize = 8; % used for axis labelling.

picSearchString = sprintf('p%04d*.mat', picNum);
picMFile = dir(picSearchString);

temp=load(picMFile.name);
PIC.x=temp.data;
PIC.num=picNum;

[FIG, PIC]=layoutFigure(FIG, PIC);  % *Keep here
FIG=do_raster(FIG, PIC, excludeLines);     % *Keep here
FIG=do_rate(FIG, PIC, excludeLines);       % *Plot here, calc from Mfile


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

NameText=sprintf('picture: %04d; filename: %s', PIC.num,getFileName(PIC.num));
set(gcf, 'Name', NameText);

% Yshift=0.05;
rateXcorner=0.05; rateYcorner=0.1; rateWidth=0.10; rateHeight=0.8;
rasterXcorner=0.2; rasterYcorner=rateYcorner; rasterWidth=0.4; rasterHeight=rateHeight;
FIG.handles.rate   = subplot('Position',[rateXcorner rateYcorner rateWidth rateHeight]);
FIG.handles.raster = subplot('Position',[rasterXcorner rasterYcorner rasterWidth rasterHeight]);

%%
FIG.handles.PrevPicPB=uicontrol('Parent',FIG.num,'Style','pushbutton','enable', 'on', ...
    'String','prev picture (<<)','Units','normalized','Position',[0.7 0.1 0.067 0.05],...
    'Visible','on', 'Backgroundcolor', [.7 .7 .7], 'callback', 'screenDataMAT(''PrevPic_PBcallback'')');

FIG.handles.RefreshPicPB=uicontrol('Parent',FIG.num,'Style','pushbutton',...
    'String','(Refresh)','Units','normalized','Position',[0.767 0.1 0.067 0.05],...
    'Visible','on', 'Backgroundcolor', [.7 .7 .7], 'callback', 'screenDataMAT(''RefreshPic_PBcallback'')');

FIG.handles.NextPicPB=uicontrol('Parent',FIG.num,'Style','pushbutton',...
    'String','next picture (>>)','Units','normalized','Position',[0.834 0.1 0.067 0.05],...
    'Visible','on', 'Backgroundcolor', [.7 .7 .7], 'callback', 'screenDataMAT(''NextPic_PBcallback'')');


%% Working on it now
FIG.handles.badLinesRemoveReset=uicontrol('Parent',FIG.num,'Style','pushbutton',...
    'String','Reset','Units','normalized','Position',[0.7 0.3 0.1 0.05],...
    'Visible','on', 'Backgroundcolor', [.7 .7 .7], 'callback', 'screenDataMAT(''badLinesRemoveReset'')');

FIG.handles.badLinesRemoveLabel=uicontrol('Parent',FIG.num,'Style','pushbutton',...
    'String','Label','Units','normalized','Position',[0.8 0.3 0.1 0.05],...
    'Visible','on', 'Backgroundcolor', [.7 .7 .7], 'callback', 'screenDataMAT(''badLinesRemoveLabel'')');

FIG.handles.badLinesRemoveAction=uicontrol('Parent',FIG.num,'Style','pushbutton','enable', 'off', ......
    'String',sprintf('Risky-DO-NAN'),'Units','normalized','Position',[0.7 0.25 0.1 0.05],...
    'Visible','on', 'Backgroundcolor', [.9 .4 .4], 'callback', 'screenDataMAT(''badLinesRemoveAction'')');

FIG.handles.censor_refractory=uicontrol('Parent',FIG.num,'Style','pushbutton','enable', 'off', ...
    'String',sprintf('remove < refractory'),'Units','normalized','Position',[0.8 0.25 0.1 0.05],...
    'Visible','on', 'Backgroundcolor', [.9 .4 .4], 'callback', 'screenDataMAT(''censor_refractory'')');

%%
FIG.handles.BadLineEdit=uicontrol('Parent',FIG.num,'Style','edit',...
    'String','','Units','normalized','Position',[0.7 0.35 0.2 0.05],...
    'Visible','on', 'Backgroundcolor', [.6 .8 .6], 'callback', 'screenDataMAT(''Badlines_Editcallback'')');

FIG.handles.BadLineText=uicontrol('Parent',FIG.num,'Style','text',...
    'String','add comma/space separated badlines  below','Units','normalized','Position',[0.7 0.40 0.2 0.025],...
    'Visible','on', 'Backgroundcolor', [.5 .7 .5]);

FIG.handles.Comments=uicontrol('Parent',FIG.num,'Style','text',...
    'String','','Units','normalized','Position',[0.65 0.50 0.3 .2],...
    'Visible','on', 'Backgroundcolor', .9*ones(3,1));

FIG.handles.CommentsOUTPUT=uicontrol('Parent',FIG.num,'Style','text',...
    'String','OUTPUTs of this picture','Units','normalized','Position',[0.7 0.70 0.2 .025],...
    'Visible','on', 'Backgroundcolor', .8*ones(3,1));

titleString = sprintf('picture %s recorded on %s\n%s', ...
               mat2str(PIC.num),...
               PIC.x.General.date, ...
               PIC.x.Stimuli.description{1});
titleString = strrep(titleString, '_', '\_');
FIG.handles.figBox = axes('Position',[0 0 1 1],'Visible','off');
text(0.5, 1, titleString, 'Units', 'normalized', 'FontSize', FIG.fontSize-1,...
   'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');

return;

%% ################################################################################################

function FIG=do_raster(FIG, PIC, excludeLines)


abs_refractory=.6e-3; % Absolute Refractory Period

%%
subplot(FIG.handles.raster);
SpikeINDs=~ismember(PIC.x.spikes{1}(1:end,1)',excludeLines)';

isi=[inf; diff(PIC.x.spikes{1}(SpikeINDs,2))];
new_line_index=[1;1+find(diff(PIC.x.spikes{1}(:,1))==1)];
isi(new_line_index)=inf;
abs_refractory_violation_index= (isi<=abs_refractory);
abs_refractory_violation_index2plot= (abs_refractory_violation_index & SpikeINDs);


plot(PIC.x.spikes{1}(SpikeINDs,2),PIC.x.spikes{1}(SpikeINDs,1), 'k.', 'MarkerSize', 4);
hold on;
plot(PIC.x.spikes{1}(abs_refractory_violation_index2plot,2),PIC.x.spikes{1}(abs_refractory_violation_index2plot,1), 'rd', 'MarkerSize', 3);

FIG.raster.xmax = (PIC.x.Hardware.Trigger.StmOn + PIC.x.Hardware.Trigger.StmOff) / 1000;
FIG.raster.ymax = ceil(PIC.x.Stimuli.fully_presented_lines/10)*10;
% FIG.raster.ymax = ceil(max(PIC.x.spikes{1}(SpikeINDs,1))/10)*10;
xlim([0 FIG.raster.xmax]);
ylim([0 FIG.raster.ymax]);
set(gca, 'FontSize', FIG.fontSize);
FIG.raster.hx=xlabel('time (sec)');
% set(FIG.raster.hx,'units','norm','pos',[0.4926   -0.01         0])
set(gca,'YTick',0:10:FIG.raster.ymax)
set(gca, 'TickDir', 'out');
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
set(gca,'YTick',0:10:FIG.raster.ymax)
ylabel('Rep Number');
FIG.rate.hx=xlabel('Rate (sp/s)');
% set(FIG.rate.hx,'units','norm','pos',[-0.2   -0.018         0])

return;
