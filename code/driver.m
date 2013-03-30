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