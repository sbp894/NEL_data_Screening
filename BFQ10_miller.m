function unit=BFQ10_miller(x1,x2,N)

%set(0,'DefaultTextInterpreter','none');
set(0,'DefaultTextUnits','data')

unit.TC.tcdata(:,1)=x1;
unit.TC.tcdata(:,2)=x2;

unit.titletext='test TC';
unit.calNUM=1;

%% Show related BF values, and choose BF by hand
% verifyBFQ10 will show minTC, book, TChand (if exists, DEFAULT), and unit.BF (if exists, i.e., re-check old data)

% if colnum==1
    h14=figure(); clf;
    % h14=figure; clf;
    set(h14,'Position',[107   340   914   358])
% end

TFiltWidthTC=N;

TextFontSize=8;
DataMarkerSize=12;
DataMarkStyle='b.';
DataFitStyle='b-';

xmin=0.03; xmax=39; ymin=-100; ymax=100;
% load normema

%%%%%% PLOT TUNING CURVE
h_line1 = semilogx(unit.TC.tcdata(:,1),unit.TC.tcdata(:,2),DataMarkStyle,'MarkerSize',DataMarkerSize);
% h_line1 = semilogx(unit.TC.tcdata(:,1),unit.TC.tcdata(:,2));
hold on
unit.TC.tcdata(:,3)=trifilt(unit.TC.tcdata(:,2)',TFiltWidthTC)'; %%% Triangular filter.

% unit.TC.tcdata(:,3)=smooth(unit.TC.tcdata(:,2),9); %%% Moving average filter.

% unit.TC.tcdata(:,3)=smooth(unit.TC.tcdata(:,1),unit.TC.tcdata(:,2),9,'sgolay',2)'; %%% Savitzky-Golay filter.

h_line2 = semilogx(unit.TC.tcdata(:,1),unit.TC.tcdata(:,3),DataFitStyle);   %%% Filter..
% h_line2 = semilogx(unit.TC.tcdata(:,1),unit.TC.tcdata(:,3)); hold on;

[pickThr,i]=min(unit.TC.tcdata(:,3));
pickBF=unit.TC.tcdata(i,1);

% semilogx(normt(1,:),normt(2,:),'k')
ylabel('dB SPL'); xlabel('Frequency (kHz)');
axis([xmin xmax ymin ymax]);
legend('Raw Data','Smooth Data'); legend boxoff;
% % set(gca,'YTick',[0 20 40 60 80 100])
% set(gca,'XTick',[.1 1 10],'XTickLabel',[.1 1 10])
if(isfield(unit,'calNUM'))
   title(sprintf('%s (Cal: P%d)',unit.titletext,unit.calNUM))
else
   title(sprintf('%s (Cal: P%d)',unit.titletext,unit.Calib.calPICT))
end

text_str = sprintf('%s %6.3f %s\n%s %4.2f %s','BF:',pickBF,'kHz.','Thresh:',pickThr,'dB SPL');
h_textBF= text(.05,.4,text_str,'Units','norm');

h_pickBF=text(pickBF,pickThr,'\uparrow','Interpreter','tex','FontSize',16, ...
   'VerticalAlignment','top','HorizontalAlignment','center');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loop to wait for verifying BF 
% if colnum==1
x15=get(h14,'Position');  % These commands insure mouse is over Figure so that cursor keys work
set(0,'PointerLocation',x15(1:2)+[10 x15(4)/2])
% end

set(gcf,'CurrentCharacter','x')
loc = find(unit.TC.tcdata(:,1)==pickBF);  %%% finding the location of the best frequency.. CAK 07/08/06..
if isempty(loc)
   [yy,loc]=min(abs(unit.TC.tcdata(:,1)-pickBF));
   disp('unit.BF NOT chosen from data points')
   pickThr = unit.TC.tcdata(loc,3);
   pickBF = unit.TC.tcdata(loc,1);
   set(h_pickBF,'Position',[pickBF pickThr]);
   text_str = sprintf('%s %6.3f %s\n%s %4.2f %s','BF:',pickBF,'kHz.','Thresh:',pickThr,'dB SPL');
   set(h_textBF,'String',text_str);
end

while 1==1      % Wait for verifying BF to complete
%    pause(.1)
   w = waitforbuttonpress;
   if w ~= 0   %%%%   ('Mouse-Button press')
      keypress=get(gcf,'CurrentCharacter');
      
      switch double(keypress)
      case 13  %%% 'RETURN'
         break;
      case 28  %%% 'LEFT cursor'
         loc=min(length(unit.TC.tcdata(:,1)),loc+1);
      case 29  %%% 'RIGHT cursor'
         loc=max(1,loc-1);
      end
   end

   pickThr = unit.TC.tcdata(loc,3);
   pickBF = unit.TC.tcdata(loc,1);
   set(h_pickBF,'Position',[pickBF pickThr]);
   text_str = sprintf('%s %6.3f %s\n%s %4.2f %s','BF:',pickBF,'kHz.','Thresh:',pickThr,'dB SPL');
   set(h_textBF,'String',text_str);
end  % End wait for verifying BF

% Set unit BF/Threshold to picked BF/Threshold
unit.BF_kHz=pickBF;
unit.Thresh_dBSPL=pickThr;

% %% Generate smoothed TC, but avoiding upward bias at BF (tip)
% % Fits each side separately, and then sets equal to actual data point at BF
% % i.e., smoothes sides (e.g., 10 dB up) without biasing threshold at BF upward
% unit.TC.tcdata(1:loc,3)=trifilt(unit.TC.tcdata(1:loc,2)',TFiltWidthTC)';
% unit.TC.tcdata(loc:end,3)=trifilt(unit.TC.tcdata(loc:end,2)',TFiltWidthTC)';
% unit.TC.tcdata(loc,3)=unit.TC.tcdata(loc,2);
set(h_line2,'YData',unit.TC.tcdata(:,3));

% pass smoothed tcdata for q10 calculation (based on actual data point at BF, and smoothed TC otherwise 
% This avoids the bias in smoothing at the tip, i.e., raising threshold at BF
[unit.Q10,unit.TC.Q10fhi,unit.TC.Q10flo,unit.TC.Q10lev]= ...
   findQ10(unit.TC.tcdata(:,1),unit.TC.tcdata(:,3),unit.BF_kHz);

semilogx([unit.TC.Q10flo unit.TC.Q10fhi],unit.TC.Q10lev*ones(1,2),'k-');
text_str = sprintf('%s %6.3f %s\n%s %4.2f %s\n%s %4.1f','BF:',pickBF,'kHz.','Thresh:',pickThr,'dB SPL','Q10: ',unit.Q10);

set(h_textBF,'String',text_str);

% temp=input('Verify Q10 is OK [Return to accept; anything else to mark as QUESTIONABLE]: ');
% if ~isempty(temp)
%    unit.Q10bad=1;
%    unit.Q10=NaN;
% end
% 
% hold off
