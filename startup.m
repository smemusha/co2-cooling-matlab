% startup.m - runs automatically when MATLAB starts (if this folder is on the path)
% Adds REFPROP, the CoBra functions and all of My Scripts (incl. subfolders).
root = 'C:\Users\smemusha\cernbox\WINDOWS\Desktop\CoBra_Master';
folders = {'C:\Program Files (x86)\REFPROP', fullfile(root, 'CoBra Scripts'), fullfile(root, 'My Scripts')};
for i = 1:numel(folders)
    if isfolder(folders{i})
        if i == 1, addpath(folders{i}); else, addpath(genpath(folders{i})); end
    end
end
% keep archived copies off the path so they never shadow the current scripts
p = strsplit(path, pathsep);
arch = p(contains(p, [filesep '_Archive']));
if ~isempty(arch), rmpath(arch{:}); end
clear root folders i p arch
