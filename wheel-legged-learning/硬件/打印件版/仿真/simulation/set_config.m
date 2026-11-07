function cfg = set_config()
% Save edits, then click Run in blance_leg2.slx: InitFcn reloads this file.
cfg.stopTime = 10;
cfg.showAnimation = true; % true opens Mechanics Explorer automatically.
% Solver accuracy: applies to both the SLX Run button and runScenario.
cfg.relTol = 5e-5;  % Balanced setting tested with the 10 s flat-ground profile.
cfg.absTol = 1e-6;  % Absolute tolerance.
cfg.maxStep = 5e-3; % Maximum solver step in seconds, not a fixed step.
% Strict cross-check: relTol=1e-5, absTol=1e-7, maxStep=1e-4.
% Reference profiles, in m/s and m.
cfg.L_v_ref = timeseries([0; 1; 0], [0; 2; 5]);
cfg.R_v_ref = cfg.L_v_ref;
cfg.L_length_ref = timeseries([0.08; 0.08], [0; cfg.stopTime]);
cfg.R_length_ref = cfg.L_length_ref;
end
