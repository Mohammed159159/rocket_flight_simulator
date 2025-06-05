clear; clc; close all;

f9_optimum = rockets('Falcon 9 Optimum');

while 1
    f9_optimum_rocket = Rocket(f9_optimum);
    sim = SimulateRocket(f9_optimum_rocket, 300, 9, 0.1);

    sim.runSimulation();

    if sim.rocket.velocity > 7910.0050568884
        f9_optimum.fuel = f9_optimum.fuel - 1000;
        f9_optimum.mass = f9_optimum.fuel + 20000;
    end

    if sim.rocket.velocity < 7910.0050568884
        f9_optimum.fuel = f9_optimum.fuel + 1000;
        f9_optimum.mass = f9_optimum.fuel + 20000;
    end
    if abs(sim.rocket.velocity - 7910.0050568884) <= 100
        break;  
    end

end

sim.displayResults();
sim.plotResults();