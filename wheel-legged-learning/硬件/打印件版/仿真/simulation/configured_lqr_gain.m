function K = configured_lqr_gain(cfg)
% 权重、标称腿长或设计函数变化时重新计算反馈矩阵，其余情况复用缓存。
validateattributes(cfg.lqrLegLength, {'numeric'}, {'scalar','real','finite','positive'});
validateattributes(cfg.lqrQ, {'numeric'}, {'vector','numel',6,'real','finite','positive'});
validateattributes(cfg.lqrR, {'numeric'}, {'vector','numel',2,'real','finite','positive'});
persistent cachedKey cachedStamp cachedK
key=[cfg.lqrLegLength, cfg.lqrQ(:).', cfg.lqrR(:).'];
source=dir(which('get_k_length'));
stamp=[source.datenum source.bytes];
if isempty(cachedK) || ~isequal(key,cachedKey) || ~isequal(stamp,cachedStamp)
    cachedK=get_k_length(cfg.lqrLegLength,cfg.lqrQ,cfg.lqrR);
    cachedKey=key; cachedStamp=stamp;
end
K=cachedK;
end
