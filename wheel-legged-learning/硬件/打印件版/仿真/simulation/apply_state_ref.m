function cfg = apply_state_ref(model)
% Refresh references before every model initialization (including the Run button).
% runScenario supplies a temporary override through SimulationInput; otherwise
% set_config.m is the source of the model's references and run settings.
if nargin == 0
    model = bdroot;
end
mw = get_param(model, 'ModelWorkspace');
overrideName = 'runScenario_cfg_override';
if mw.hasVariable(overrideName)
    cfg = mw.getVariable(overrideName);
else
    cfg = [];
end
if isempty(cfg)
    cfg = set_config();
end
validateattributes(cfg, {'struct'}, {'scalar'}, mfilename, 'cfg');
validateattributes(cfg.stopTime, {'numeric'}, {'scalar','finite','positive'}, ...
    mfilename, 'cfg.stopTime');
names = {'L_v_ref','R_v_ref','L_length_ref','R_length_ref'};
for i = 1:numel(names)
    name = names{i};
    ts = cfg.(name);
    validateattributes(ts, {'timeseries'}, {'scalar'}, mfilename, name);
    validateattributes(ts.Data, {'numeric'}, {'vector','finite','real'});
    validateattributes(ts.Time, {'numeric'}, {'vector','finite','real'});
    assert(numel(ts.Data) == numel(ts.Time) && ts.Time(1) == 0 ...
        && all(diff(ts.Time) > 0), 'Invalid time series: %s', name);
end
if isfield(cfg, 'showAnimation')
    validateattributes(cfg.showAnimation, {'logical'}, {'scalar'});
end
% Only write after validating the complete configuration.
solverParameters = state_ref_solver_parameters(cfg);
for i = 1:numel(names)
    name = names{i};
    assignin(mw, name, cfg.(name));
end
set_param(model, 'StopTime', num2str(cfg.stopTime, 17));
if ~isempty(solverParameters)
    set_param(model, solverParameters{:});
end
if isfield(cfg, 'showAnimation')
    animationOptions = {'off','on'};
    set_param(model, 'SimMechanicsOpenEditorOnUpdate', ...
        animationOptions{1 + cfg.showAnimation});
end
if ~evalin('base', 'exist(''K'', ''var'')')
    assignin('base', 'K', get_k_length(0.08));
end
end
