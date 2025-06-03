clear; clc; close all;

f9 = rockets('Falcon 9 Optimum');

while 1
    f9_rocket = Rocket(f9);
    sim = SimulateRocket(f9_rocket, 300, 9, 0.1);

    sim.runSimulation();

    if sim.rocket.velocity > 7910.0050568884
        f9.fuel = f9.fuel - 1000;
        f9.mass = f9.mass - 1000;
    end

    if sim.rocket.velocity < 7910.0050568884
        f9.fuel = f9.fuel + 1000;
        f9.mass = f9.mass + 1000;
    end
    if abs(sim.rocket.velocity - 7910.0050568884) <= 100
        break;  
    end

end

sim.plotResults();