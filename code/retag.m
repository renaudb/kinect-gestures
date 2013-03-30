function [X,Y]=retag(X, Y, name, scheme);
%RETAG -- Retag the raw data according to a tagging scheme.
%
% Input
%    Xi: (N,60) skeletal frames.
%    Yi: (N,GN+1) 0/1 encoding of gesture presence.
%    name: the name of the file.
%    scheme: the tagging scheme to use.
%
% Output
%    X: (N,60) skeletal frames.
%    Y: (N,GN+1) 0/1 encoding of gesture presence.
%
% Author: Renaud Bourassa-Denis

% Set the scheme if left unspecified.
if nargin < 4
  scheme = 'label';
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

function [X, Y] = motion(X, Y, tol)
  % Find the motion start.
  motion_start = 1;
  for i=2:size(X,1)
    dist = sqrt(sum((X(i,:)-X(i-1,:)).^2));
    if dist > tol
      motion_start = i;
      break
    end
  end

  % Update the class.
  id = find(Y(end,:) == 1);
  Y(motion_start:end, id) = 1;
  Y(motion_start:end, 13) = 0;
end

function [X, Y] = label(X, Y, name)
  % Read the labels.
  frames = importdata('../data/labels/labels.txt');

  % Find the beginning of the sequence.
  seq_beg = frames.data(find(strcmp(name, frames.textdata)));

  % Update the class.
  id = find(Y(end,:) == 1);
  Y(seq_beg:end, id) = 1;
  Y(seq_beg:end, 13) = 0;
end

% Retag according to the given scheme.
switch scheme
  case 'last-60'
    [X,Y] = last_n(X, Y, 60);
  case 'motion'
    [X,Y] = motion(X, Y, 0.1);
  case 'label'
    [X,Y] = label(X, Y, name);
  otherwise
    warning('Unexpected ');
end

end
