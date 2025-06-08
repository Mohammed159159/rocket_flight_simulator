classdef Rocket
    % Rocket: Defines the rocket's properties and methods for calculations and state updates.

    properties
        % --- Fixed Rocket Parameters (Constants of the rocket's design) ---
        name;           % Name of the rocket model
        no_nozzles;     % Number of engine nozzles
        cd;             % Coefficient of Drag
        rho_exhaust;    % Density of exhaust gases (kg/m^3)
        A_projected;    % Projected frontal area for drag (m^2)
        A_exit;         % Nozzle exit area (m^2)
        v_exit;         % Exhaust velocity relative to nozzle (m/s)
        P_exit;         % Exhaust pressure at nozzle exit (Pa)

        % --- Dynamic Rocket State (These change over time) ---
        mass;           % Current total mass of the rocket (kg)
        fuel            % Current mass of fuel from the rocket's total mass (kg)
        m_dot           % Current mass flow rate of fuel (kg/s)

        altitude;       % Current altitude of the rocket (m)
        time;           % Current simulation time (s)

        atmos           % Current environmental conditions
        % (P [Pa] - air pressure, g [m/s^2] - gravitational acceleration, rho [kg/m^3] - air density)


        F_net;          % Current net force on the rocket (N)
        T_m;            % Current momentum thrust force on the rocket (N)
        T_p;            % Current pressure thrust force on the rocket (N)
        W;              % Current weight of the rocket (N)
        D;              % Current drag force on the rocket (N)

        velocity;       % Current velocity of the rocket (m/s)
        acceleration;   % Current acceleration of the rocket (m/s^2)

    end % properties

    methods
        % --- Constructor Method --- %
        % Accepts a 'rocketParams' struct for all the fixed parameters and rocket's initial state.
        function rocket = Rocket(rocketParams)

            % Initialize the fixed rocket parameters from the 'rocketParams' struct
            rocket.name = rocketParams.name;
            rocket.no_nozzles = rocketParams.no_nozzles;
            rocket.cd = rocketParams.cd;
            rocket.rho_exhaust = rocketParams.rho_exhaust;
            rocket.A_projected = rocketParams.A_projected;
            rocket.A_exit = rocketParams.A_exit;
            rocket.v_exit = rocketParams.v_exit; % Should a dynamic parameter
            rocket.P_exit = rocketParams.P_exit; % Shold be a dynamic parameter

            % Initialize the dynamic rocket parameters
            rocket.mass = rocketParams.mass;
            rocket.fuel = rocketParams.fuel;
            rocket.m_dot = rocket.mDot();

            rocket.velocity = 0;

            rocket.altitude = 0;
            rocket.time = 0;

            rocket.atmos = lookupAtmos(rocket.altitude);

            rocket.T_m = rocket.momentumThrust();
            rocket.T_p = rocket.pressureThrust();
            rocket.W = rocket.weight();
            rocket.D = rocket.drag();
            rocket.F_net = rocket.netForce();

            rocket.acceleration = rocket.F_net / rocket.mass;
        end

        % --- Method to Calculate Mass Flow Rate (helper function) ---
        function m_dot = mDot(rocket)
            m_dot = rocket.rho_exhaust * (rocket.no_nozzles * rocket.A_exit) * rocket.v_exit;
        end

        % --- Method to Calculate Momentum Thrust Force ---
        function T_m = momentumThrust(rocket)
            T_m = rocket.m_dot * rocket.v_exit;
        end

        % --- Method to Calculate Pressure Thrust Force ---
        function T_p = pressureThrust(rocket)
            T_p = (rocket.P_exit - rocket.atmos.P) * rocket.no_nozzles * rocket.A_exit;
        end

        % --- Method to Calculate Drag Force ---
        function D = drag(rocket)
            D = rocket.cd * (0.5 * rocket.atmos.rho * (rocket.velocity^2)) * rocket.A_projected;
            if rocket.velocity < 0
                D = -D; % Drag opposes motion
            end
        end

        % --- Method to Calculate Weight Force ---
        function W = weight(rocket)
            W = rocket.mass * rocket.atmos.g;
        end

        % --- Method to Calculate Net Force ---
        function F_net = netForce(rocket)
            F_net = rocket.T_m + rocket.T_p - rocket.W - rocket.D;
        end

        % --- Method to Calculate Net Force from Momentum Change ---
        function F_net = rateOfChangeOfMomentum(rocket, v_o, dt)
            % This calculates the (dp/dt) termm
            F_net = (1 / dt) * (rocket.velocity - v_o) * rocket.mass;
        end

        % --- Method to Update Rocket's State for Simulation ---
        % Updates the rocket's dynamic parameters (mass, velocity, altitude, and time, etc.)
        function rocket_obj = updateState(rocket, dt)
            % --- Calculate variables for next state ---

            % 1. Update altitude using velocity and acceleration of previous state
            rocket.altitude = rocket.altitude + rocket.velocity * dt ...
                + 1/2 * rocket.acceleration * dt^2;
            rocket.altitude = max(rocket.altitude, 0);  % Ground clamp

            % 2. Update fuel and mass using mass flow rate of previous state
            rocket.fuel = rocket.fuel - rocket.m_dot * dt;
            rocket.mass = rocket.mass - rocket.m_dot * dt;

            % 3. Update velocity (Explicit Euler Method)
            rocket.velocity = rocket.velocity + rocket.acceleration * dt;

            % 4. Update mass flow rate - Handle case where fuel is nearly depleted (no more m_dot)
            if rocket.fuel <= 0
                rocket.m_dot = 0;
                rocket.fuel = 0;
            elseif rocket.fuel < rocket.m_dot * dt
                rocket.m_dot = rocket.fuel / dt; % Adjust m_dot if fuel runs out too fast for dt
                % TODO: P_exit should be updated as well?
            end

            % 5. Update time
            rocket.time = rocket.time + dt;

            % 6. Update environmental conditions
            rocket.atmos = lookupAtmos(rocket.altitude);
            rocket.P_exit = rocket.atmos.P; % Update exit pressure assuming ideal expansion

            % 7. Update forces
            rocket.T_m = rocket.momentumThrust();
            rocket.T_p = rocket.pressureThrust();
            rocket.W = rocket.weight();
            rocket.D = rocket.drag();
            rocket.F_net = rocket.netForce();

            % 8. Update acceleration
            rocket.acceleration = rocket.F_net / rocket.mass;

            rocket_obj = rocket;
        end

    end % methods

end % classdef
