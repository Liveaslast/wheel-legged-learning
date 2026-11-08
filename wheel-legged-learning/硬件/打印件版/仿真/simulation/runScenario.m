function out = runScenario(cfg, model)
% 新旧模型统一运行入口。旧配置没有 model 字段时仍运行原版。
% runScenario(cfg) 使用 cfg.model；runScenario(cfg,'blance_leg2_RPY') 临时选择新版。
if nargin < 1 || isempty(cfg)
    cfg = set_config();
end
validateattributes(cfg, {'struct'}, {'scalar'}, mfilename, 'cfg');
if nargin < 2 || isempty(model)
    if isfield(cfg, 'model')
        model = cfg.model;
    else
        model = 'blance_leg2';
    end
end
model = validatestring(model, {'blance_leg2','blance_leg2_RPY'}, mfilename, 'model');
folder = fileparts(mfilename('fullpath'));
load_system(fullfile(folder, [model '.slx']));
% 初始化回调不能直接从模型工作区读到仿真输入对象中的临时覆盖值。
% 因此在运行期间显式保存本次配置，结束或异常退出时恢复原值。
mw = get_param(model, 'ModelWorkspace');
overrideName = 'runScenario_cfg_override';
previousOverride = [];
if mw.hasVariable(overrideName)
    previousOverride = mw.getVariable(overrideName);
end
assignin(mw, overrideName, cfg);
restoreOverride = onCleanup(@() assignin(mw, overrideName, previousOverride)); %#ok<NASGU>
% 配置校验与应用只维护在 apply_config 中，初始化回调也使用同一份 cfg。
apply_config(model, cfg);
in = Simulink.SimulationInput(model);
in = in.setModelParameter('ReturnWorkspaceOutputs','on');
out = sim(in);
end

