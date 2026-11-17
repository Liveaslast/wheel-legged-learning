function [T_air, on_ground] = airborne_pitch_mode( ...
    F_N_L, F_N_R, valid_L, valid_R, PITCH, d_PITCH)

% MATLAB Function 块以 0.001 s 离散执行。
% on_ground 为 true 时选择地面 LQR，为 false 时选择空中控制。
% T_air 是每轮力矩，单位 N·m。PITCH 和 d_PITCH 分别用 rad 和 rad/s。

persistent ground_state sample_count
if isempty(ground_state)
    ground_state = false;
    sample_count = 0;
end

% 支持力阈值为初始试验值，按估算支持力的实际波形标定。
contact_force = 6;    % 每轮接地阈值，N
release_force = 3;    % 每轮离地阈值，N
confirm_samples = 5;  % 连续 5 个采样点

transition_detected = false;
if valid_L && valid_R && isfinite(F_N_L) && isfinite(F_N_R)
    if ground_state
        transition_detected = F_N_L <= release_force && F_N_R <= release_force;
    else
        transition_detected = F_N_L >= contact_force && F_N_R >= contact_force;
    end
end

% 无效估算或条件中断时清空计数，保持当前状态。
if transition_detected
    sample_count = sample_count + 1;
    if sample_count >= confirm_samples
        ground_state = ~ground_state;
        sample_count = 0;
    end
else
    sample_count = 0;
end

on_ground = ground_state;

% 轮电机对机身的反作用力矩用于减小俯仰，正号沿用已试的轴向。
T_air = 0;
if ~on_ground && isfinite(PITCH) && isfinite(d_PITCH)
    T_air = max(-0.5, min(0.5, 1.0*PITCH + 0.08*d_PITCH));
end
end
