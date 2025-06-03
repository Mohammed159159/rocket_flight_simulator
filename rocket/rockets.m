% In your new file, e.g., rockets.m

function rocket = rockets(modelName)
% This function will return a struct of parameters for a specified rocket model.
% The 'modelName' input will be a string like 'StandardRocket' or 'HeavyLifter'.

% Initialize an empty struct for parameters
rocket = struct();

% Use a switch statement to define different rocket models
switch modelName
    case 'Falcon 9 Optimum'
        % Define all the FIXED parameters for your 'StandardRocket' here
        % These are the parameters that describe the physical design of the rocket,
        % which are currently hardcoded in your RocketModel constructor.
        rocket.name = 'Falcon 9 Optimum';
        rocket.mass = 106000.00; % Example: 100,000 kg for this model %59177
        rocket.fuel = rocket.mass - 20000;
        rocket.no_nozzles = 3;
        rocket.cd = 0.75;
        rocket.rho_exhaust = 0.174657713540341;
        rocket.A_projected = 10.75210086;
        rocket.A_exit = 0.66472;
        rocket.v_exit = 2697.75;
        rocket.P_exit = 101325;
    case 'Falcon 9 Fast'
        % Define all the FIXED parameters for your 'StandardRocket' here
        % These are the parameters that describe the physical design of the rocket,
        % which are currently hardcoded in your RocketModel constructor.
        rocket.name = 'Falcon 9 Fast'; % Fastest rocket to reach destination
        rocket.mass = 37330.00; % Example: 100,000 kg for this model
        rocket.fuel = 0.8982051969 * rocket.mass;
        rocket.no_nozzles = 3;
        rocket.cd = 0.75;
        rocket.rho_exhaust = 0.174657713540341;
        rocket.A_projected = 10.75210086;
        rocket.A_exit = 0.66472;
        rocket.v_exit = 2697.75;
        rocket.P_exit = 101325;
    case 'Falcon 9'
        % Define all the FIXED parameters for your 'StandardRocket' here
        % These are the parameters that describe the physical design of the rocket,
        % which are currently hardcoded in your RocketModel constructor.
        rocket.name = 'Falcon 9';
        rocket.mass = 549054; % Example: 100,000 kg for this model
        rocket.fuel = 0.9 * rocket.mass;
        rocket.no_nozzles = 9;
        rocket.cd = 0.75;
        rocket.rho_exhaust = 0.174657713540341;
        rocket.A_projected = 10.75210086;
        rocket.A_exit = 0.66472;
        rocket.v_exit = 2697.75;
        rocket.P_exit = 101325;

    case 'Falcon 9 Mini Heavy'
        % Define all the FIXED parameters for your 'StandardRocket' here
        % These are the parameters that describe the physical design of the rocket,
        % which are currently hardcoded in your RocketModel constructor.
        rocket.name = 'Falcon 9 Mini Heavy';
        rocket.mass = 258000.00; % Example: 100,000 kg for this model
        rocket.no_nozzles = 3;
        rocket.fuel = 0.7604651163 * rocket.mass;
        rocket.cd = 0.75;
        rocket.rho_exhaust = 0.174657713540341;
        rocket.A_projected = 10.75210086;
        rocket.A_exit = 0.66472;
        rocket.v_exit = 2697.75;
        rocket.P_exit = 101325;

    case 'Falcon 9 Nano' % Minimum fuel to deliver payload
        % Define all the FIXED parameters for your 'StandardRocket' here
        % These are the parameters that describe the physical design of the rocket,
        % which are currently hardcoded in your RocketModel constructor.
        rocket.name = 'Falcon 9 Nano';
        rocket.mass = 38000.00; % Example: 100,000 kg for this model
        rocket.fuel = 0.7368421053 * rocket.mass;
        rocket.no_nozzles = 3;
        rocket.cd = 0.75;
        rocket.rho_exhaust = 0.174657713540341;
        rocket.A_projected = 10.75210086;
        rocket.A_exit = 0.66472;
        rocket.v_exit = 2697.75;
        rocket.P_exit = 101325;
    case 'Falcon 9 Default' % Minimum fuel to deliver payload
        % Define all the FIXED parameters for your 'StandardRocket' here
        % These are the parameters that describe the physical design of the rocket,
        % which are currently hardcoded in your RocketModel constructor.
        rocket.name = 'Falcon 9 Default';
        rocket.mass = 100000.00; % Example: 100,000 kg for this model
        rocket.fuel = 0.9 * rocket.mass;
        rocket.no_nozzles = 3;
        rocket.cd = 0.75;
        rocket.rho_exhaust = 0.174657713540341;
        rocket.A_projected = 10.75210086;
        rocket.A_exit = 0.66472;
        rocket.v_exit = 2697.75;
        rocket.P_exit = 101325;

    otherwise
        % Handle cases where an unknown model name is requested
        error('rockets:UnknownModel', 'Unknown rocket model name: %s', modelName);
end

end