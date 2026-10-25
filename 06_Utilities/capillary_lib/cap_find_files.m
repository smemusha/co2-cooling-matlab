function [scadaFiles, tsFiles] = cap_find_files(folder, timeColumn)
% CAP_FIND_FILES  SCADA csv files and "Timestamps" xlsx files in a campaign folder.
%   A csv counts as SCADA data only if its header contains timeColumn, so
%   result csv files saved in the same folder are ignored.
    assert(isfolder(folder), 'Campaign folder not found: %s', folder);
    d = dir(fullfile(folder, '*.csv'));
    scadaFiles = {};
    for i = 1:numel(d)
        f = fullfile(d(i).folder, d(i).name);
        fid = fopen(f, 'r');
        if fid < 0, continue; end
        hdr = fgetl(fid); fclose(fid);
        if ischar(hdr) && contains(hdr, timeColumn), scadaFiles{end+1,1} = f; end %#ok<AGROW>
    end
    d = dir(fullfile(folder, '*Timestamps*.xlsx'));
    d = d(~startsWith({d.name}, '~$'));            % skip Excel lock files
    tsFiles = fullfile({d.folder}', {d.name}');
    assert(~isempty(scadaFiles), 'No SCADA csv files in %s', folder);
end
