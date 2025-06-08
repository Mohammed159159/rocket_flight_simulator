function optimal_v = solveRocket(rocket_obj, dt)
% solveRocket: Solves for the rocket_obj velocity where LHS = RHS
%                of the rocket_obj equation using fsolve.
%
% Inputs:
%   rocket_obj : A value class to the Rocket object. Its properties
%                       will be used for calculations. Its velocity property
%                       will be temporarily modified by the objective function
%                       during the solve process.
%   initial_v_guess   : An initial guess for the velocity (m/s) for fsolve.
%   dt                : A time step value after which the velocity is calculated.
%
% Output:
%   optimal_v         : The velocity (m/s) at which the rocket_obj equation is balanced.

fprintf('Solving for velocity after dt=%.2f using fsolve...\n', dt);

% Define the objective function for fsolve.
% This anonymous function calls a local helper function (defined below)
% to calculate the residual. This is clean and keeps the velocity
% management isolated.
fsolve_objective = @(v_test) local_residual_calculator(rocket_obj, v_test, dt);

% Call fsolve to find the optimal initial velocity
% Set options if you want to suppress fsolve's output for cleaner console
optimal_v = fsolve(fsolve_objective, rocket_obj.velocity); % Pass initial guess and options

fprintf('Optimal velocity found by fsolve: %.17f m/s\n', optimal_v);

end % End of main solveRocket function


% --- Local Helper Function ---
% This function performs the residual calculation for fsolve.
function residual_val = local_residual_calculator(rocket_obj_for_solve, v_test, dt)
% Temporarily set the rocket's velocity to the value fsolve is currently testing

v_o = rocket_obj_for_solve.velocity;


rocket_obj_for_solve.velocity = v_test;

% Calculate the residual: (LHS - RHS)
% This is the equation fsolve tries to make zero.
residual_val = rocket_obj_for_solve.F_net - ...
    rocket_obj_for_solve.rateOfChangeOfMomentum(v_o, dt);
    
% IMPORTANT: Restore the rocket's velocity to its original state.
% This ensures that the 'rocket_obj_for_solve' object's velocity property
% isn't left at some intermediate test value by fsolve's internal probing,
% but is ready for the final optimal value to be assigned later.

end