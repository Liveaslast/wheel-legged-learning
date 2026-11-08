function cfg = set_config()
% 新旧模型共用本配置；点击任一模型的运行按钮时会重新读取本文件。
% 仅决定 runScenario(cfg) 默认运行哪个模型，不切换当前点击运行的模型。
cfg.model = 'blance_leg2'; % 新版：'blance_leg2_RPY'。
cfg.stopTime = 10;
cfg.showAnimation = true; % true 时自动打开机构浏览器。
% 求解精度：同时应用于 SLX 运行按钮和 runScenario。
cfg.relTol = 5e-5;  % 已通过 10 秒平地工况验证的折中设置。
cfg.absTol = 1e-6;  % 绝对容差。
cfg.maxStep = 5e-3; % 求解器最大步长，单位为秒，并非固定步长。
% 严格复核设置：relTol=1e-5、absTol=1e-7、maxStep=1e-4。
% 编码器转速转换为轮子对地转速：补偿实际连杆 BC 和机身的转动。
cfg.compensateWheelSpeed = true;
% LQR 状态：[theta theta_dot x x_dot phi phi_dot]；控制量：[T Tp]。
% 已通过 2 秒和 5 秒的硬阶跃验证；参考信号未作平滑。
cfg.lqrLegLength = 0.08;
cfg.lqrQ = [20 0.2 0.03 5 300 0.6];
cfg.lqrR = [100 10];
% 较小的位置权重会使位置纠偏变慢，也需检查 x。
% 参考信号，速度单位为 m/s，腿长单位为 m。
cfg.L_v_ref = timeseries([0; 2; 0], [0; 2; 5]);
cfg.R_v_ref = cfg.L_v_ref;
cfg.L_length_ref = timeseries([0.08; 0.08], [0; cfg.stopTime]);
cfg.R_length_ref = cfg.L_length_ref;
end
