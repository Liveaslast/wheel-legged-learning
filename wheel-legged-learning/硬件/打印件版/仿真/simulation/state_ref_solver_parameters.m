function parameters = state_ref_solver_parameters(cfg)
% Validate shared solver settings for model callbacks and scripted runs.
% Missing fields preserve the model settings for older configurations.
fields = {'relTol','absTol','maxStep'};
modelNames = {'RelTol','AbsTol','MaxStep'};
parameters = {};
for i = 1:numel(fields)
    field = fields{i};
    if isfield(cfg, field)
        value = cfg.(field);
        validateattributes(value, {'numeric'}, ...
            {'scalar','real','finite','positive'}, mfilename, ['cfg.' field]);
        parameters(end+1:end+2) = {modelNames{i}, num2str(value, 17)}; %#ok<AGROW>
    end
end
end
