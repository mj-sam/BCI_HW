function [ signal ] = Laplacian( Signal,ChIdx,Positions,Type )
% Signal : EEG signal which has all the channel
% ChIdx  : channel we want to apply filter on
% Position : position of channel in 2d
% Type : type of filter
% Handle zero index
    signal = [];
    for i_channel=1:size(ChIdx,2)
        %% for each channel we want to apply filter
        % Find neighbours
        if strcmp(Type,'small')
            [NN,IndxNeighbour] = NeighboursSmall(ChIdx(i_channel),Positions);
        else
            [IndxNeighbour] = NeighboursLarge(ChIdx(i_channel),Positions);
        end
        SumDistance = 0;
        for i_neighbour = 1:size(IndxNeighbour,2)
            if IndxNeighbour(i_neighbour) ~= 0
                TmpDistance = Distance(Positions(ChIdx(i_channel),:),Positions(IndxNeighbour(i_neighbour),:));
                SumDistance = SumDistance + (1/TmpDistance);
            end
        end
        AccomulatedSignal = zeros(size(Signal,1),1);
        for i_neighbour = 1:size(IndxNeighbour,2)
            if IndxNeighbour(i_neighbour) ~= 0
                TmpDistance = Distance(Positions(ChIdx(i_channel),:),Positions(IndxNeighbour(i_neighbour),:));
                TmpG = ((1 / TmpDistance)/SumDistance);
                TmpFiltered = TmpG * Signal(:,IndxNeighbour(i_neighbour),:);
                AccomulatedSignal = AccomulatedSignal + TmpFiltered;
            end
        end
        signal(:,i_channel) = Signal(:,ChIdx(i_channel)) - AccomulatedSignal;
    end
end