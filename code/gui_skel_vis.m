function gui_skel_vis(X,tidx,h);
%SKEL_VIS -- Visualize a skeleton in 3D coordinates.
%
% Input
%   X: (T,4*NUI_SKELETON_POSITION_COUNT) matrix from load_file.
%   tidx: time index >=1, <=T.
%   h: (optional) axes handle to draw in.
%
% Author: Sebastian Nowozin <Sebastian.Nowozin@microsoft.com>

assert(tidx >= 1);
assert(tidx <= size(X,1));
xyz_ti=X(tidx,:);

skel_model
skel=reshape(xyz_ti, 4, NUI_SKELETON_POSITION_COUNT)';
if nargin < 3
  h=axes;
end

axes(h);
plot3(skel(:,1), skel(:,2), skel(:,3), 'bo');
axis(h, 'equal');

for ci=1:size(nui_skeleton_conn,1)
  hold on;
  line([xyz_ti(4*nui_skeleton_conn(ci,1)+1) ; ...
	xyz_ti(4*nui_skeleton_conn(ci,2)+1)], ...
	[xyz_ti(4*nui_skeleton_conn(ci,1)+2) ; ...
	xyz_ti(4*nui_skeleton_conn(ci,2)+2)], ...
	[xyz_ti(4*nui_skeleton_conn(ci,1)+3) ; ...
	xyz_ti(4*nui_skeleton_conn(ci,2)+3)]);
end

tpos=[0, 0, 2.75];
cpos=tpos + [3, 2, -5];
set(h,'CameraPosition',cpos);
set(h,'CameraTarget',tpos);
set(h,'CameraViewAngle',12);
set(h,'CameraUpVector',[0 1 0]);
set(h,'Projection','perspective');

set(h,'XTick',[]);
set(h,'YTick',[]);
set(h,'ZTick',[]);

set(h,'XLim', [-0.5, 0.5]);
set(h,'YLim', [-1.0, 1.0]);
set(h,'ZLim', [ 2.5, 3.0]);

title(sprintf('Frame %d', tidx));
