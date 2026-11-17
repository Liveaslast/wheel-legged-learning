function [Z_rel_Dot, valid] = wheel_relative_vertical_rate( ...
    phi1, phi4, d_phi1, d_phi4, theta, d_theta)
% 单轮轮心相对虚拟髋轴中点的竖直速度，世界 Z 向上为正。
% phi1、phi4 和对应角速度沿用现有 VMC 的角度约定。
% theta、d_theta 是虚拟腿相对竖直的角度和角速度，取同侧 LQR 的输入。
% 角度和角速度用 rad、rad/s，输出用 m/s。沿用 RM 的平面投影。
% 构型无效时速度输出为零，同时置 valid 为 false。

Z_rel_Dot = 0;
valid = false;
if ~all(isfinite([d_phi1 d_phi4 theta d_theta]))
    return
end
[L0, J, geometry_valid] = five_bar_geometry_rm(phi1, phi4);
if ~geometry_valid
    return
end

d_L0 = J(1,1)*d_phi1 + J(2,1)*d_phi4;
Z_rel_Dot = -d_L0*cos(theta) + L0*d_theta*sin(theta);
valid = isfinite(Z_rel_Dot);
if ~valid
    Z_rel_Dot = 0;
end
end
