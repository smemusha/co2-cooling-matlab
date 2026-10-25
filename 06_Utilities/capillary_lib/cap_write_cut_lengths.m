function cut = cap_write_cut_lengths(lengthsFile, sfpFolder, capIDs, finalLength, finalStd, margin, testLength)
% CAP_WRITE_CUT_LENGTHS  Cut lengths for the single-flow-point test.
%   cut = round(final) + round(STD) + margin   [mm], at most the tested length
%   - fills the empty "Current length (mm)" cells of the flow-scan lengths.xlsx
%   - creates <sfpFolder>\lengths.xlsx with Test length = cut (if it does not exist)
%   Existing values are never overwritten; differences are only reported.
    capIDs = string(capIDs(:));
    rule = round(finalLength(:)) + round(finalStd(:)) + margin;
    cut = min(rule, testLength(:));             % cannot be longer than tested
    ok = isfinite(cut);

    fprintf('\nCut lengths for the single flow point test (final + STD + %g mm)\n', margin);
    fprintf('  %-16s %10s %8s %10s\n', 'Capillary', 'Final [mm]', 'STD [mm]', 'Cut [mm]');
    for c = 1:numel(capIDs)
        note = ''; if rule(c) > cut(c), note = sprintf('  (rule %g > tested length, kept)', rule(c)); end
        fprintf('  %-16s %10.0f %8.0f %10.0f%s\n', capIDs(c), finalLength(c), finalStd(c), cut(c), note);
    end

    % 1) current length in the flow-scan lengths.xlsx
    T = readtable(lengthsFile, 'VariableNamingRule', 'preserve', 'TextType', 'string');
    if width(T) < 3, T.("Current length (mm)") = NaN(height(T),1); end
    cur = T{:,3};
    if ~isnumeric(cur), cur = str2double(string(cur)); end
    changed = false;
    for i = 1:height(T)
        k = cap_ids(string(T{i,1}));
        c = find(arrayfun(@(s) isequal(cap_ids(s), k), capIDs), 1);
        if isempty(c) || ~ok(c), continue; end
        if ~isfinite(cur(i))
            cur(i) = cut(c); changed = true;
        elseif cur(i) ~= cut(c)
            fprintf('  note: %s current length kept at %g mm (rule gives %g mm)\n', capIDs(c), cur(i), cut(c));
        end
    end
    if changed
        T.(T.Properties.VariableNames{3}) = cur;
        writetable(T, lengthsFile);
        fprintf('  Current lengths filled in: %s\n', lengthsFile);
    end

    % 2) lengths.xlsx of the single flow point test
    sfpFile = fullfile(sfpFolder, 'lengths.xlsx');
    if isfile(sfpFile)
        [tl, ~] = cap_read_lengths(sfpFile, capIDs(ok));
        ids = capIDs(ok); d = tl ~= cut(ok);
        if any(d)
            fprintf('  note: %s already exists and differs for %s - not changed\n', ...
                sfpFile, strjoin(ids(d), ', '));
        end
    else
        if ~isfolder(sfpFolder), mkdir(sfpFolder); end
        S = table(capIDs(ok), cut(ok), NaN(nnz(ok),1), 'VariableNames', ...
            {'Capillary', 'Test length (mm)', 'Current length (mm)'});
        writetable(S, sfpFile);
        fprintf('  Created: %s\n', sfpFile);
    end
end
