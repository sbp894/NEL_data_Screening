% function plot_screening_summary(allChinID)
allChinID=[87, 210, 212, 9998, 9999];

MATDataDir='/media/parida/DATAPART1/Matlab/ExpData/MatData/';

nHist=120;
histBinEdges=linspace(0, 30, nHist);

ax_left=nan(length(allChinID),1);
ax_right=nan(length(allChinID),1);
for chinVar=1:length(allChinID)
    
    %% Identify data directory
    ChinID=allChinID(chinVar);
    
    checkDIR=dir(sprintf('%s*Q%d*',MATDataDir,ChinID));
    if isempty(checkDIR)
        error('No such directory for animal number %d',ChinID);
    elseif length(checkDIR)~=1
        error('Multiple directories. Change!');
    else
        DataDir=[MATDataDir checkDIR.name];
    end
    
    %%
    temp=load([DataDir filesep 'ScreeningOutput/ScreeningSummary' num2str(ChinID) '.mat']);
    cur_summary_data=temp.xlsSummaryData;
    
    YesNumberRefractory=~isnan([cur_summary_data.percentRefractoryViolation]);
    
    RoyalData= YesNumberRefractory & ...
        (strcmp({cur_summary_data.trigger}, 'GOOD ') | strcmp({cur_summary_data.trigger}, 'EXCELLENT ') | strcmp({cur_summary_data.trigger}, '---') | cellfun(@(x) isempty(x), {cur_summary_data.trigger}));
    IgnobleData=YesNumberRefractory & (strcmp({cur_summary_data.trigger}, 'POOR ') | strcmp({cur_summary_data.trigger}, 'FAIR '));
    
    
    %% Count distribution
    ax_left(chinVar)=subplot(length(allChinID), 2, chinVar*2-1);
    [countsGood,bins] = histcounts([cur_summary_data(RoyalData).percentRefractoryViolation], histBinEdges);
    [countsBad,~] = histcounts([cur_summary_data(IgnobleData).percentRefractoryViolation], histBinEdges);
    
    binCenters=(.5*(bins(1:end-1)+bins(2:end)));
    %% Plot 
    %     loglog(binCenters, countsGood, 'd-', binCenters, countsBad, 'o-', 'linewidth', 2);
    
    % or bar plot
    bar(binCenters, countsGood, 'b', 'facealpha', .5);
    hold on;
    bar(binCenters, countsBad, 'r', 'facealpha', .5);
    
    title(['Q' num2str(ChinID) '-Count Distribution']);
%     set(gca, 'xtick', get(gca, 'XTICK')', 'xticklabel', cellfun(@(x) num2str(sprintf('%.3f', x)),num2cell(get(gca, 'XTICK')'), 'UniformOutput' , false))
%     set(gca, 'ytick', [.1 1 10 100]);
%     set(gca, 'ytick', get(gca, 'yTICK')', 'yticklabel', cellfun(@(x) num2str(sprintf('%.3f', x)),num2cell(get(gca, 'ytick')'), 'UniformOutput' , false))
    
    %% Probability distribution
    ax_right(chinVar)=subplot(length(allChinID), 2, 2*chinVar);
    [countsGood,bins] = histcounts([cur_summary_data(RoyalData).percentRefractoryViolation], histBinEdges, 'Normalization', 'pdf');
    [countsBad,~] = histcounts([cur_summary_data(IgnobleData).percentRefractoryViolation], histBinEdges, 'Normalization', 'pdf');
    binCenters=(.5*(bins(1:end-1)+bins(2:end)));
    %     binCenters=log10(1e-5+.5*(bins(1:end-1)+bins(2:end)));
    
    %% Plot 
    %     loglog(binCenters, countsGood, 'd-', binCenters, countsBad, 'o-', 'linewidth', 2);
    
    % or bar plot
    bar(binCenters, countsGood, 'b', 'facealpha', .5);
    hold on;
    bar(binCenters, countsBad, 'r', 'facealpha', .5);
    
    title(['Q' num2str(ChinID) '-PDF']);
%     set(gca, 'xtick', get(gca, 'XTICK')' , 'xticklabel', cellfun(@(x) num2str(sprintf('%.3f', x)),num2cell(get(gca, 'XTICK')'), 'UniformOutput' , false))
%     set(gca, 'ytick', [.1 1 10]);
%     set(gca, 'ytick', get(gca, 'yTICK')', 'yticklabel', cellfun(@(x) num2str(sprintf('%.3f', x)),num2cell(get(gca, 'ytick')'), 'UniformOutput' , false))
end

legend('Good', 'Bad');
xlabel('Percentage spikes violating refractory');

linkaxes([ax_left;ax_right] , 'x');
linkaxes(ax_left , 'xy');
linkaxes(ax_right, 'xy');

