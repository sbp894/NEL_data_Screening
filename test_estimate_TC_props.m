clear;
figHan= 11;
clc;

warning('to update: use the right calib file, not the last one blindly');

parentDataDir= '/media/parida/DATAPART1/Matlab/ExpData/MatData/';
allDataDirs= dir([parentDataDir '*AN*']);
parentOutDir= '/media/parida/DATAPART1/Matlab/GeneralOutput/TCfitting/';
fSize= 14;

for chinVar= 1:length(allDataDirs)
    
    DataDir= [parentDataDir allDataDirs(chinVar).name filesep];
    OutDir= [parentOutDir allDataDirs(chinVar).name filesep];
    
    if ~isdir(OutDir)
        mkdir(OutDir);
    end
    
    all_calib_files= dir([DataDir '*calib*']);
    all_tc_files= dir([DataDir '*tc*']);
    
    calib_data= load([DataDir all_calib_files(end).name]);
    calib_data= calib_data.data.CalibData;
    
    
    parfor tcVar= 1:length(all_tc_files)
        figure(figHan); clf;
        cur_tc_file= [DataDir all_tc_files(tcVar).name];
        temp_data= load(cur_tc_file);
        temp_data= temp_data.data.TcData;
        temp_data(temp_data(:,1)==0, :)=[];
        freq= temp_data(:,1);
        tc_data_atten= temp_data(:,2);
        
        tc_data= arrayfun(@(x) CalibInterp(x,calib_data), freq) -tc_data_atten;
        estimate_TC_props(tc_data, freq);
        
        xlabel('Frequency (kHz)');
        ylabel('Thresh (dB SPL)');
        grid on;
        set(gca, 'fontsize', fSize);
        [a,tc_fName,c]= fileparts(cur_tc_file);
        out_fName= [OutDir tc_fName];
        title(strrep(tc_fName, '_', '/'));
        set(gcf, 'units', 'inches', 'position', [1 1 6 4]);
        ylim([-20 150])
        dummy_parsave(figHan, out_fName);
    end
end


function dummy_parsave(fHan, out_fName)
saveas(fHan, out_fName, 'png');
end