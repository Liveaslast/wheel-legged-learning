function [L_T_cmd, R_T_cmd] = T_select(on_ground, T_air, L_T_ground, R_T_ground)
% 轮端力矩选择：当在空中时，采用空中姿态控制器计算的驱动轮力矩；在地面时采用LQR计算出的驱动轮力矩
if on_ground
    L_T_cmd = L_T_ground;
    R_T_cmd = R_T_ground;
else
    L_T_cmd = T_air;
    R_T_cmd = T_air;
end

end