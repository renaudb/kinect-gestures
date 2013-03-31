[X, Y, relX, z] = load_data('../data/', 1.0, [1:12]);
train_X=X(1:uint32(size(X,1)*0.8),:);
train_Y=Y(1:uint32(size(Y,1)*0.8),:);
val_Y=Y(uint32(size(Y,1)*0.8)+1:end,:);
val_X=X(uint32(size(X,1)*0.8)+1:end,:);
train_relX=relX(1:uint32(size(relX,1)*0.8),:);
val_relX=relX(uint32(size(relX,1)*0.8)+1:end,:);

net=train_net(train_relX, train_Y)
test_net(net, val_relX, val_X, val_Y)

%train_dX=dX(1:uint32(size(dX,1)*0.8),:);
%train_dY=dY(1:uint32(size(dY,1)*0.8),:);

%val_dY=dY(uint32(size(dY,1)*0.8)+1:end,:);
%val_dX=dX(uint32(size(dX,1)*0.8)+1:end,:);


% For sliding window. Note that this also skips frames. Sliding window size
% and skip sizes can be modified in load_data_sliding.
[slided_relX,weighted_Y] = load_data_sliding('../data/', 1.0, [1:12], 5, 3);
train_relX=slided_relX(1:uint32(size(slided_relX,1)*0.8),:);
val_relX=slided_relX(uint32(size(slided_relX,1)*0.8)+1:end,:);
train_Y=weighted_Y(1:uint32(size(weighted_Y,1)*0.8),:);
val_Y=weighted_Y(uint32(size(weighted_Y,1)*0.8)+1:end,:);

net=train_net(train_relX, train_Y, [100])
test_net_sliding(net, val_relX, val_Y)
