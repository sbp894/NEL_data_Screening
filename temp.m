
audio_fName='/media/parida/DATAPART1/Matlab/SNRenv/SFR_sEPSM/shorter_stim/FLN_Stim_S_P.wav';
calib_fName= '/media/parida/SP/temp/p0010_calib.mat';

plotYes=1 ;
verbose=1;
[filteredSPL, originalSPL]=CalibFilter_outSPL(audio_fName, calib_fName, plotYes, verbose)
