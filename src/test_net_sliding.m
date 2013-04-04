function test_net_sliding(net, test_relX, test_Y)
    h = axes;
    correct_frames = 0;
    correct_gestures = 0;
    total_gestures = 0;
    T = size(test_Y,1);
    sq_diff_tot = 0.0;
    current_gesture = -1;
    votes = zeros(1, 13);
    for ti=1:T
        result = net(test_relX(ti, :)');
        [r, c] = max(result);
        [rr, cc] = max(test_Y(ti, :));
        if c == cc
            correct_frames = correct_frames +1;
        end
        sq_diff = sum((test_Y(ti,:)-result').^2)/size(result,1);
        sq_diff_tot = sq_diff_tot + sq_diff;
        %fprintf('%d net_output: %d  expected: %d  sq_difference: %f\n', ti, c, cc, sq_diff);
        
        % Geture based metrics
        if cc == 13
            continue;
        end
        if current_gesture == -1
            current_gesture = cc;
        end                
        if current_gesture ~= cc
            if max(votes') == 0
                majority = 13;
            else
                [r, majority] = max(votes');
            end            
            if majority == current_gesture
                correct_gestures = correct_gestures + 1;
                fprintf('%d,%d guessed correctly\n', current_gesture, majority);
            else
                fprintf('%d,%d guessed incorrectly\n', current_gesture, majority);
            end
            votes = zeros(1, 13);
            total_gestures = total_gestures + 1;
            current_gesture = cc;
        end
        if c ~= 13
            votes(1, c) = votes(1, c) + 1;
        end
    end
    fprintf('frame precision: %f\n', correct_frames * 1.0/ T);
    fprintf('squared error: %f\n', sq_diff_tot / T);
    gesture_recall = correct_gestures * 1.0 / total_gestures;
    fprintf('gesture recall: %f\n', gesture_recall);
end