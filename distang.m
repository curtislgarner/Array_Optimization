% Calculates distance and angle between 2 coordinate pairs
function [d,a]=distang(p1,p2)
d=sqrt((p1(1)-p2(1))^2+(p1(2)-p2(2))^2);
a=atan2(p2(2)-p1(2),p2(1)-p1(1));

