% SimulateRocket.m
classdef SimulateRocket < handle
    properties
        % --- Configuration Properties (Inputs to the simulation) ---
        timeStep = 0.1; % Simulation time step (s) - default value
        targetAltitude_m; % Target altitude of the flight (m)
        targetTime_s;     % Target time of completion for the flight (s)

        % --- Simulation State/Results Properties (Outputs of the simulation) ---
        rocket; % An instance of the Rocket class, representing the rocket's current state
        simHistory; % A structure to hold all simulation history data for plotting/analysis
    end

    methods
        % --- Constructor Method ---
        % This method is called when you create an simulationect of SimulateRocket class.
        % It sets up the simulation parameters and initializes the rocket simulationect.
        function simulation = SimulateRocket(rocket, target_altitude_km_input, target_time_minutes_input, time_step_input)
            % Assign input parameters to class properties
            simulation.targetAltitude_m = target_altitude_km_input * 1000; % Convert km to m
            simulation.targetTime_s = target_time_minutes_input * 60;     % Convert minutes to seconds
            simulation.rocket = rocket;

            % Allow time_step to be overridden if provided, otherwise use default (0.1s)
            if nargin > 3 && ~isempty(time_step_input)
                simulation.timeStep = time_step_input;
            end

            % Initialize simHistory structure with the rocket's initial state
            simulation.simHistory = struct();

            % Get rocket's initial state (at time step 0)
            simulation.simHistory.time = simulation.rocket.time;
            simulation.simHistory.mass = simulation.rocket.mass;
            simulation.simHistory.velocity = simulation.rocket.velocity;
            simulation.simHistory.altitude = simulation.rocket.altitude;
            simulation.simHistory.acceleration = simulation.rocket.acceleration;
            simulation.simHistory.net_force = simulation.rocket.F_net;
            simulation.simHistory.momentum_thrust = simulation.rocket.T_m;
            simulation.simHistory.pressure_thrust = simulation.rocket.T_p;
            simulation.simHistory.drag = simulation.rocket.D;
            simulation.simHistory.weight = simulation.rocket.W;
            simulation.simHistory.P_ambient = simulation.rocket.atmos.P;
            simulation.simHistory.P_exit = simulation.rocket.P_exit;
            simulation.simHistory.temperature = simulation.rocket.atmos.T;
            simulation.simHistory.rho_air = simulation.rocket.atmos.rho;
            simulation.simHistory.g_local = simulation.rocket.atmos.g;
        end

        % --- runSimulation Method ---
        % This method contains the main simulation loop.
        function runSimulation(simulation) % 'simulation' is passed by reference (handle class behavior)
            fprintf('Rocket model: %s\n', simulation.rocket.name);
            fprintf('Starting Rocket Simulation...\n');
            fprintf('Target: %.0f km altitude within %.0f minutes (%.0f s)\n', ...
                simulation.targetAltitude_m/1000, simulation.targetTime_s/60, simulation.targetTime_s);
            fprintf('Time: %.1f s, Alt: %.2f km, Vel: %.2f m/s, Mass: %.2f kg\n', ...
                simulation.rocket.time, simulation.rocket.altitude/1000, simulation.rocket.velocity, simulation.rocket.mass);

            % Simulation Loop
            while simulation.rocket.altitude < simulation.targetAltitude_m && ... % Check altitude target
                    simulation.rocket.time < simulation.targetTime_s && ...     % Check time target
                    simulation.rocket.mass > 0.01 && ...                  % Avoid division by zero
                    simulation.rocket.velocity >= -1 % Prevent indefinite simulation if it crashes and goes negative velocity
                % (e.g., if it hits ground with negative velocity)

                % --- Update the Rocket's State ---
                simulation.rocket = simulation.rocket.updateState(simulation.timeStep);

                % --- Store history for plotting ---
                % Append the *new* state (after update) and the *calculated* acceleration/net force
                simulation.simHistory.time = [simulation.simHistory.time; simulation.rocket.time];
                simulation.simHistory.mass = [simulation.simHistory.mass; simulation.rocket.mass];
                simulation.simHistory.velocity = [simulation.simHistory.velocity; simulation.rocket.velocity];
                simulation.simHistory.altitude = [simulation.simHistory.altitude; simulation.rocket.altitude];
                simulation.simHistory.acceleration = [simulation.simHistory.acceleration; simulation.rocket.acceleration];
                simulation.simHistory.net_force = [simulation.simHistory.net_force; simulation.rocket.F_net];
                simulation.simHistory.P_ambient = [simulation.simHistory.P_ambient; simulation.rocket.atmos.P];
                simulation.simHistory.P_exit = [simulation.simHistory.P_exit; simulation.rocket.P_exit];
                simulation.simHistory.temperature = [simulation.simHistory.temperature; simulation.rocket.atmos.T];
                simulation.simHistory.rho_air = [simulation.simHistory.rho_air; simulation.rocket.atmos.rho];
                simulation.simHistory.g_local = [simulation.simHistory.g_local; simulation.rocket.atmos.g];
                simulation.simHistory.momentum_thrust = [simulation.simHistory.momentum_thrust; simulation.rocket.T_m];
                simulation.simHistory.drag = [simulation.simHistory.drag; simulation.rocket.D];
                simulation.simHistory.weight = [simulation.simHistory.weight; simulation.rocket.W];

                % --- Check for Ground Impact (if needed) ---
                % if simulation.rocket.altitude <= 0 && (simulation.rocket.time > simulation.timeStep) % Avoid breaking on initial t=0, h=0
                %     fprintf('Rocket hit ground at %.1f s. Simulation ended.\n', simulation.rocket.time);
                %     break; % Exit loop if rocket hits ground
                % end

                % --- Display progress (optional) ---
                % The modulo condition ensures printing roughly every 10 seconds.
                % `mod(rocket.time, 10) < time_step` ensures it triggers when time crosses a multiple of 10.
                if rem(simulation.rocket.time, 10) < simulation.timeStep % Print every 10 seconds
                    % Re-calculate component forces for display if they are not stored as properties in Rocket
                    % Assuming rocket.momentumThrust(), rocket.weight(), rocket.drag() are methods
                    fprintf('Time: %.1f s, Alt: %.2f km, Vel: %.2f m/s, Mass: %.2f kg\n', ...
                        simulation.rocket.time, simulation.rocket.altitude/1000, simulation.rocket.velocity, simulation.rocket.mass);
                end
            end

            % --- Display Final Results Summary ---
            simulation.displayResults(); % Call a separate helper method
        end

        % --- Helper Method to Display Final Results ---
        function displayResults(simulation)
            fprintf('\n--- Simulation Finished ---\n');
            fprintf('Final Time: %.2f s (%.2f minutes)\n', simulation.rocket.time, simulation.rocket.time/60);
            fprintf('Final Altitude: %.2f km\n', simulation.rocket.altitude/1000);
            fprintf('Final Velocity: %.2f m/s\n', simulation.rocket.velocity);
            fprintf('Final Mass: %.2f kg\n', simulation.rocket.mass);

            % Check if targets were met
            if simulation.rocket.altitude >= simulation.targetAltitude_m && simulation.rocket.time <= simulation.targetTime_s
                fprintf('\nSUCCESS! Rocket reached %.0f km within %.0f minutes.\n', simulation.targetAltitude_m/1000, simulation.targetTime_s/60);
            elseif simulation.rocket.altitude >= simulation.targetAltitude_m
                fprintf('\nRocket reached %.0f km, but took %.2f minutes (longer than %.0f minutes).\n', ...
                    simulation.targetAltitude_m/1000, simulation.rocket.time/60, simulation.targetTime_s/60);
            elseif simulation.rocket.time >= simulation.targetTime_s
                fprintf('\nRocket did NOT reach %.0f km within %.0f minutes. Max altitude: %.2f km.\n', ...
                    simulation.targetAltitude_m/1000, simulation.targetTime_s/60, simulation.rocket.altitude/1000);
            elseif simulation.rocket.mass <= 0.01 && simulation.rocket.altitude < simulation.targetAltitude_m
                fprintf('\nRocket ran out of fuel before reaching target altitude/time. Max altitude: %.2f km.\n', simulation.rocket.altitude/1000);
            else
                fprintf('\nSimulation ended due to other conditions (e.g., ground impact with negative velocity, or unexpected loop exit).\n');
            end
        end

        % --- plotResults Method ---
        % This method plots the simulation history.
        function plotResults(simulation)
            figure('Name', ['Rocket Simulation Results - ' simulation.rocket.name]);

            subplot(4,1,1);
            plot(simulation.simHistory.time, simulation.simHistory.altitude/1000, 'b-');
            xlabel('Time (s)');
            ylabel('Altitude (km)');
            title('Altitude vs. Time');
            grid on;

            subplot(4,1,2);
            plot(simulation.simHistory.time, simulation.simHistory.velocity, 'r-');
            xlabel('Time (s)');
            ylabel('Velocity (m/s)');
            title('Velocity vs. Time');
            grid on;

            subplot(4,1,3);
            plot(simulation.simHistory.time, simulation.simHistory.mass, 'g-');
            xlabel('Time (s)');
            ylabel('Mass (kg)');
            title('Mass vs. Time');
            grid on;

            subplot(4,1,4);
            plot(simulation.simHistory.time, simulation.simHistory.acceleration, 'm-');
            xlabel('Time (s)');
            ylabel('Acceleration (m/s^2)');
            title('Acceleration vs. Time');
            grid on;

            % figure(Name = ['Rocket Simulation Results - ' simulation.rocket.name] );

            % subplot(4,1,1);
            % plot(simulation.simHistory.time, simulation.simHistory.net_force, 'b-');
            % xlabel('Time (s)');
            % ylabel('Net Force (N)');
            % title('Net Force vs. Time');
            % grid on;

            % subplot(4,1,2);
            % plot(simulation.simHistory.time, simulation.simHistory.momentum_thrust + simulation.simHistory.pressure_thrust, 'r-');
            % xlabel('Time (s)');
            % ylabel('Thrust (N)');
            % title('Thrust vs. Time');
            % grid on;

            % subplot(4,1,3);
            % plot(simulation.simHistory.time, simulation.simHistory.drag, 'g-');
            % xlabel('Time (s)');
            % ylabel('Drag (N)');
            % title('Drag vs. Time');
            % grid on;

            % subplot(4,1,4);
            % plot(simulation.simHistory.time, simulation.simHistory.weight, 'm-');
            % xlabel('Time (s)');
            % ylabel('Weight (N)');
            % title('Weight vs. Time');
            % grid on;

            % figure(Name = ['Rocket Simulation Results - ' simulation.rocket.name] );

            % subplot(4,1,1);
            % plot(simulation.simHistory.time, simulation.simHistory.P_ambient, 'b-');
            % xlabel('Time (s)');
            % ylabel('Ambient Pressure (Pa)');
            % title('Ambient Pressure vs. Time');
            % grid on;

            % subplot(4,1,2);
            % plot(simulation.simHistory.time, simulation.simHistory.P_exit, 'r-');
            % xlabel('Time (s)');
            % ylabel('Exit Pressure (Pa)');
            % title('Exit Pressure vs. Time');
            % grid on;

            % subplot(4,1,3);
            % plot(simulation.simHistory.time, simulation.simHistory.temperature, 'g-');
            % xlabel('Time (s)');
            % ylabel('Temperature (K)');
            % title('Temperature vs. Time');
            % grid on;

            % subplot(4,1,4);
            % plot(simulation.simHistory.time, simulation.simHistory.g_local, 'm-');
            % xlabel('Time (s)');
            % ylabel('g (m/s^2)');
            % title('Gravitational Acceleration vs. Time');
            % grid on;

        end
    end
end