function parameters = config_solver_parameters(cfg)
% 检查三项必填精度参数，并转换为模型参数名称和值。
fields = {'relTol','absTol','maxStep'};
modelNames = {'RelTol','AbsTol','MaxStep'};
parameters = cell(1, 6);
for i = 1:numel(fields)
    field = fields{i};
    value = cfg.(field);
    validateattributes(value, {'numeric'}, ...
        {'scalar','real','finite','positive'}, mfilename, ['cfg.' field]);
    parameters(2*i-1:2*i) = {modelNames{i}, num2str(value, 17)};
end
end
