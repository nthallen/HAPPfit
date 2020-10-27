function chunks = chunker(index)

% function chunks = chunker(index)
%Input is a vector containing indices for all data chunks of a certain type (e.g. inlet number)
%output is a 2-column matrix containing start and stop indices for each chunk

%Edited from the MBO2006 function autoindexer.m.
%070707 Glenn Wolfe (NASA Goddard)

if isempty(index)
    chunks = [];
else
    chunks = [];%this matrix will contain the indices
    j=find(diff(index)~=1);
    chunkstart = [index(1);index(j+1)];
    chunkstop = [index(j);index(end)];
    chunks = [chunkstart chunkstop];
end