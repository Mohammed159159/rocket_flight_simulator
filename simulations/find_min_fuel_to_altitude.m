clear; clc; close all;

f9_mini = rockets('Falcon 9 Nano');

while 1
    f9_mini_rocket = Rocket(f9_mini);
    sim = SimulateRocket(f9_mini_rocket, 300, 9, 0.1);

    sim.runSimulation();
    
    if sim.rocket.velocity <= 0
        break;
    end
    f9_mini.fuel = f9_mini.fuel - 1000;   
    f9_mini.mass = f9_mini.mass - 1000;


end

sim.displayResults();
sim.plotResults();