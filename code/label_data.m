%LOAD_DATA -- Load gesture recognition dataset
%
% Input
%    directory: location of sequences.
%
% Output
%    X: (N,60) skeletal frames.
%    Y: (N,GN+1) 0/1 encoding of gesture presence.
%    tagset: (1,GN) cellarray of gesture names.
%
% Author: Renaud Bourassa-Denis

% Set the directory if left unspecified.

   directory = '../data/'


% Set the ratio if left unspecified.

  ratio = 1.0;


% Set gesture mask to all gesture if unspecified.

  gesture_mask = [10:12];


% List of tags.
tagset = { 'G1  lift outstretched arms', 'G2  Duck', ...
	'G3  Push right', 'G4  Goggles', 'G5  Wind it up', ...
	'G6  Shoot', 'G7  Bow', 'G8  Throw', 'G9  Had enough', ...
	'G10 Change weapon', 'G11 Beat both', 'G12 Kick' };

% Load all data files from directory.
files = dir(strcat(directory, '/*.csv'));


file_names = {};
frame_beginnings = [];

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
  % Remove frames past first action.
  [r,c] = find(Yf == 1);
  r = r(find(c < 13));
  seq_end = r(1);
  Xf = Xf(1:seq_end, :);
  Yf = Yf(1:seq_end, :);

  % Retag the data.
  [Xf, Yf] = tag(Xf, Yf);

  % Remove 0 columns from X.
  X = Xf(:, setdiff([1:80], [4:4:80]));
  Y = Yf;
  
  h = axes;
  T = size(X,1);

  ti = 1;
  while ti <= T
    skel_vis(X,ti,h);
    drawnow;

    a = input('', 's');
    if strcmp(a, 'z')
        file_names{i} = name;
        frame_beginnings(i) = ti;
        break;
    elseif strcmp(a, '')
        % do nothing
        ti = min(ti + 1, T);
    else
        % Assuming its a number
        ti = max(ti - str2double(a), 1);
    end
    cla;
  end
  hold off;
end