clear; clc; close all;

rocket_params = rockets('Falcon 9 Mini Heavy');

while 1
    falcon_9_mini_heavy = Rocket(rocket_params);
    sim = SimulateRocket(falcon_9_mini_heavy, 300, 9, 0.1);

    sim.runSimulation();
    
    if sim.rocket.velocity <= 0
        break;
    end
    rocket_params.mass = rocket_params.mass + 1000;   

end

sim.displayResults();
sim.plotResults();