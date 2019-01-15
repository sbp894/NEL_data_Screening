clear;
clc;

allFiles= dir('*.m');

for fileVar=1:length(allFiles)
    fName_old= allFiles(fileVar).name;
    fName_new= strrep(fName_old, 'atten', 'atn');
    fName_new= strrep(fName_new, 'SNRenv_', '');
    fName_new= strrep(fName_new, 'pinkStim_', '');
    fName_new= strrep(fName_new, 'nType0_', '');
    
    if ~strcmp(fName_old, fName_new)
        fprintf('converting %s to \n \t \t %s\n', fName_old, fName_new);
        movefile(fName_old, fName_new);
    else
        fprintf('skipping %s ', fName_old);
    end
end