function [F_N, valid, P] = estimate_support_force_rm(phi1, phi4, T1, T2, theta, varargin)
% RM 支持力估算，单侧机加工五连杆。坐标约定与模型中的 VMC 一致。
% 新接法：estimate_support_force_rm(phi1,phi4,T1,T2,theta,Z_M_Ddot,Z_rel_Ddot)
% 原接法：estimate_support_force_rm(phi1,phi4,T1,T2,theta,d_theta,dd_theta,d_L0,dd_L0,Z_M_Ddot)
% 角度用 rad，力矩用 N·m，加速度用 m/s^2，世界 Z 轴朝上。
% Z_M_Ddot 是虚拟髋轴中点的竖直运动加速度，静止为零，自由落体为 -g。
% Z_rel_Ddot 是轮心相对髋的竖直加速度，向上为正。
% T1 和 T2 分别是 J1、J4 的驱动力矩，符号与 control 的输出一致。
% F_N 保留原始正负值。估算无效时，valid 为 false，数值输出为 NaN。

% P 是腿对轮子的向下竖直传力估算，可用于对齐力与加速度的时间窗。
F_N = NaN;
P = NaN;
valid = false;
if ~all(isfinite([T1 T2 theta]))
    return
end

[L0,J,geometry_valid] = five_bar_geometry_rm(phi1,phi4);
if ~geometry_valid
    return
end

ct = cos(theta);
st = sin(theta);
if nargin == 7
    Z_M_Ddot = varargin{1};
    Z_rel_Ddot = varargin{2};
    Z_w_Ddot = Z_M_Ddot + Z_rel_Ddot;
elseif nargin == 10
    d_theta = varargin{1};
    dd_theta = varargin{2};
    d_L0 = varargin{3};
    dd_L0 = varargin{4};
    Z_M_Ddot = varargin{5};
    % 原接法由 z_w = z_M - L0*cos(theta) 展开得到轮心加速度。
    Z_w_Ddot = Z_M_Ddot - dd_L0*ct + 2*d_L0*d_theta*st ...
        + L0*dd_theta*st + L0*d_theta^2*ct;
else
    return
end
if ~isfinite(Z_w_Ddot)
    return
end

% 原 VMC 正向映射为 [T1; T2] = J * [F0; Tp]。
j11 = J(1,1); j12 = J(1,2);
j21 = J(2,1); j22 = J(2,2);
detJ = j11*j22 - j12*j21;
% 用腿长归一化力这一列，再检查矩阵是否接近奇异。
scale = (j11/L0)^2 + j12^2 + (j21/L0)^2 + j22^2;
if abs(detJ/L0) <= 1e-4*scale
    return
end
F0 = (j22*T1 - j12*T2)/detJ;
Tp = (j11*T2 - j21*T1)/detJ;

m_w = 0.60;
g = 9.80665;
P = F0*ct + Tp*st/L0;
F_N = P + m_w*(g + Z_w_Ddot);
valid = true;
end
