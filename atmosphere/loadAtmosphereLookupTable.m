% loadAtmosphereLookupTable.m
% This function loads the atmospheric lookup table from a .mat file.
% It uses a persistent variable to ensure the file is loaded only once per MATLAB session.

function lookupTable = loadAtmosphereLookupTable()
    persistent loaded_table; % This variable retains its value between calls

    % Check if the table has already been loaded
    if isempty(loaded_table) || ~isstruct(loaded_table)
        fprintf('Loading atmosphere_lookup_table.mat for the first time via function...\n');
        try
            data = load('atmosphere_lookup_table.mat');
            loaded_table = data.atmosphere_lookup_table; % Extract the struct
        catch ME
            if strcmp(ME.identifier, 'MATLAB:load:couldNotReadFile')
                error('AtmosphereLookup:TableMissing', ...
                      'atmosphere_lookup_table.mat not found. Please run generateAtmosphereLookupTable.m first.');
            else
                rethrow(ME);
            end
        end
    end
    lookupTable = loaded_table; % Return the (persisted) lookup table
end