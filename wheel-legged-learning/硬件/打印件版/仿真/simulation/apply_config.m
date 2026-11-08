function cfg = apply_config(model, cfg)
% 模型初始化时应用配置，模型运行按钮和脚本仿真共用此入口。
% apply_config(model, cfg) 显式应用配置；省略 cfg 时读取本次运行覆盖值或 set_config。
if nargin < 1 || isempty(model)
    model = bdroot;
end
assert(~isempty(model), '请先打开模型，或显式传入模型名称。');
mw = get_param(model, 'ModelWorkspace');
overrideName = 'runScenario_cfg_override';
if nargin < 2
    if mw.hasVariable(overrideName)
        cfg = mw.getVariable(overrideName);
    else
        cfg = [];
    end
end
% 脚本运行使用临时配置；直接点击模型运行时读取配置文件。
if isempty(cfg)
    cfg = set_config();
end
validateattributes(cfg, {'struct'}, {'scalar'}, mfilename, 'cfg');
validateattributes(cfg.stopTime, {'numeric'}, {'scalar','finite','positive'});
validateattributes(cfg.showAnimation, {'logical'}, {'scalar'});
validateattributes(cfg.compensateWheelSpeed, {'logical'}, {'scalar'});
names = {'L_v_ref','R_v_ref','L_length_ref','R_length_ref'};
for i = 1:numel(names)
    name = names{i};
    ts = cfg.(name);
    validateattributes(ts, {'timeseries'}, {'scalar'}, mfilename, name);
    validateattributes(ts.Data, {'numeric'}, {'vector','nonempty','finite','real'});
    validateattributes(ts.Time, {'numeric'}, {'vector','nonempty','finite','real'});
    assert(numel(ts.Data) == numel(ts.Time) && ts.Time(1) == 0 ...
        && all(diff(ts.Time) > 0), '参考信号时间序列无效：%s', name);
end
solverParameters = config_solver_parameters(cfg);
configuredGain = configured_lqr_gain(cfg);
% 所有配置检查通过后，再写入模型工作区并刷新反馈矩阵。
for i = 1:numel(names)
    assignin(mw, names{i}, cfg.(names{i}));
end
assignin(mw, 'wheel_speed_compensation', double(cfg.compensateWheelSpeed));
set_param(model, 'StopTime', num2str(cfg.stopTime, 17), solverParameters{:});
animationOptions = {'off','on'};
set_param(model, 'SimMechanicsOpenEditorOnUpdate', ...
    animationOptions{1 + cfg.showAnimation});
assignin('base', 'K', configuredGain);
end
