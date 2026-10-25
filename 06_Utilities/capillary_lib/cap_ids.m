function ids = cap_ids(s)
% CAP_IDS  All capillary IDs in a text, normalised to e.g. "D076-009" or "20260303-006".
%   "P.O.B-D076-9", "POB-D076-009" and "D076-009" all give "D076-009".
    ids = strings(0,1);
    s = string(s);
    if isempty(s) || ismissing(s) || s == "", return; end
    tok = regexp(upper(s), '(?<![\dA-Z])(D\d{3}|\d{8})-(\d{1,3})(?!\d)', 'tokens');
    for i = 1:numel(tok)
        ids(end+1,1) = sprintf('%s-%03d', tok{i}{1}, str2double(tok{i}{2})); %#ok<AGROW>
    end
    ids = unique(ids, 'stable');
end
