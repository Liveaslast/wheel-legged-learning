function cfg = set_state_ref()
% Original Damiao reference profile, in m/s and m.
cfg.stopTime = 10;
cfg.showAnimation = false; % true opens Mechanics Explorer automatically.
cfg.L_v_ref = timeseries([0; -1; 0], [0; 2; 5]);
cfg.R_v_ref = cfg.L_v_ref;
cfg.L_length_ref = timeseries([0.08; 0.08], [0; cfg.stopTime]);
cfg.R_length_ref = cfg.L_length_ref;
end
