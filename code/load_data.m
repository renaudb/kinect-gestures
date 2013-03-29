function [X,Y,tagset]=load_data(directory, ratio, gesture_mask);
%LOAD_DATA -- Load gesture recognition dataset
%
% Input
%    directory: location of sequences.
%
% Output
%    X: (N,60) skeletal frames.
%    Y: (N,GN+1) 0/1 encoding of gesture presence.
%    tagset: (1,GN+1) cellarray of gesture names.
%
% Author: Renaud Bourassa-Denis

% Set the ratio if left unspecified.
if nargin < 2
  ratio = 1.0;
end

% Set gesture mask to all gesture if unspecified.
if nargin < 3
  gesture_mask = [1:12];
end

% List of tags.
tagset = { 'G1  lift outstretched arms', 'G2  Duck', ...
	'G3  Push right', 'G4  Goggles', 'G5  Wind it up', ...
	'G6  Shoot', 'G7  Bow', 'G8  Throw', 'G9  Had enough', ...
	'G10 Change weapon', 'G11 Beat both', 'G12 Kick' };

% Load all data files from directory.
files = dir(strcat(directory, '/*.csv'));
for i = 1:length(files)
  % Break up the file.
  [p,name,e] = fileparts(files(i).name);

  % Skip csv files with no tagstream.
  if (exist(strcat(directory, name, '.tagstream'), 'file') ~= 2)
     continue;
  end

  % Extract the gesture.
  parts = regexp(name,'_','split');
  gesture = str2num(cell2mat(strrep(parts(3), 'A', '')));

  % Skip gestures not in gesture_mask.
  if (size(find(gesture_mask == gesture), 2) == 0)
    continue;
  end

  % Skip files depending on ratio.
  if (rand(1,1) > ratio)
    continue;
  end

  % Load the data from the file.
  [Xf,Yf] = load_file(name, tagset);

  % Remove 0 columns from X.
  Xf = Xf(:, setdiff([1:80], [4:4:80]));

  % Add the data to X and Y.
  if exist('X') && exist('Y')
    X = cat(1,X,Xf);
    Y = cat(1,Y,Yf);
  else
    X = Xf;
    Y = Yf;
  end
end
