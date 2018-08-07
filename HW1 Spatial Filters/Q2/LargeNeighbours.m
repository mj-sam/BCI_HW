function [ right,left,up,down] = LargeNeighbours(inputIdx,plane)
    [TmpRight,out,out,out] = SmallNeighbours(inputIdx,plane);
    [right,out,out,out] = SmallNeighbours(TmpRight,plane);
    
    [out,TmpLeft,out,out] = SmallNeighbours(inputIdx,plane);
    [out,left,out,out] = SmallNeighbours(TmpLeft,plane);
    
    [out,out,TmpUp,out] = SmallNeighbours(inputIdx,plane);
    [out,out,up,out] = SmallNeighbours(TmpUp,plane);
    
    [out,out,out,TmpDown] = SmallNeighbours(inputIdx,plane);
    [out,out,out,down] = SmallNeighbours(TmpDown,plane);
end
