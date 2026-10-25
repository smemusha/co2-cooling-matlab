function [t, p, m] = cap_read_scada(files, timeColumn, pressureColumn, flowColumn, dedupe)
% CAP_READ_SCADA  Read and combine SCADA csv exports (time, DP1050 [bar], FT1030 [g/s]).
%   dedupe = 'time' : one sample per timestamp, NaN samples dropped
%            'rows' : only fully identical rows dropped (NaN kept, different
%                     readings at the same timestamp kept)
    n = numel(files);
    assert(n > 0, 'No SCADA csv files found');
    tC = cell(n,1); pC = tC; mC = tC;
    for f = 1:n
        T = readtable(files{f}, 'VariableNamingRule', 'preserve');
        tC{f} = toDatetime(T{:, timeColumn});
        pC{f} = toNumeric(T{:, pressureColumn});
        mC{f} = toNumeric(T{:, flowColumn});
    end
    t = vertcat(tC{:}); p = vertcat(pC{:}); m = vertcat(mC{:});
    switch dedupe
        case 'time'
            [t, idx] = unique(t);
            p = p(idx); m = m(idx);
            ok = ~isnat(t) & isfinite(p) & isfinite(m);
            t = t(ok); p = p(ok); m = m(ok);
        case 'rows'
            [~, idx] = unique(table(t, p, m), 'rows');
            t = t(idx); p = p(idx); m = m(idx);
        otherwise
            error('dedupe must be "time" or "rows"');
    end
    assert(~isempty(t), 'No valid SCADA samples in the csv files');
end

function t = toDatetime(raw)
    if isdatetime(raw), t = raw(:); return; end
    t = datetime(string(raw(:)), 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
end

function v = toNumeric(raw)
    if ~isnumeric(raw), raw = str2double(string(raw)); end
    v = double(raw(:));
end
