function name = cap_report_name(capIDs, suffix)
% CAP_REPORT_NAME  Report file name from the capillary IDs,
%   e.g. "POB-D076-009_to_012_<suffix>.xlsx".
    k = strings(numel(capIDs),1);
    for i = 1:numel(capIDs), k(i) = cap_ids(capIDs(i)); end
    k = sort(k);
    first = "POB-" + k(1);
    if isscalar(k)
        name = first + "_" + suffix + ".xlsx";
    else
        name = first + "_to_" + regexp(k(end), '\d+$', 'match', 'once') + "_" + suffix + ".xlsx";
    end
    name = char(name);
end
