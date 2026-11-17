function [Z_M_Ddot_avg, Z_rel_Ddot_L, Z_rel_Ddot_R, valid_L, valid_R] = ...
    wheel_vertical_acceleration(Z_M_Ddot, Z_rel_Dot_L, Z_rel_Dot_R, valid_speed_L, valid_speed_R)
% 单个模块同时计算两轮，以 1 ms 固定采样执行。
% 机身加速度取最近 2 ms 的梯形平均；相对加速度用同一窗口的速度差计算。
% 两项相加得到轮心在该窗口内的平均竖直加速度，向上为正，单位 m/s^2。
% 首次获得完整窗口前，或窗口内有无效数据时，相应的有效标志为假。

persistent body_history body_valid_history speed_history speed_valid_history
if isempty(body_history)
    body_history = zeros(2,1);
    body_valid_history = false(2,1);
    speed_history = zeros(2,2);
    speed_valid_history = false(2,2);
end

body_valid = isfinite(Z_M_Ddot);
speed = [Z_rel_Dot_L, Z_rel_Dot_R];
speed_valid = [valid_speed_L && isfinite(Z_rel_Dot_L), ...
               valid_speed_R && isfinite(Z_rel_Dot_R)];
body_window_valid = body_valid && all(body_valid_history);
valid = body_window_valid & speed_valid & all(speed_valid_history,1);

Z_M_Ddot_avg = 0;
if body_window_valid
    Z_M_Ddot_avg = (body_history(1) + 2*body_history(2) + Z_M_Ddot) / 4;
end

accel = zeros(1,2);
for wheel = 1:2
    if valid(wheel)
        accel(wheel) = (speed(wheel) - speed_history(1,wheel)) / 0.002;
    end
end

Z_rel_Ddot_L = accel(1);
Z_rel_Ddot_R = accel(2);
valid_L = valid(1);
valid_R = valid(2);

body_history = [body_history(2); Z_M_Ddot];
body_valid_history = [body_valid_history(2); body_valid];
speed_history = [speed_history(2,:); speed];
speed_valid_history = [speed_valid_history(2,:); speed_valid];
end
