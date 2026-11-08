function omega = wheel_carrier_rate(phi1,phi4,w1,w4,bodyPitchRate)
%#codegen
% 实际轮电机基座（连杆 BC）绕世界 X 轴的角速度，单位 rad/s。
% 输入采用与 control/Subsystem4 和 calc/Subsystem1 相同的坐标约定。
% 几何参数与 VMC_calc 一致，髋轴间距为 80 mm。
l1=0.075; l2=0.14; l3=0.14; l4=0.075; l5=0.08;
xb=l1*cos(phi1); yb=l1*sin(phi1);
xd=l5+l4*cos(phi4); yd=l4*sin(phi4);
a=2*l2*(xd-xb); b=2*l2*(yd-yb);
c=l2*l2+(xd-xb)^2+(yd-yb)^2-l3*l3;
disc=a*a+b*b-c*c;
assert(disc >= -1e-12, 'Unreachable five-bar geometry');
phi2=2*atan2(b+sqrt(max(disc,0)),a+c);
phi3=atan2(yb-yd+l2*sin(phi2),xb-xd+l2*cos(phi2));
den=l2*sin(phi3-phi2);
assert(abs(den)>1e-10, 'Five-bar velocity singularity');
w2=(l1*sin(phi1-phi3)*w1+l4*sin(phi3-phi4)*w4)/den;
% 本模型中，实际连杆转动与机身俯仰角速度在世界 X 轴方向相加。
omega=w2+bodyPitchRate;
end
