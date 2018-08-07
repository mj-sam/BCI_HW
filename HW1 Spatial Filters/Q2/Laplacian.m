function [ signal ] = Laplacian( Signal,ChIdx,Positions,Type )
signal = [];
for i_channel=1:size(ChIdx,2)
    %% for each channel we want to apply filter
    % Find neighbours
    if strcmp(Type,'small')
        [Right,Left,Up,Down] = SmallNeighbours(ChIdx(i_channel),Positions);
    else
        [Right,Left,Up,Down] = LargeNeighbours(ChIdx(i_channel),Positions);
    end
    % Sum of distance with neighbours
    DisRight    =   Distance(Positions(ChIdx(i_channel),:),Positions(Right,:));
    DisLeft     =   Distance(Positions(ChIdx(i_channel),:),Positions(Left,:));
    DisUp       =   Distance(Positions(ChIdx(i_channel),:),Positions(Up,:));
    DisDown     =   Distance(Positions(ChIdx(i_channel),:),Positions(Down,:));
    SumDistance = (1/DisRight) + (1/DisLeft) + (1/DisUp) + (1/DisDown);
    % Init Accomulator
    % G * Right neighbour signal
    % Right Part
    G = ((1 / DisRight)/SumDistance);
    FilteredRight = G * Signal(:,Right);
    % Left part
    G = ((1 / DisLeft)/SumDistance);
    FilteredLeft = G * Signal(:,Left);
    % Up part
    G = ((1 / DisUp)/SumDistance);
    FilteredUp = G * Signal(:,Up);
    % Down part
    G = ((1 / DisDown)/SumDistance);
    FilteredDown = G * Signal(:,Down);
    AccomulatedSignal = FilteredRight + FilteredLeft + FilteredUp + FilteredDown ;
    %%
    %     disp('acc ')
    %     size(AccomulatedSignal)
    %     disp('sig ')
    %     size(Signal(ChIdx(i_channel),:))
    signal(:,i_channel) = Signal(:,ChIdx(i_channel)) - AccomulatedSignal;
end
end