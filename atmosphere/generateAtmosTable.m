% generateAtmosphereLookupTable.m
% This script generates a lookup table for atmospheric properties and gravity
% at various altitudes and saves it to a .mat file.

clear; clc;

fprintf('Generating atmospheric lookup table...\n');

% --- Configuration for the Lookup Table ---
max_altitude_km = 500; % Maximum altitude for your table (e.g., 1000 km, beyond which atmos is negligible)
altitude_step_m = 50;  % Altitude step size in meters (e.g., every 50m)

% Create a vector of altitudes
altitudes_m = 0:altitude_step_m:(max_altitude_km * 1000); % Convert km to m

% Initialize arrays to store results
num_points = length(altitudes_m);
pressure_lookup = zeros(num_points, 1);
density_lookup = zeros(num_points, 1);
temperature_lookup = zeros(num_points, 1);
gravity_lookup = zeros(num_points, 1); % Assuming StandardAtmos gives 'g' or you'll use your own

% --- Loop to Populate the Table ---
for i = 1:num_points
    current_alt = altitudes_m(i);

    % Call StandardAtmos (assuming it returns T, P, rho in a struct)
    % Adjust this call based on your StandardAtmos function's actual output structure
    atmos_data = StandardAtmos(current_alt, "HeightUnit", "m", "OutputFormat", "struct");

    pressure_lookup(i) = atmos_data.P;
    density_lookup(i) = atmos_data.rho;
    temperature_lookup(i) = atmos_data.T; % Store temperature if needed for other calcs

    % --- Gravity Lookup ---
    % If StandardAtmos provides 'g', use atmos_data.g.
    % Otherwise, use your getGravity function:
    gravity_lookup(i) = atmos_data.g; % Assuming you have getGravity.m
end

% --- Store all lookup data in a single struct ---
atmosphere_lookup_table.altitudes_m = altitudes_m;
atmosphere_lookup_table.pressure = pressure_lookup;
atmosphere_lookup_table.density = density_lookup;
atmosphere_lookup_table.temperature = temperature_lookup;
atmosphere_lookup_table.gravity = gravity_lookup;

% --- Save the Lookup Table to a .mat file ---
save('atmosphere_lookup_table.mat', 'atmosphere_lookup_table');

fprintf('Atmospheric lookup table generated and saved to atmosphere_lookup_table.mat\n');
fprintf('Table covers 0 to %.0f km with %.0f m steps.\n', max_altitude_km, altitude_step_m);