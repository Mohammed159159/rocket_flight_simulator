classdef Rocket < handle
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
        dt;             % Time step (0.1 s)

        % --- Dynamic Rocket State (These change over time) ---
        mass;           % Current mass of the rocket (kg)
        fuel            % Current mass of fuel from the rocket's mass (kg)

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
            rocket.dt = 0.1;

            % Initialize the dynamic rocket parameters
            rocket.mass = rocketParams.mass;
            rocket.fuel = rocketParams.fuel;
            rocket.velocity = 0;

            rocket.altitude = 0;
            rocket.time = 0;

            rocket.F_net = 0;
            rocket.T_m = 0;
            rocket.T_p = 0;
            rocket.W = 0;
            rocket.D = 0;
            rocket.acceleration = 0;

            rocket.atmos = lookupAtmos(rocket.altitude);
        end

        % --- Method to Calculate Mass Flow Rate (helper function) ---
        function m_dot = mDot(rocket)
            % Calculates the mass flow rate of exhaust gases.
            m_dot = rocket.rho_exhaust * rocket.no_nozzles * rocket.A_exit * (rocket.v_exit + rocket.velocity); % kg/s

            % Handle case where fuel is nearly depleted (no more m_dot)
            if rocket.fuel - m_dot * rocket.dt < 0
                m_dot = rocket.fuel / rocket.dt; % Adjust m_dot if fuel runs out too fast for dt
                rocket.v_exit = m_dot / (rocket.rho_exhaust * rocket.A_exit * rocket.no_nozzles) - rocket.velocity;
                % TODO: P_exit should be updated as well
            end

            % m_dot should not be negative
            if m_dot <= 0
                m_dot = 0;
                rocket.v_exit = 0;
                rocket.P_exit = rocket.atmos.P;
            end
        end

        % --- Helper Method to Get Mass for Weight Calculation ---
        % This accounts for the mass burned during the dt interval for the original equation.
        function m = nextMass(rocket)
            m_dot = rocket.mDot();
            m = rocket.mass - (m_dot * rocket.dt);
            if m < 0
                m = 0; % Mass cannot be negative
            end
        end

        % --- Method to Get Momentum Thrust Force (RHS) ---
        function T_m = momentumThrust(rocket)
            T_m = rocket.mDot() * (rocket.v_exit + rocket.velocity);
        end

        % --- Method to get Pressure Thrust Force ---
        % Currently not used assuming ideal expansion
        function T_p = pressureThrust(rocket)
            T_p = (rocket.P_exit - rocket.atmos.P) * rocket.no_nozzles * rocket.A_exit;
        end

        % --- Method to Drag Force ---
        function D = drag(rocket)
            D = rocket.cd * (0.5 * rocket.atmos.rho * (rocket.velocity^2)) * rocket.A_projected; % Using rho_exhaust as air density
            if rocket.velocity < 0
                D = -D; % Drag opposes motion
            end
        end

        % --- Method to Calculate Weight Force ---
        function W = weight(rocket)
            m = rocket.nextMass();
            W = m * rocket.atmos.g;
        end

        % --- Method to Calculate Net External Force ---
        function F_net = netForce(rocket)
            rocket.T_m = rocket.momentumThrust();
            rocket.W = rocket.weight();
            rocket.D = rocket.drag();
            rocket.T_p = rocket.pressureThrust();

            F_net = rocket.T_m + rocket.T_p - rocket.W - rocket.D;
        end

        % --- Method to Calculate Net Force from Momentum Change ---
        function F_net = rateOfChangeOfMomentum(rocket)
            % This calculates the (dp/dt) termm
            m = rocket.nextMass(); % Uses dt internally
            F_net = (1 / rocket.dt) * rocket.velocity * m; % TODO: should be dp / dt
        end

        % --- Method to Update Rocket's State for Simulation ---
        function updateState(rocket, dt_sim)
            % Updates the rocket's dynamic parameters (mass, velocity, altitude, and time, etc.)

            % 1. Get Net Force for the current state (automatically updates thrust, weight, and drag)
            rocket.F_net = rocket.netForce();

            % 2. Calculate instantaneous acceleration
            rocket.acceleration = rocket.F_net / rocket.mass; % should be m - mdot dt

            % 3. Get mass flow rate for mass update
            m_dot = rocket.mDot();
            rocket.P_exit = rocket.atmos.P;

            % 4. Update Velocity (Explicit Euler Method)
            rocket.velocity = rocket.velocity + rocket.acceleration * rocket.dt;

            % 5. Update Altitude (using updated velocity for better accuracy)
            rocket.altitude = rocket.altitude + rocket.velocity * dt_sim;

            if rocket.altitude < 0
                rocket.altitude = 0;
            end

            % 6. Update Fuel and Mass
            rocket.fuel = rocket.fuel - m_dot * dt_sim;
            rocket.mass = rocket.mass - m_dot * dt_sim;

            % 7. Update Time
            rocket.time = rocket.time + dt_sim;

            % 8. Update environmental conditions
            rocket.atmos = lookupAtmos(rocket.altitude);

            % Solve for the initial velocity of rocket after first time step (dt)
            if rocket.time == 0
                rocket.velocity = solveRocket(rocket);
            end

        end

    end % methods

end % classdef
