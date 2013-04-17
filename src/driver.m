% Load the data and separate it in training and testing dataset.
[slided_relX,weighted_Y] = load_data_sliding('../data/', 1.0, [1:12], 5, 5);
train_relX=slided_relX(1:uint32(size(slided_relX,1)*0.8),:);
val_relX=slided_relX(uint32(size(slided_relX,1)*0.8)+1:end,:);
train_Y=weighted_Y(1:uint32(size(weighted_Y,1)*0.8),:);
val_Y=weighted_Y(uint32(size(weighted_Y,1)*0.8)+1:end,:);

% Train a network.
net=train_net(train_relX, train_Y, [25])

% Test the network.
test_net_sliding(net, val_relX, val_Y)
