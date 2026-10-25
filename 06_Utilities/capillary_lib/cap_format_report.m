function cap_format_report(file, nData, nCol, rowsPerCap, keyCol, numCols, mergeKey)
% CAP_FORMAT_REPORT  Format the 'Report' sheet of an Excel report (needs Excel).
%   Blue header, light band on every second capillary, highlighted key column
%   (optionally merged into one cell per capillary), 0.00 format on numCols.
    if nargin < 7, mergeKey = false; end
    rgb = @(r,g,b) r + 256*g + 65536*b;     % Excel colour code
    col = @(k) char('A' + k - 1);
    last = nData + 1;
    excel = actxserver('Excel.Application');
    excel.DisplayAlerts = false;
    try
        wb = excel.Workbooks.Open(file);
        ws = wb.Sheets.Item('Report');
        tbl = ws.Range(sprintf('A1:%s%d', col(nCol), last));
        tbl.Font.Name = 'Calibri';
        tbl.Font.Size = 11;
        tbl.HorizontalAlignment = -4108;            % centre
        tbl.VerticalAlignment = -4108;
        tbl.Borders.LineStyle = 1;
        tbl.Borders.Color = rgb(191,191,191);

        % header
        hdr = ws.Range(sprintf('A1:%s1', col(nCol)));
        hdr.Font.Bold = true;
        hdr.Font.Color = rgb(255,255,255);
        hdr.Interior.Color = rgb(31,56,100);
        hdr.WrapText = true;
        hdr.RowHeight = 32;

        % light band on every second capillary
        r0 = 2;
        for c = 1:numel(rowsPerCap)
            r1 = r0 + rowsPerCap(c) - 1;
            if rowsPerCap(c) > 0 && mod(c,2) == 0
                ws.Range(sprintf('A%d:%s%d', r0, col(nCol), r1)).Interior.Color = rgb(242,242,242);
            end
            r0 = r1 + 1;
        end
        ws.Range(sprintf('A2:A%d', last)).Font.Bold = true;

        % key column
        kc = ws.Range(sprintf('%s1:%s%d', col(keyCol), col(keyCol), last));
        kc.Font.Bold = true;
        kc.Font.Size = 12;
        if mergeKey                                 % one merged cell per capillary
            r0 = 2;
            for c = 1:numel(rowsPerCap)
                r1 = r0 + rowsPerCap(c) - 1;
                if rowsPerCap(c) > 1
                    ws.Range(sprintf('%s%d:%s%d', col(keyCol), r0, col(keyCol), r1)).Merge;
                end
                r0 = r1 + 1;
            end
        end
        kc.Interior.Color = rgb(252,228,214);
        ws.Range(sprintf('%s1', col(keyCol))).Interior.Color = rgb(197,90,17);
        for e = [7 8 9 10]                          % left, top, bottom, right edges
            kc.Borders.Item(e).Weight = -4138;      % medium
            kc.Borders.Item(e).Color = rgb(197,90,17);
        end

        % number formats for numeric columns
        for k = numCols
            ws.Range(sprintf('%s2:%s%d', col(k), col(k), last)).NumberFormat = '0.00';
        end

        ws.Columns.AutoFit;
        for k = 1:nCol
            w = ws.Columns.Item(k).ColumnWidth;
            ws.Columns.Item(k).ColumnWidth = min(max(w + 2, 10), 24);
        end

        ws.Activate;
        excel.ActiveWindow.SplitRow = 1;            % freeze header
        excel.ActiveWindow.FreezePanes = true;
        excel.ActiveWindow.DisplayGridlines = false;

        wb.Save;
        wb.Close(false);
    catch err
        warning('Report written but formatting failed: %s', err.message);
        try, wb.Close(false); catch, end
    end
    excel.Quit;
    delete(excel);
end
