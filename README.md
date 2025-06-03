# Rocket Flight Simulator

A comprehensive MATLAB/Octave-based simulation framework for modeling and visualizing rocket flight trajectories. This simulator allows users to define custom rocket parameters, simulate their flight through a realistic atmospheric model, and visualize key performance metrics over time.

## ✨ Features

* **Configurable Rocket Models:** Easily define and select different rocket configurations (mass, thrust, drag, nozzle parameters) from a central catalog.
* **Realistic Atmospheric Model:** Utilizes a pre-computed atmospheric lookup table for accurate interpolation of air density, pressure, temperature, and gravity based on altitude. This ensures fast and consistent atmospheric data access.
* **Physics-Based Simulation:** Implements core rocket dynamics, including thrust, drag, weight, and mass flow rate, to simulate acceleration, velocity, altitude, and mass changes over time.
* **Numerical Solver Integration:** Uses `fsolve` to accurately determine optimal initial velocities or solve for specific force balance conditions.
* **Modular Design:** Organized into distinct classes and functions for easy understanding, maintenance, and extension (e.g., `Rocket` class for the vehicle, `SimulateRocket` for the simulation loop, separate functions for atmospheric data).
* **Automated Plotting:** Generates clear visualizations of key flight parameters (altitude, velocity, acceleration, mass, forces) against time for post-simulation analysis.
* **Efficient Data Handling:** Employs `persistent` variables in atmospheric functions to load large lookup tables from disk only once per session, significantly boosting simulation speed.

## 🚀 Getting Started

These instructions will get you a copy of the project up and running on your local machine.

### Prerequisites

* **MATLAB** (R2018a or newer recommended) OR **GNU Octave** (version 5.1.0 or newer recommended).

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/Mohammed159159/rocket_flight_simulator.git](https://github.com/Mohammed159159/rocket_flight_simulator.git)
    cd rocket_flight_simulator
    ```

2.  **Add project to MATLAB/Octave Path:**
    Open MATLAB/Octave, navigate to the `rocket_flight_simulator` directory, and add it (and its subfolders, if any are added later) to your path:
    ```matlab
    addpath(genpath(pwd)); % Adds current directory and all subfolders to path
    ```

3.  **Generate Atmosphere Lookup Table:**
    The simulator relies on a pre-computed atmospheric data table for performance. You need to generate this once.
    ```matlab
    generateAtmosphereLookupTable;
    ```
    This will create a file named `atmosphere_lookup_table.mat` in your project root.

### Running a Simulation

1.  Open the `run_my_rocket_sim.m` script in your MATLAB/Octave editor.
2.  Review the `rockets_to_simulate` cell array to choose which rocket models you want to run.
3.  Execute the script:
    ```matlab
    run_my_rocket_sim;
    ```
    The script will loop through the selected rockets, run their simulations, and display plots for each.

## 📁 Project Structure

Here's a brief overview of the key files in the repository:

* `generateAtmosphereLookupTable.m`: Script to create the `atmosphere_lookup_table.mat` file.
* `atmosphere_lookup_table.mat`: (Generated file) Contains pre-computed atmospheric data for efficient lookups.
* `rockets.m`: Function returning a struct catalog of all predefined rocket models and their parameters.
* `Rocket.m`: Class defining the rocket's physical properties, current state, and physics-based calculations (thrust, drag, weight).
* `SimulateRocket.m`: Class responsible for managing a single simulation run, integrating the rocket's state over time, and recording simulation history.
* `loadAtmosphereLookupTable.m`: Helper function that loads the `atmosphere_lookup_table.mat` into a persistent variable, ensuring it's loaded only once per session.
* `getAtmosphericConditions.m`: Function that uses the loaded atmosphere table to provide interpolated atmospheric properties at a given altitude.
* `solveRocket.m`: Utility function that uses `fsolve` to find a specific velocity where the rocket's force equation is balanced.
* `run_my_rocket_sim.m`: The main script to configure and execute rocket simulations.
* `StandardAtmos.m`: (Legacy/Utility) May be used for generating the lookup table, or as a reference standard atmosphere model.

## 🚀 Rocket Models

The `rockets.m` function acts as your rocket model catalog.
You can access specific rocket parameters like this:
```matlab
all_models = rockets();
falcon9_params = all_models.Falcon9;
falcon9_mini_params = all_models.Falcon9Mini;
% ... and so on