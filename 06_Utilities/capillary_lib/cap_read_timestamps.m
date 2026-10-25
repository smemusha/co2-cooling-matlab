function [ranges, found, capIDs] = cap_read_timestamps(tsFiles, capIDs, scadaTime)
% CAP_READ_TIMESTAMPS  Stable windows from the colleagues' "Timestamps" xlsx files.
%   Finds every "from / to" header in the sheet and reads the rows below it.
%   Capillary ID: Designation column -> block title -> file name.
%   Date: Date column; if there is no SCADA data on that date, the file-name date is tried.
%   capIDs empty -> every capillary found is returned, sorted by number.
%   ranges{c}: n x 2 string array 'yyyy/MM/dd HH:mm:ss'; found: table of windows.
    % no IDs given -> every capillary in the files is used, sorted by number
    capIDs = string(capIDs(:));
    autoIds = isempty(capIDs);
    keys = strings(numel(capIDs),1);
    for c = 1:numel(capIDs)
        id = cap_ids(capIDs(c));
        assert(isscalar(id), 'Cannot read capillary ID: %s', capIDs(c));
        keys(c) = id;
    end

    K = strings(0,1); FL = strings(0,1); T0 = NaT(0,1); T1 = NaT(0,1);
    SRC = strings(0,1); NOTE = strings(0,1);

    for f = 1:numel(tsFiles)
        [~, fname] = fileparts(tsFiles{f});
        fname = string(fname);
        C = readcell(tsFiles{f});
        txt = cellText(C);
        fileIds = cap_ids(fname);
        tok = regexp(fname, '^(\d{4})\.(\d{2})\.(\d{2})', 'tokens', 'once');
        if isempty(tok), fileDate = NaT; else, fileDate = datetime(str2double(tok)); end

        [hr, hc] = find(lower(txt) == "from");
        for b = 1:numel(hr)
            r = hr(b); cFrom = hc(b);
            hdr = lower(txt(r,:));
            cTo = find(hdr == "to", 1);          if isempty(cTo), cTo = cFrom + 1; end
            cDes = find(hdr == "designation", 1); if isempty(cDes), cDes = cTo + 1; end
            cDate = cFrom - 1;

            blockTitle = "";
            for rr = r-1:-1:max(1, r-4)
                t = txt(rr,:); t = t(contains(t, ["g/s", "|"]));
                if ~isempty(t), blockTitle = t(1); break; end
            end
            titleIds = cap_ids(blockTitle);
            if isscalar(fileIds) && isscalar(titleIds) && fileIds ~= titleIds
                warning('%s: file name says %s, sheet title says %s', fname, fileIds, titleIds);
            end

            for k = r+1:size(C,1)
                t0 = toTimeOfDay(C{k,cFrom});
                t1 = toTimeOfDay(C{k,min(cTo,size(C,2))});
                if isnan(t0) || isnan(t1), break; end      % end of block

                des = "";
                if cDes <= size(C,2), des = txt(k,cDes); end
                ids = cap_ids(des);
                if ~isscalar(ids), ids = titleIds; end
                if ~isscalar(ids), ids = fileIds; end
                if ~isscalar(ids)
                    warning('%s row %d: capillary ID not found, row skipped', fname, k);
                    continue
                end
                if ~autoIds && ~any(keys == ids), continue; end   % not a selected capillary

                flow = regexp(char(des), '\d+(\.\d+)?\s*g/s', 'match', 'once');
                if isempty(flow) || flow == ""
                    flow = regexp(char(blockTitle), '\d+(\.\d+)?\s*g/s', 'match', 'once');
                end
                if isempty(flow), flow = ""; end
                flow = string(flow);

                d = NaT;
                if cDate >= 1, d = toDate(C{k,cDate}); end
                note = "";
                if isnat(d), d = fileDate; note = "date from file name"; end
                st = d + t0; en = d + t1;
                if en <= st, en = en + days(1); end

                if ~any(scadaTime >= st & scadaTime <= en)
                    if ~isnat(fileDate) && fileDate ~= d && ...
                            any(scadaTime >= fileDate + t0 & scadaTime <= fileDate + t1)
                        note = "row date " + char(d, 'dd.MM.yyyy') + " wrong, used file name date";
                        st = fileDate + t0; en = fileDate + t1;
                    else
                        note = "no SCADA data in this window";
                    end
                end

                K(end+1,1) = ids; FL(end+1,1) = flow; T0(end+1,1) = st; T1(end+1,1) = en;
                SRC(end+1,1) = fname; NOTE(end+1,1) = note;
            end
        end
    end

    if autoIds
        assert(~isempty(K), 'No capillary IDs found in the timestamp files');
        keys = unique(K);                           % sorted by capillary number
        capIDs = "P.O.B-" + keys;
    end
    ranges = cell(numel(capIDs),1);
    capCol = strings(size(K));
    for c = 1:numel(capIDs)
        m = find(K == keys(c));
        if isempty(m), error('No timestamps found for %s', capIDs(c)); end
        [~, u] = unique(T0(m)); m = m(u);            % sorted, duplicates removed
        s = T0(m); e = T1(m);
        s.Format = 'yyyy/MM/dd HH:mm:ss'; e.Format = 'yyyy/MM/dd HH:mm:ss';
        ranges{c} = [string(s), string(e)];
        capCol(K == keys(c)) = capIDs(c);
    end

    T0.Format = 'dd.MM.yyyy HH:mm'; T1.Format = 'HH:mm';
    found = table(capCol, FL, T0, T1, SRC, NOTE, 'VariableNames', ...
        {'Capillary','Flow','From','To','File','Note'});
    found = sortrows(found, {'Capillary','From'});
end

function txt = cellText(C)
    txt = strings(size(C));
    for i = 1:numel(C)
        v = C{i};
        if ischar(v) || isstring(v), txt(i) = strtrim(string(v)); end
    end
end

function t = toTimeOfDay(v)
    t = duration(NaN, 0, 0);
    if isdatetime(v)
        t = timeofday(v);
    elseif isduration(v)
        t = v;
    elseif isnumeric(v) && isscalar(v) && isfinite(v)
        t = days(mod(v, 1));                       % Excel time fraction
    elseif ischar(v) || isstring(v)
        tok = regexp(strtrim(string(v)), '^(\d{1,2})[:.h](\d{2})(?::(\d{2}))?$', 'tokens', 'once');
        if ~isempty(tok)
            sec = str2double(tok(3)); if isnan(sec), sec = 0; end
            t = duration(str2double(tok(1)), str2double(tok(2)), sec);
        end
    end
    t = seconds(round(seconds(t)));                % Excel stores 16:48 as 16:47:59.999
end

function d = toDate(v)
    d = NaT;
    if isdatetime(v)
        d = dateshift(v, 'start', 'day');
    elseif isnumeric(v) && isscalar(v) && v > 1
        d = dateshift(datetime(v, 'ConvertFrom', 'excel'), 'start', 'day');
    elseif ischar(v) || isstring(v)
        fmts = {'dd.MM.yyyy', 'dd/MM/yyyy', 'dd-MM-yyyy', 'yyyy-MM-dd', 'yyyy/MM/dd', 'yyyy.MM.dd'};
        for i = 1:numel(fmts)
            try
                d = datetime(strtrim(string(v)), 'InputFormat', fmts{i});
                return
            catch
            end
        end
    end
end
