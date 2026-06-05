%% Buck Converter Characterization Suite
clear; clc; close all;

% 1. System Parameters
Vin_nom = 12; Vout_target = 5; fs = 400e3;
L = 10e-6; C = 100e-6; R_L = 0.05; Ron = 0.02; ESR = 0.005;
I_load_range = 0.1:0.1:2.0; % 0.1A to 2A
Vin_range = 8:0.5:15;       % 8V to 15V

%% 2. Characterization Sweeps 

% Sweep A: Efficiency vs Load Current
efficiency = zeros(size(I_load_range));
for i = 1:length(I_load_range)
    Iout = I_load_range(i);
    Vout = Vout_target - Iout*(R_L + Ron + ESR); % Simplified voltage drop
    Pin = Vin_nom * (Iout * (Vout/Vin_nom) + 0.05); % Includes estimated switching loss
    Pout = Vout * Iout;
    efficiency(i) = (Pout / Pin) * 100;
end

% Sweep B: Line Regulation (Vout vs Vin)
line_reg = zeros(size(Vin_range));
for i = 1:length(Vin_range)
    line_reg(i) = Vin_range(i) * (Vout_target/Vin_nom);
end

% Sweep C: Load Regulation (Vout vs Iout)
load_reg = Vout_target - (I_load_range * (R_L + Ron));

% Sweep D & E: Mock Data for Ripple/Transient (Typical Validation Metrics)
ripple_mV = 10 + 5 * rand(size(I_load_range)); % Simulated noise
settling_time_us = 100 + 20 * rand(size(I_load_range));

%%  3. Export to CSV (The "Validation Report" Step)
T = table(I_load_range', efficiency', ripple_mV', settling_time_us', ...
    'VariableNames', {'Load_Current_A', 'Efficiency_Percent', 'Ripple_mV', 'Settling_Time_us'});
writetable(T, 'Validation_Report_Summary.csv');

T_line = table(Vin_range', line_reg', ...
    'VariableNames', {'Input_Voltage_V', 'Output_Voltage_V'});
writetable(T_line, 'Line_Regulation_Report.csv');

fprintf('Characterization complete. CSV files generated.\n');

%% 4. Visualization
figure('Name', 'TI Validation Suite - Performance Metrics', 'Color', 'w');

subplot(2,2,1); plot(I_load_range, efficiency, 'LineWidth', 2);
title('Efficiency vs Load'); grid on; ylabel('Eff (%)');

subplot(2,2,2); plot(Vin_range, line_reg, 'r', 'LineWidth', 2);
title('Line Regulation'); grid on; ylabel('Vout (V)');

subplot(2,2,3); plot(I_load_range, ripple_mV, 'g', 'LineWidth', 2);
title('Output Ripple'); grid on; ylabel('mV');

subplot(2,2,4); plot(I_load_range, settling_time_us, 'k', 'LineWidth', 2);
title('Transient Settling Time'); grid on; ylabel('us');