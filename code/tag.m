function [X,Y]=tag(X, Y, scheme);
%TAG -- Retag the raw data according to a tagging scheme.
%
% Input
%    Xi: (N,60) skeletal frames.
%    Yi: (N,GN+1) 0/1 encoding of gesture presence.
%    scheme: the tagging scheme to use.
%
% Output
%    X: (N,60) skeletal frames.
%    Y: (N,GN+1) 0/1 encoding of gesture presence.
%
% Author: Renaud Bourassa-Denis

% Set the scheme if left unspecified.
if nargin < 3
  scheme = 'last-60';
end

function [X, Y] = last_n(X, Y, n)
  % Iterate through every frame.
  for i=1:size(Y, 1)
    % Extract the frame gesture id.
    id = find(Y(i,:) == 1);
    if id ~= 13
      % If the id is not 13 (nothing), retag the past 60 frames.
      for j=(i + [-1:-1:-n])
	if j < 1 || find(Y(j,:) == 1) ~= 13
	  break
	end
	% Retag with id.
	Y(j, id) = 1;
	Y(j, 13) = 0;
      end
    end
  end
end

% Retag according to the given scheme.
switch scheme
  case 'last-60'
    [X,Y] = last_n(X, Y, 60);
  otherwise
    warning('Unexpected ');
end

end
