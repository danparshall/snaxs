function [vec_out,vec_delta]=make_graded_3vec(vec_max,vec_min,Npts)
% [vec_out,vec_delta]=make_graded_3vec(vec_max,vec_min,Npts)
% 	Create at (Npts)x3 array which transitions smoothly from vec_min to vec_max

vec_delta=(vec_max - vec_min)/(Npts-1);

vec1=linspace(vec_min(1),vec_max(1),Npts);
vec2=linspace(vec_min(2),vec_max(2),Npts);
vec3=linspace(vec_min(3),vec_max(3),Npts);

vec_out=[vec1(:) vec2(:) vec3(:)];

