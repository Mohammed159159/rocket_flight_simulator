clear; clc; close all;

f9 = rockets('Falcon 9 Optimum');

f9_rocket = Rocket(f9);

f9_sim = SimulateRocket(f9_rocket, 300, 9, 0.1);

f9_sim.runSimulation();


f9_sim.displayResults();
f9_sim.plotResults();