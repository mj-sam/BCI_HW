function [ Neighbours,Indexes ] = NeighboursSmall(inputIdx,plane)
    X = plane(inputIdx,:);
    eucleadDistance = [];
    for i_2d=1:59
        Y = plane(i_2d,:);
        dX = abs(X(1)-Y(1));
        dY = abs(X(2)-Y(2));
        eucleadDistance(i_2d) = sqrt(power(dX,2)+power(dY,2));
    end
    Neighbours = struct('Right',struct('idx',0,'dist',10000),'RightTop',struct('idx',0,'dist',10000),'Top',struct('idx',0,'dist',10000),'TopLeft',struct('idx',0,'dist',10000),'Left',struct('idx',0,'dist',10000),'LeftButtom',struct('idx',0,'dist',10000),'Buttom',struct('idx',0,'dist',10000),'ButtomRight',struct('idx',0,'dist',10000));    
    [Out,IdxSorted] = sort(eucleadDistance);
    for i_compare=1:59
        if IdxSorted(i_compare) ~= inputIdx
            tmpDeg = Degree(plane(inputIdx,:),plane(IdxSorted(i_compare),:));
            % ::: on right 
            if (tmpDeg < 22.5 ) || ( 337.5 <= tmpDeg)
                if Neighbours.Right.dist > eucleadDistance(IdxSorted(i_compare))
                    Neighbours.Right.dist = eucleadDistance(IdxSorted(i_compare));
                    Neighbours.Right.idx = IdxSorted(i_compare);
                end
            end
            % ::: on between right and top
            if (22.5 <= tmpDeg) && (tmpDeg < 67.5) 
                if Neighbours.RightTop.dist > eucleadDistance(IdxSorted(i_compare))
                    Neighbours.RightTop.dist = eucleadDistance(IdxSorted(i_compare));
                    Neighbours.RightTop.idx = IdxSorted(i_compare);
                end
            end
            % ::: on top
            if (67.5 <= tmpDeg) && (tmpDeg < 112.5)
                if Neighbours.Top.dist > eucleadDistance(IdxSorted(i_compare))
                    Neighbours.Top.dist = eucleadDistance(IdxSorted(i_compare));
                    Neighbours.Top.idx = IdxSorted(i_compare);
                end
            end        
            % ::: on between top and left
            if (112.5 <= tmpDeg) && (tmpDeg < 157.5)
                if Neighbours.TopLeft.dist > eucleadDistance(IdxSorted(i_compare))
                    Neighbours.TopLeft.dist = eucleadDistance(IdxSorted(i_compare));
                    Neighbours.TopLeft.idx = IdxSorted(i_compare);
                end
            end
            % ::: on left
            if (157.5 <= tmpDeg) && (tmpDeg < 202.5)
                if Neighbours.Left.dist > eucleadDistance(IdxSorted(i_compare))
                    Neighbours.Left.dist = eucleadDistance(IdxSorted(i_compare));
                    Neighbours.Left.idx = IdxSorted(i_compare);
                end
            end
            % ::: on between left and buttom
            if (202.5 <= tmpDeg) && (tmpDeg < 247.5)
                if Neighbours.LeftButtom.dist > eucleadDistance(IdxSorted(i_compare))
                    Neighbours.LeftButtom.dist = eucleadDistance(IdxSorted(i_compare));
                    Neighbours.LeftButtom.idx = IdxSorted(i_compare);
                end
            end        
            % ::: on buttom
            if (247.5 <= tmpDeg) && (tmpDeg < 292.5)
                if Neighbours.Buttom.dist > eucleadDistance(IdxSorted(i_compare))
                    Neighbours.Buttom.dist = eucleadDistance(IdxSorted(i_compare));
                    Neighbours.Buttom.idx = IdxSorted(i_compare);
                end
            end
            % ::: on between buttom and right
            if (292.5 <= tmpDeg) && (tmpDeg < 337)
                if Neighbours.ButtomRight.dist > eucleadDistance(IdxSorted(i_compare))
                    Neighbours.ButtomRight.dist = eucleadDistance(IdxSorted(i_compare));
                    Neighbours.ButtomRight.idx = IdxSorted(i_compare);
                end
            end
        end
    end
    Indexes = [Neighbours.Right.idx Neighbours.RightTop.idx Neighbours.Top.idx Neighbours.TopLeft.idx Neighbours.Left.idx Neighbours.LeftButtom.idx Neighbours.Buttom.idx Neighbours.ButtomRight.idx ];
end

