function [testLength, currentLength] = cap_read_lengths(file, capIDs)
% CAP_READ_LENGTHS  Tested and current lengths [mm] per capillary from lengths.xlsx.
%   Columns: Capillary | Test length (mm) | Current length (mm)
%   Rows are matched to capIDs by capillary number, so the row order in the
%   file does not matter. A missing current length is returned as NaN.
    assert(isfile(file), ['Lengths file not found: %s\n' ...
        'Create it with columns: Capillary | Test length (mm) | Current length (mm)'], file);
    T = readtable(file, 'VariableNamingRule', 'preserve', 'TextType', 'string');
    assert(width(T) >= 2, '%s: needs at least the columns Capillary and Test length (mm)', file);
    keyFile = strings(height(T),1);
    for i = 1:height(T)
        k = cap_ids(string(T{i,1}));
        if isscalar(k), keyFile(i) = k; end
    end
    testCol = toNum(T, 2);
    if width(T) >= 3, curCol = toNum(T, 3); else, curCol = NaN(height(T),1); end

    n = numel(capIDs);
    testLength = NaN(n,1); currentLength = NaN(n,1);
    missing = strings(0,1);
    for c = 1:n
        i = find(keyFile == cap_ids(capIDs(c)), 1);
        if isempty(i) || ~isfinite(testCol(i)), missing(end+1) = capIDs(c); continue; end %#ok<AGROW>
        testLength(c) = testCol(i); currentLength(c) = curCol(i);
    end
    assert(isempty(missing), '%s: no test length for %s', file, strjoin(missing, ', '));
end

function v = toNum(T, j)
    v = T{:, j};
    if ~isnumeric(v), v = str2double(string(v)); end
    v = double(v(:));
end
