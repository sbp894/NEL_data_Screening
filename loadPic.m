function x = loadPic(picNum)     % Load picture
picSearchString = sprintf('p%04d*.mat', picNum);
picMFile = dir(picSearchString);
if ~isempty(picMFile)
    x=load(picMFile.name);
    x=x.data;
else
    error('Picture file p%04d*.mat not found.', picNum);
    x = [];
    return;
end
