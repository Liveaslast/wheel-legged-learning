function [L0, J, valid] = five_bar_geometry_rm(phi1, phi4)
% 机加工五连杆的腿长和 VMC 力矩映射矩阵。
% J 的第一列是腿长对 J1、J4 角度的偏导；第二列对应虚拟腿角。

L0 = 0;
J = zeros(2,2);
valid = false;
if ~isfinite(phi1) || ~isfinite(phi4)
    return
end

l1 = 0.12; l2 = 0.18; l3 = 0.18; l4 = 0.12; l5 = 0.10;

% 与机加工版 VMC 采用同一个闭环装配分支。
xb = l1*cos(phi1);
yb = l1*sin(phi1);
xd = l5 + l4*cos(phi4);
yd = l4*sin(phi4);
a = 2*l2*(xd - xb);
b = 2*l2*(yd - yb);
c = l2^2 - l3^2 + (xd - xb)^2 + (yd - yb)^2;
disc = a^2 + b^2 - c^2;
if disc <= 0
    return
end
phi2 = 2*atan2(b + sqrt(disc), a + c);
phi3 = atan2(yb - yd + l2*sin(phi2), xb - xd + l2*cos(phi2));
x = xb + l2*cos(phi2) - l5/2;
y = yb + l2*sin(phi2);
L0 = hypot(x,y);
phi0 = atan2(y,x);
s = sin(phi3 - phi2);
if L0 < 1e-6 || abs(s) < 1e-6
    return
end

% 原 VMC 正向映射为 [T1; T2] = J * [F0; Tp]。
j11 = l1*sin(phi0 - phi3)*sin(phi1 - phi2)/s;
j12 = l1*cos(phi0 - phi3)*sin(phi1 - phi2)/(L0*s);
j21 = l4*sin(phi0 - phi2)*sin(phi3 - phi4)/s;
j22 = l4*cos(phi0 - phi2)*sin(phi3 - phi4)/(L0*s);
J = [j11, j12; j21, j22];
valid = true;
end
