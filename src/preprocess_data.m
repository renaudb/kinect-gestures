function [Xp, Yp] = preprocess_data(X, Y, name, window, skip);
%PREPROCESS_DATA -- Load gesture recognition dataset
%
% Input
%    X: (N,80) skeletal frames.
%    Y: (N,GN+1) 0/1 encoding of gesture presence.
%    window: sliding window size.
%    skip: number of skipped frames.
%
% Output
%    Xp: preprocessed X.
%    Yp: preprocessed Y.
%
% Author: Renaud Bourassa-Denis

% Rename parameters.
w = window;
s = skip;

% Retag the data.
[Xp, Yp] = retag(X, Y, name);

% Remove 1.0 columns from X.
Xp = Xp(:, setdiff([1:80], [4:4:80]));

% Normalize over shoulder center.
Xp = repmat(Xp(:,7:9),1,20)-Xp;

% Compute final number of rows.
N = size(Xp, 1) - (s * w - 2);

% Duplicate and reshape data over window.
idx = [1:N]' * ones(1, w) + repmat([0:s:(s * w) - 1], N, 1);
Xp = reshape(Xp(idx',:)', w * size(Xp, 2), [])';

% Compute moving average over window.
f = zeros(w * s - 1, 1);
f(1:s:(s * w - 1), 1) = 1 / w;
Yp = flipud(filter(f, 1, flipud(Yp(1:N, :))));
