classdef Rocket < handle
    % RocketModel: Defines the rocket's properties and methods for calculations and state updates.

    properties
        % --- Fixed Rocket Parameters (Constants of the rocket's design) ---
        name;
        no_nozzles;     % Number of engine nozzles
        cd;             % Coefficient of Drag
        rho_exhaust;    % Density of exhaust gases (kg/m^3) - Renamed from 'rho' to avoid confusion with ambient air density
        A_projected;    % Projected frontal area for drag (m^2)
        A_exit;         % Nozzle exit area (m^2)
        v_exit;         % Exhaust velocity relative to nozzle (m/s)
        P_exit;         % Exhaust pressure at nozzle exit (Pa)
        dt;          % The specific dt used in the original LHS = RHS equation (0.1 s)

        % --- Dynamic Rocket State (These change over time) ---
        mass;           % Current mass of the rocket (kg)
        fuel            % Amount of rocket mass that is fuel
        velocity;       % Current velocity of the rocket (m/s)

        altitude;       % Current altitude of the rocket (m)
        time;           % Current simulation time (s)

        atmos           % Current environmental conditions (P [Pa], g [m/s^2], rho [kg/m^3])

        F_net;          % Current net force on the rocket (N)
        acceleration;   % Current acceleration of the rocket (m/s^2)

    end % properties

    methods
        % --- MODIFIED Constructor Method ---
        % It now accepts a 'rocketParams' struct for all the fixed parameters.
        % The dynamic initial conditions (initialMass, etc.) and environmental
        % parameters (fixed_P_ambient, fixed_g) remain separate.
        function rocket = Rocket(rocketParams)

            % Initialize the fixed rocket parameters from the 'rocketParams' struct
            % You will assign each property from the struct's fields:
            rocket.name = rocketParams.name;
            rocket.no_nozzles = rocketParams.no_nozzles;
            rocket.cd = rocketParams.cd;
            rocket.rho_exhaust = rocketParams.rho_exhaust;
            rocket.A_projected = rocketParams.A_projected;
            rocket.A_exit = rocketParams.A_exit;
            rocket.v_exit = rocketParams.v_exit;
            rocket.P_exit = rocketParams.P_exit;
            rocket.dt = 0.1;

            % The rest of your constructor (dynamic state, environmental) remains the same:
            rocket.mass = rocketParams.mass; % <--- CHANGE IS HERE
            rocket.fuel = rocketParams.fuel;
            rocket.velocity = 0;

            rocket.altitude = 0;
            rocket.time = 0;

            rocket.F_net = 0;
            rocket.acceleration = 0;

            rocket.atmos = lookupAtmos(rocket.altitude);


        end

        % --- Method to Calculate Mass Flow Rate (helper function) ---
        function m_dot_gasses = mDot(rocket)
            % Calculates the mass flow rate of exhaust gases.
            m_dot_gasses = rocket.rho_exhaust * rocket.no_nozzles * rocket.A_exit * (rocket.v_exit + rocket.velocity); % kg/s
            % % Handle cases where mass is nearly depleted (no more m_dot)
            if rocket.fuel - m_dot_gasses * rocket.dt < 0
                m_dot_gasses = rocket.fuel / rocket.dt; % Adjust m_dot if fuel runs out too fast for dt
                rocket.v_exit = m_dot_gasses / (rocket.rho_exhaust * rocket.A_exit * rocket.no_nozzles) - rocket.velocity;
            end

            if m_dot_gasses <= 0
                m_dot_gasses = 0;
                rocket.v_exit = 0;
                rocket.P_exit = rocket.atmos.P;
            end
        end

        % --- Helper Method to Get Mass for Weight/RHS Calculation ---
        % This accounts for the mass burned during the dt interval for the original equation.
        function m_rocket = nextMass(rocket)
            m_dot = rocket.mDot();
            m_rocket = rocket.mass - (m_dot * rocket.dt);
            if m_rocket < 0
                m_rocket = 0; % Mass cannot be negative
            end
        end
        
        % --- New Methods to Get Individual Force Components ---
        function Tm = momentumThrust(rocket)
            Tm = rocket.mDot() * (rocket.v_exit + rocket.velocity);
        end

        function Tp = pressureThrust(rocket)
            Tp = (rocket.P_exit - rocket.atmos.P) * rocket.no_nozzles * rocket.A_exit;
        end

        function D = drag(rocket)
            D = rocket.cd * (0.5 * rocket.atmos.rho * (rocket.velocity^2)) * rocket.A_projected; % Using rho_exhaust as air density
            if rocket.velocity < 0
                D = -D; % Drag opposes motion
            end
        end

        function W = weight(rocket)
            % Weight is calculated using mass_after_dt as per your original formulation
            mass_for_W = rocket.nextMass();
            W = mass_for_W * rocket.atmos.g;
        end

        % --- Method to Calculate Net External Force (LHS) ---
        % Now calls the new individual force getter methods
        function net_force_external = netForce(rocket)
            net_force_external = rocket.momentumThrust() - rocket.weight() - rocket.drag();
        end

        % --- NEW: Method to Calculate Net Force from Momentum Change (RHS of equation) ---
        function net_force_momentum_change = rateOfChangeOfMomentum(rocket)
            % This calculates the (dp/dt) term from your original equation.
            mass_for_rhs_calc = rocket.nextMass(); % Uses dt internally
            net_force_momentum_change = (1 / rocket.dt) * rocket.velocity * mass_for_rhs_calc;
        end

        % --- Method to Update Rocket's State for Simulation ---
        function updateState(rocket, dt_sim)
            % Updates the rocket's mass, velocity, altitude, and time
            % based on the current forces and a simulation time step (dt_sim).

            % 1. Get Net Force (LHS) for the current state
            rocket.F_net = rocket.netForce();

            % 2. Calculate instantaneous acceleration
            rocket.acceleration = rocket.F_net / rocket.mass;

            % 3. Get mass flow rate for mass update
            m_dot_gasses = rocket.mDot();

            % 4. Update Velocity (Explicit Euler Method)
            rocket.velocity = rocket.velocity + rocket.acceleration * rocket.dt;


            % 5. Update Altitude (using updated velocity for better accuracy)
            rocket.altitude = rocket.altitude + rocket.velocity * dt_sim;

            if rocket.altitude < 0
                rocket.altitude = 0;
            end

            % 6. Update Mass
            rocket.mass = rocket.mass - m_dot_gasses * dt_sim;
            rocket.fuel = rocket.fuel - m_dot_gasses * dt_sim;

            % 7. Update Time
            rocket.time = rocket.time + dt_sim;

            % 8. Update environmental conditions
            rocket.atmos = lookupAtmos(rocket.altitude);

            % Call the external function to solve for the initial velocity.
            % This function will modify rocket.velocity directly as RocketModel is a handle class.
            if rocket.time == 0
                rocket.velocity = solveRocket(rocket);
            end

        end

    end % methods

end % classdef
