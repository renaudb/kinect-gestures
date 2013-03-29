function [X,Y]=load_file(file_basename, tagset);
%LOAD_FILE -- Load gesture recognition sequence
%
% Input
%    file_basename: sequence name such as 'P1_1_1A_01'.
%
% Output
%    X: (T,80) skeletal frames.
%    Y: (T,GN) 0/1 encoding of gesture presence.
%    tagset: (1,GN) cellarray of gesture names.
%
% Author: Sebastian Nowozin <Sebastian.Nowozin@microsoft.com>

X=load(sprintf('../data/%s.csv', file_basename));
tags=load_tagstream(sprintf('../data/%s.tagstream', file_basename), tagset);
Y=tagstream_to_y(X, tags, tagset, 1);

X=X(:,2:end);

K=find(sum(abs(X),2)<=1.0e-10);
RI=[];
for ki=1:numel(K)
  if K(ki) ~= ki
    break;
  end
  RI=[RI, ki];
end
X(RI,:)=[];
Y(RI,:)=[];
