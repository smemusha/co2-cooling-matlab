function cap_print_windows(found)
% CAP_PRINT_WINDOWS  Compact table of the stable windows read from the timestamp files.
    fprintf('\nStable windows (timestamp files)\n');
    fprintf('  %-16s %-9s %-10s %-5s  %-5s  %s\n', 'Capillary', 'Flow', 'Date', 'From', 'To', 'Note');
    for i = 1:height(found)
        fprintf('  %-16s %-9s %-10s %-5s  %-5s  %s\n', found.Capillary(i), found.Flow(i), ...
            char(found.From(i), 'dd.MM.yyyy'), char(found.From(i), 'HH:mm'), ...
            char(found.To(i), 'HH:mm'), found.Note(i));
    end
end
