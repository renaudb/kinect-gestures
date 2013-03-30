function test_net_sliding(net, test_relX, test_Y)
    h = axes;
    correct = 0;
    T = size(test_Y,1);
    sq_diff_tot = 0.0;
    for ti=1:T
        result = net(test_relX(ti, :)');
        [r, c] = max(result);
        [rr, cc] = max(test_Y(ti, :));
        if c==cc
            correct=correct+1;
        end
        sq_diff = sum((test_Y(ti,:)-result').^2)/size(result,2);
        sq_diff_tot = sq_diff_tot + sq_diff;
        fprintf('%d net_output: %d  expected: %d  sq_difference: %f\n', ti, c, cc, sq_diff);
    end
    fprintf('precision: %f\n', correct * 1.0/ T);
    fprintf('squared error: %f\n', sq_diff_tot / T);
end