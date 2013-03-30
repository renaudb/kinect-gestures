%LABEL_DATA -- Label the dataset with beginning frames.
%
% Input
%    directory: location of sequences.
%
% Output
%    file_names: files labelled.
%    frame_beginnings: the beginning frame for each file.
%
% Author: Renaud Bourassa-Denis

% Set the directory.
directory = '../data/';

% Set the ratio.
ratio = 1.0;

% Set gesture mask.
gesture_mask = [1:12];

% List of tags.
tagset = { 'G1  lift outstretched arms', 'G2  Duck', ...
	'G3  Push right', 'G4  Goggles', 'G5  Wind it up', ...
	'G6  Shoot', 'G7  Bow', 'G8  Throw', 'G9  Had enough', ...
	'G10 Change weapon', 'G11 Beat both', 'G12 Kick' };

% Load all data files from directory.
files = dir(strcat(directory, '/*.csv'));

% Store the label data.
file_names = {};
frame_beginnings = [];

% Iterates over all files.
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

  % Skip empty files.
  if size(Yf, 1) == 0
      continue
  end

  name
  % Remove frames past first action.
  [r,c] = find(Yf == 1);
  r = r(find(c < 13));
  seq_end = r(1);
  Xf = Xf(1:seq_end, :);
  Yf = Yf(1:seq_end, :);

  % Remove 0 columns from X.
  X = Xf(:, setdiff([1:80], [4:4:80]));
  Y = Yf;

  % Set the axes.
  h = axes;

  % Iterate over the frames.
  T = size(X,1);
  ti = T;
  while ti >= 1
    skel_vis(X,ti,h);
    drawnow;

    % Stop on input.
    a = input('', 's');
    if strcmp(a, 'z')
        file_names{i} = name;
        frame_beginnings(i) = ti;
        break;
    elseif strcmp(a, '')
        % Do nothing
        ti = max(1, ti - 1);
    else
        % Assuming its a number
        ti = min(ti + str2double(a), T);
    end
    cla;
  end

  % Print the result.
  file_names
  frame_beginnings
end
