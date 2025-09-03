% dopant_diffusion_advanced.m
% Advanced simulation of dopant diffusion in silicon (VLSI fabrication)
% Includes temperature variation + auto-saving of figures
% Author: <Your Name>
% Date: <Insert Date>

clc; clear; close all;

%% Parameters
C_s = 1e21;     % surface concentration [atoms/cm^3] (constant-source)
C_b = 1e15;     % background concentration [atoms/cm^3]
D0 = 10.5;      % diffusion prefactor [cm^2/s]
Ea = 3.69;      % activation energy [eV]
kB = 8.617e-5;  % Boltzmann const [eV/K]

temps = [900 1000 1100] + 273; % furnace temps in K
t_vec = [10 30 60 120]*60;     % diffusion times [s]
x = linspace(0,2e-4,500);      % depth [cm] (0–2 µm)

% Create results folder
if ~exist('results','dir')
    mkdir results
end

%% Loop over temperatures
for T = temps
    D = D0 * exp(-Ea/(kB*T)); % diffusion coefficient at this T
    
    % ---- Constant-source diffusion ----
    fig1 = figure('Color','w'); hold on; grid on;
    for t = t_vec
        C = C_s * erfc(x./(2*sqrt(D*t)));
        semilogy(x*1e4, C, 'DisplayName',sprintf('t=%.0f min',t/60));
    end
    yline(C_b,'--k','Background doping');
    xlabel('Depth x (\mum)'); ylabel('Concentration (atoms/cm^3)');
    title(sprintf('Constant-Source Diffusion @ %d °C',T-273));
    legend('Location','southwest');
    saveas(fig1, sprintf('results/constant_diffusion_%dC.png',T-273));
    
    % ---- Junction depth vs. time ----
    xj = sqrt(4*D*t_vec) .* erfcinv(C_b/C_s); % junction depth
    fig2 = figure('Color','w'); 
    plot(t_vec/60, xj*1e4,'o-','LineWidth',1.5);
    xlabel('Diffusion time (min)'); ylabel('Junction depth (\mum)');
    title(sprintf('Junction Depth vs. Time @ %d °C',T-273));
    grid on;
    saveas(fig2, sprintf('results/junction_depth_%dC.png',T-273));
    
    % ---- Limited-source diffusion ----
    Q = 1e14; % total dopant dose [atoms/cm^2]
    fig3 = figure('Color','w'); hold on; grid on;
    for t = t_vec
        C = (Q./sqrt(pi*D*t)) .* exp(-(x.^2)./(4*D*t));
        semilogy(x*1e4, C, 'DisplayName',sprintf('t=%.0f min',t/60));
    end
    xlabel('Depth x (\mum)'); ylabel('Concentration (atoms/cm^3)');
    title(sprintf('Limited-Source Diffusion @ %d °C',T-273));
    legend('Location','southwest');
    saveas(fig3, sprintf('results/limited_diffusion_%dC.png',T-273));
end

disp(' All simulations complete. Figures saved in /results folder.');
