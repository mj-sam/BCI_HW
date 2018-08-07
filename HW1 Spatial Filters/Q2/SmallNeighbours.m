function [ right,left,up,down] = SmallNeighbours(inputIdx,plane)
    X = plane(inputIdx,:);
    eucleadDistance = [];
    distanceX = [];
    distanceY = [];
    for i_2d=1:59
        Y = plane(i_2d,:);
        dX = abs(X(1)-Y(1));
        dY = abs(X(2)-Y(2));
        eucleadDistance(i_2d) = sqrt(power(dX,2)+power(dY,2));
    end
    for i_x=1:59
        Y = plane(i_x,:);
        distanceX(i_x) = X(1)-Y(1);
    end
    for i_x=1:59
        Y = plane(i_x,:);
        AbsdistanceX(i_x) = abs(X(1)-Y(1));
    end
    for i_y=1:59
        Y = plane(i_y,:);
        AbsdistanceY(i_y) = abs(X(2)-Y(2));
    end
    for i_y=1:59
        Y = plane(i_y,:);
        distanceY(i_y) = X(2)-Y(2);
    end
    [Out,idx] = sort(eucleadDistance);
    %% finding nearest right
    for i_idx = 1 : size(idx,2)
        if AbsdistanceY(idx(i_idx)) < 0.1 && distanceX(idx(i_idx)) > 0  && idx(i_idx) ~= inputIdx
            right = idx(i_idx);
           break
        end
    end
    %% finding nearest Left
    for i_idx = 1 : size(idx,2)
        if AbsdistanceY(idx(i_idx)) < 0.1 && distanceX(idx(i_idx)) < 0  && idx(i_idx) ~= inputIdx
            left = idx(i_idx);
           break
        end
    end
     %% finding nearest Down
    for i_idx = 1 : size(idx,2)
        if AbsdistanceX(idx(i_idx)) < 0.1 && distanceY(idx(i_idx)) > 0  && idx(i_idx) ~= inputIdx
            down = idx(i_idx);
           break
        end
    end
    %% finding nearest Up
    for i_idx = 1 : size(idx,2)
        if AbsdistanceX(idx(i_idx)) < 0.1 && distanceY(idx(i_idx)) < 0  && idx(i_idx) ~= inputIdx
            up = idx(i_idx);
           break
        end
    end
end

