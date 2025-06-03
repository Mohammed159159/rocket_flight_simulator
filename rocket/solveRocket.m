function optimal_v = solveRocket(rocket_obj_handle)
% solveRocket: Solves for the rocket_obj_handle velocity where LHS = RHS
%                of the rocket_obj_handle equation using fsolve.
%
% Inputs:
%   rocket_obj_handle : A handle to the Rocket object. Its properties
%                       will be used for calculations. Its velocity property
%                       will be temporarily modified by the objective function
%                       during the solve process.
%   initial_v_guess   : An initial guess for the velocity (m/s) for fsolve.
%
% Output:
%   optimal_v         : The velocity (m/s) at which the rocket_obj_handle equation is balanced.

fprintf('Solving for velocity after dt using fsolve...\n');

% Define the objective function for fsolve.
% This anonymous function calls a local helper function (defined below)
% to calculate the residual. This is clean and keeps the velocity
% management isolated.
fsolve_objective = @(v_test) local_residual_calculator(rocket_obj_handle, v_test);

% Call fsolve to find the optimal initial velocity
% Set options if you want to suppress fsolve's output for cleaner console
optimal_v = fsolve(fsolve_objective, rocket_obj_handle.velocity); % Pass initial guess and options

fprintf('Optimal velocity found by fsolve: %.15f m/s\n', optimal_v);

end % End of main solveRocket function


% --- Local Helper Function ---
% This function performs the residual calculation for fsolve.
% It's defined within the same solveRocket.m file but outside the main function.
function residual_val = local_residual_calculator(rocket_handle_for_solve, v_test)
    % Store the original velocity of the rocket object
    original_velocity = rocket_handle_for_solve.velocity;

    % Temporarily set the rocket's velocity to the value fsolve is currently testing
    rocket_handle_for_solve.velocity = v_test;

    % Calculate the residual: (LHS - RHS)
    % This is the equation fsolve tries to make zero.
    residual_val = rocket_handle_for_solve.netForce() - ...
                   rocket_handle_for_solve.rateOfChangeOfMomentum();

    % IMPORTANT: Restore the rocket's velocity to its original state.
    % This ensures that the 'rocket_handle_for_solve' object's velocity property
    % isn't left at some intermediate test value by fsolve's internal probing,
    % but is ready for the final optimal value to be assigned later.
    rocket_handle_for_solve.velocity = original_velocity;
end