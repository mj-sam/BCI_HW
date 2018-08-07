function [signal] = SpatialFilter(Signal,Positions,Type,ChannelIndex)
    if strcmp(Type,'Nofilter')
        signal = Signal(:,ChannelIndex);
    end
    
    if strcmp(Type,'CAR')
        CommonAverage = mean(Signal,2);
        signal = bsxfun(@minus,Signal,CommonAverage);
        signal = signal(:,ChannelIndex);
    end
    
    if strcmp(Type,'SLaplacian')
        signal = Laplacian(Signal,ChannelIndex,Positions,'small');
    end
    
    if strcmp(Type,'LLaplacian')
        signal = Laplacian(Signal,ChannelIndex,Positions,'large');
    end
end

