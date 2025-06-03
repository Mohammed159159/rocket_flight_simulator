clear; clc; close all;

f9_mini = rockets('Falcon 9 Optimum');

while 1
    f9_mini_rocket = Rocket(f9_mini);
    sim = SimulateRocket(f9_mini_rocket, 300, 9, 0.1);

    sim.runSimulation();

    if sim.rocket.velocity > 7910.0050568884
        f9_mini.fuel = f9_mini.fuel - 1000;
        f9_mini.mass = f9_mini.fuel + 20000;
    end

    if sim.rocket.velocity < 7910.0050568884
        f9_mini.fuel = f9_mini.fuel + 1000;
        f9_mini.mass = f9_mini.fuel + 20000;
    end
    if abs(sim.rocket.velocity - 7910.0050568884) <= 100
        break;  
    end

end

sim.displayResults();
sim.plotResults();