% will complete later
%
clear;
% function create_tc_property_dist(allChinIDs)
CodesDir='/media/parida/DATAPART1/Matlab/Screening/';
FigOutDir= '/media/parida/DATAPART1/Matlab/GeneralOutput/';
saveLatex= 1;
LatexDir= '/home/parida/Dropbox/Conferences/ARO-2019/latex/Figures/eps/';
figHan= 4274;

allChinIDs= [321 322 325 338 341 343 346 347 355 358 360 361 362];
nhInds= [321 322 325 338 341 343 346 347 355];
hiInds= [358 360 361 362];
MATDataDir='/media/parida/DATAPART1/Matlab/ExpData/MatData/';

tc_prop_data= cell(length(allChinIDs), 1);
nhData= [];
hiData= [];

for chinVar= 1:length(allChinIDs)
    ChinNum= allChinIDs(chinVar);
    
    checkDIR=dir(sprintf('%s*Q%d*AN*',MATDataDir,ChinNum));
    if isempty(checkDIR)
        error('No such directory for animal number %d',ChinNum);
    elseif length(checkDIR)~=1
        
        fprintf('Multiple directories found.\n');
        for dirVar= 1:length(checkDIR)
            fprintf('(%d)-%s\n', dirVar, checkDIR(dirVar).name);
        end
        
        chosen_dir_num= input('Which one? \n');
        DataDir=[MATDataDir checkDIR(chosen_dir_num).name];
        
        %     error('Multiple directories. Change!');
        
    else
        DataDir=[MATDataDir checkDIR.name];
    end
    cd(DataDir);
    allUnitFiles= dir('Unit*.mat');
    curChinTCdata= repmat(struct('BF_kHz', nan, 'Q10', nan, 'Thresh_dB', nan), length(allUnitFiles), 1);
    for fileVar= 1:length(allUnitFiles)
        temp= load(allUnitFiles(fileVar).name);
        temp= temp.data;
        curChinTCdata(fileVar).BF_kHz= temp.BFmod;
        curChinTCdata(fileVar).Q10= temp.Q10_mod;
        curChinTCdata(fileVar).Thresh_dB= temp.Thresh_dB;
    end
    if ismember(ChinNum, nhInds)
        nhData = [nhData; curChinTCdata]; %#ok<*AGROW>
    elseif ismember(ChinNum, hiInds)
        hiData = [hiData; curChinTCdata];
    end
end

cd(CodesDir);

%% Plot
mrkSize= 10;
lw2= 2.5;
fSize= 18;
xtickVals= [.2 .5 1 2 4 7 10];

figure(figHan);
clf;
ax(1)= subplot(211);
hold on;
lHan(1)= plot([nhData.BF_kHz], [nhData.Thresh_dB], 'd', 'markersize', mrkSize, 'linew', lw2);
lHan(2)= plot([hiData.BF_kHz], [hiData.Thresh_dB], 'd', 'markersize', mrkSize, 'linew', lw2);
set(gca, 'xscale', 'log', 'fontsize', fSize, 'xtick', xtickVals, 'xticklabel', '');
ylabel('$\Theta(dB\ SPL)$', 'interpreter', 'latex');
grid on;
axis tight;

Q10_ytickVals= [.5 1 5 10];
ax(2)= subplot(212);
hold on;
lHan(1)= plot([nhData.BF_kHz], [nhData.Q10], 'd', 'markersize', mrkSize, 'linew', lw2);
lHan(2)= plot([hiData.BF_kHz], [hiData.Q10], 'd', 'markersize', mrkSize, 'linew', lw2);
set(gca, 'xscale', 'log', 'yscale', 'log', 'fontsize', fSize, 'xtick', xtickVals, 'ytick', Q10_ytickVals);
ylabel('$Q_{10}$', 'interpreter', 'latex');
grid on;
legend('Normal', 'Impaired', 'location', 'northwest');
axis tight;
ylim([.5 20]);
xlabel('CF (kHz)');

linkaxes(ax, 'x');
xlim([.2 11]);

set(gcf, 'units', 'normalized', 'position', [.1 .1 .6 .6]);

fName= 'units_thresh_q10_nh_vs_hi';
saveas(figHan, [FigOutDir fName], 'tiff');

if saveLatex
   saveas(figHan, [LatexDir fName], 'epsc');
end