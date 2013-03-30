function [X,Y,slided_relX,weighted_Y,tagset]=load_data_sliding(directory, ratio, gesture_mask);
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
if nargin < 1
   directory = '../data/'
end

% Set the ratio if left unspecified.
if nargin < 2
  ratio = 1.0;
end

% Set gesture mask to all gesture if unspecified.
if nargin < 3
  gesture_mask = [1];
end

% List of tags.
tagset = { 'G1  lift outstretched arms', 'G2  Duck', ...
	'G3  Push right', 'G4  Goggles', 'G5  Wind it up', ...
	'G6  Shoot', 'G7  Bow', 'G8  Throw', 'G9  Had enough', ...
	'G10 Change weapon', 'G11 Beat both', 'G12 Kick' };

% Load all data files from directory.
files = dir(strcat(directory, '/*.csv'));
sliding_window_size=5;
skip_size=3;
s = RandStream('mt19937ar','Seed',0);
files = files(randperm(s, size(files,1)),:);

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

  % Remove frames past first action.
  [r,c] = find(Yf == 1);
  r = r(find(c < 13));
  seq_end = r(1);
  Xf = Xf(1:seq_end, :);
  Yf = Yf(1:seq_end, :);

  % Retag the data.
  [Xf, Yf] = retag(Xf, Yf, name);

  % Remove 0 columns from X.
  Xf = Xf(:, setdiff([1:80], [4:4:80]));
  Xf=Xf([1:skip_size:size(Xf,1)],:);
  Yf=Yf([1:skip_size:size(Yf,1)],:);
  relXf=repmat(Xf(:,7:9),1,20)-Xf;
  
  slided_relXf = zeros(size(relXf,1)-sliding_window_size, size(relXf,2)*sliding_window_size);
  weighted_Yf = zeros(size(Yf,1)-sliding_window_size, size(Yf,2));
  for j=1:size(relXf,1)-sliding_window_size
      for k=1:sliding_window_size
          slided_relXf(j,(k-1)*size(relXf,2)+1:k*size(relXf,2))=relXf(j+k-1,:);
          weighted_Yf(j,:)=weighted_Yf(j,:)+Yf(j+k-1,:);
      end
      weighted_Yf(j,:)=weighted_Yf(j,:)./sliding_window_size;
  end
  
%   if mod(i,skip_size)==0 && i >= sliding_window_size * skip_size
%       input = [];
%       for k=sliding_window_size:-sliding_window_size:i - sliding_window_size * skip_size
%           input = [input relXf];
%       end
%       
%       slided_relXf = [slided_relXf; input];
%   end  

%   
%   slided_relXf=zeros(size(relXf,1)-sliding_window_size, size(relXf,1)*sliding_window_size);
%   for j=1:size(slided_relXf,1)
%       
%   end
  
  % Add the data to X and Y.
  if exist('X') && exist('Y')
    X = cat(1,X,Xf);
    Y = cat(1,Y,Yf);
    relX = cat(1,relX,relXf);
    slided_relX = cat(1,slided_relX,slided_relXf);
    weighted_Y = cat(1,weighted_Y,weighted_Yf);
  else
    X = Xf;
    Y = Yf;
    relX = relXf;
    slided_relX = slided_relXf;
    weighted_Y = weighted_Yf;
  end
end
