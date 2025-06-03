% run_my_rocket_sim.m
clear; clc; close all;

% Ensure all your .m files (rockets.m, Rocket.m, SimulateRocket.m,
% loadAtmosphereLookupTable.m, getAtmosphericConditions.m) are in MATLAB's path.

% --- Select the specific rocket models you want to simulate ---
rockets = {rockets("Falcon 9 Optimum"), ...
 rockets("Falcon 9 Fast"), ...
 rockets("Falcon 9")};


% --- Define common simulation targets (or make them per-rocket if needed) ---
target_altitude_km = 300; % km
target_time_minutes = 9;  % minutes
simulation_time_step = 0.1; % s

% --- Loop Through Each Rocket and Run Simulation ---
for i = 1:length(rockets)
    current_rocket_params = rockets{i};

    fprintf('\n====================================================\n');
    fprintf('SIMULATING: %s\n', current_rocket_params.name); % Use the 'name' field for display
    fprintf('====================================================\n');

    % Create an instance of the SimulateRocket class for the current rocket
    sim = SimulateRocket(Rocket(current_rocket_params), ...
                         target_altitude_km, ...
                         target_time_minutes, ...
                         simulation_time_step);

    % Run the simulation
    sim.runSimulation();

    % Plot the results
    sim.plotResults();
end

fprintf('\nAll simulations completed!\n');