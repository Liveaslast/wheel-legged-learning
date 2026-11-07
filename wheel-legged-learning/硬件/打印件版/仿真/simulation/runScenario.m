function out = runScenario(cfg)
% Run the same plant and controller with four independent reference signals.
if nargin == 0
    cfg = set_config();
end
folder = fileparts(mfilename('fullpath'));
model = 'blance_leg2';
load_system(fullfile(folder, [model '.slx']));
in = Simulink.SimulationInput(model);
solverParameters = state_ref_solver_parameters(cfg);
if ~isempty(solverParameters)
    in = in.setModelParameter(solverParameters{:});
end
if ~evalin('base', 'exist(''K'', ''var'')')
    in = in.setVariable('K', get_k_length(0.08));
end
names = {'L_v_ref','R_v_ref','L_length_ref','R_length_ref'};
for i = 1:numel(names)
    name = names{i};
    ts = cfg.(name);
    validateattributes(ts, {'timeseries'}, {'scalar'}, mfilename, name);
    validateattributes(ts.Data, {'numeric'}, {'vector','finite','real'});
    assert(numel(ts.Data) == numel(ts.Time) && ts.Time(1) == 0 ...
        && all(diff(ts.Time) > 0), 'Invalid time series: %s', name);
    in = in.setVariable(name, ts, 'Workspace', model);
end
validateattributes(cfg.stopTime, {'numeric'}, {'scalar','finite','positive'});
in = in.setModelParameter('StopTime', num2str(cfg.stopTime), ...
    'ReturnWorkspaceOutputs','on');
if isfield(cfg, 'showAnimation')
    validateattributes(cfg.showAnimation, {'logical'}, {'scalar'});
    animationOptions = {'off', 'on'};
    in = in.setModelParameter('SimMechanicsOpenEditorOnUpdate', ...
        animationOptions{1 + cfg.showAnimation});
end
% InitFcn cannot read SimulationInput overrides through ModelWorkspace.getVariable.
% Keep its explicit configuration visible during sim, then restore it even on error.
mw = get_param(model, 'ModelWorkspace');
overrideName = 'runScenario_cfg_override';
previousOverride = [];
if mw.hasVariable(overrideName)
    previousOverride = mw.getVariable(overrideName);
end
assignin(mw, overrideName, cfg);
restoreOverride = onCleanup(@() assignin(mw, overrideName, previousOverride)); %#ok<NASGU>
out = sim(in);
end

