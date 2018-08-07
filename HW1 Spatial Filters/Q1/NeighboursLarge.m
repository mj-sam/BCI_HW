function [ Indexes ] = NeighboursLarge(inputIdx,plane)
    Indexes = [];
    [out,closeNeighbour] = NeighboursSmall(inputIdx,plane);
    for i_closeNeighbour = 1:size(closeNeighbour,2)
        [out,Tmp] = NeighboursSmall(closeNeighbour(i_closeNeighbour),plane);
        Indexes = union(Indexes,Tmp);
    end
    Indexes = setdiff(Indexes,closeNeighbour);
end

