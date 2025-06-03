% getAtmosphericConditions.m
% This function provides atmospheric properties (pressure, density, temperature, gravity)
% at a given altitude, using a pre-loaded lookup table.

function atmos_data = lookupAtmos(altitude_m)
    % Get the lookup table. This will automatically load it once if not already in memory.
    lookupTable = loadAtmosphereLookupTable(); % Call the loading function

    % Ensure altitude is within the lookup table's range
    current_alt_for_interp = altitude_m;
    min_table_alt = lookupTable.altitudes_m(1);
    max_table_alt = lookupTable.altitudes_m(end);

    if altitude_m < min_table_alt
        current_alt_for_interp = min_table_alt;
    elseif altitude_m > max_table_alt
        current_alt_for_interp = max_table_alt;
        % You might want to add a warning here if this happens frequently:
        % warning('AtmosphereLookup:AltitudeOutOfRange', ...
        %         'Altitude %.2f m is outside atmosphere lookup table range (max %.2f m). Using max altitude values for interp.', ...
        %         altitude_m, max_table_alt);
    end

    % Perform linear interpolation
    atmos_data = struct(); % Create a struct to hold the results
    atmos_data.P = interp1(lookupTable.altitudes_m, ...
                                  lookupTable.pressure, ...
                                  current_alt_for_interp, 'linear');
    atmos_data.rho = interp1(lookupTable.altitudes_m, ...
                            lookupTable.density, ...
                            current_alt_for_interp, 'linear');
    atmos_data.T = interp1(lookupTable.altitudes_m, ...
                           lookupTable.temperature, ...
                           current_alt_for_interp, 'linear');
    atmos_data.g = interp1(lookupTable.altitudes_m, ...
                           lookupTable.gravity, ...
                           current_alt_for_interp, 'linear');
end