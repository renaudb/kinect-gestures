function test_net(net, test_relX, test_X, test_Y)
    h = axes;
    correct = 0;
    T = size(test_X,1);
   
    for ti=1:T
        skel_vis(test_X,ti,h);
        drawnow;
        
        result = net(test_relX(ti, :)');
        [r, c] = max(result);

        if c==find(test_Y(ti, :) == 1)
            correct=correct+1;
        end
        fprintf('%d net_output: %d  expected: %d \n', ti, c, find(test_Y(ti, :) == 1));
        
        %pause(1/30);
        cla;
    end
    fprintf('precision: %f\n', correct * 1.0/ T);
end