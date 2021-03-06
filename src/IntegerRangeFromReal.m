function [integer_max, offset, step_size] = IntegerRangeFromReal( min_max, step_size, continuous_chunks )
%INTEGERRANGEFROMREAL Convert a range of real values to integers
%  
% integer_max = IntegerRangeFromReal( min_max, step_size)
%   Returns the number of steps needed to span the space identified by
%   the two row matrix min_max = [min; max] with step_size. 
%
%   step_size=0 is assumed to be continuous and step sizes for these
%   continuous are computed such that the continuous space is divided into
%   chunks (default is 10 chunks, identified by the range 1:11)
%
% ... = IntegerRangeFromReal(min_max, step_size, continuous_chunks)
%   specify the number of chunks to use for continuous values
%
% [integer_max, offset] = IntegerRangeFromReal(...)
%   also return the rounded version of minimum values to use as the offset
%
% [integer_max, offset, step_size] = IntegerRangeFromReal(...)
%   also return the actual step_sizes used (including continuous functions)
%
% The original range can be reconstructed as
%   min_max = zeros(2, length(integer_max));
%   min_max(2,:) = (integer_max - 1) .* step_size;
%   min_max = bsxfun(@plus, min_max, offset);
%
% Example:
% >> format shortG
% >> [integer_max, offset, step_size] = IntegerRangeFromReal([0 1 1.5 3 3.2 20; 2 2 3 4.2 4 80], [.5 .5 .3 .2 0 60])
% 
% integer_max =
%      5     3     6      7    11     2
% offset =
%      0     1     1.5    3    3.2    20
% step_size =
%      0.5   0.5   0.3    0.2  0.08   60
%
%
% Rebuild range and check
%
%  >> min_max = zeros(2, length(integer_max));
%  >> min_max(2,:) = (integer_max - 1) .* step_size;
%  >> min_max = bsxfun(@plus, min_max, offset)
% 
% min_max =
%     0    1    1.5    3      3.2   20
%     2    2    3      4.2    4     80
%
%
% adapted from a piece of SampleNdRange (v4) by Bryan Palmintier 2016
%
% see also:
%  RealRangeFromInteger

% HISTORY
% ver     date    time       who     changes made
% ---  ---------- -----  ----------- ---------------------------------------
%   4  2017-07-16 20:47  BryanP      BUGFIX: properly handle zero and negative ranges with zero stepsizes 
%   3  2017-07-16 17:27  BryanP      Specify format as shortG for consistant doctests 
%   2  2017-07-16 17:17  BryanP      BUGFIX: correct offset when min value not a multiple of step_size. Also update integer_max for 1-based indexing 
%   1  2016-07-08 00:40  BryanP      Adapted from code in SampleNdRange v4

        if nargin < 3
            continuous_chunks = 10;
        end
        
        % Compute step sizes for any continuous values
        if any(step_size == 0)
            continuous_mask = (step_size == 0);
            step_size(continuous_mask) = ...
                (min_max(2, continuous_mask) - min_max(1, continuous_mask)) ./ (continuous_chunks);
            % For any step sizes that are still zero (b/c min=max) or
            % negative (b/c min<max), force step_size to 1 to avoid divide
            % by zero errors or invalid states
            step_size(step_size <= 0) = 1;
        end
            
        %Convert the discrete sample range to a set of integers
        d_min = round(min_max(1,:)./step_size, 0);
        d_max = round(min_max(2,:)./step_size, 0);
        
        %Store range, add one to ensure we get both min and max
        integer_max = d_max - d_min + 1;
        %Force any with min > max to zero (+1)
        integer_max(integer_max <= 0) = 1; 

        offset = min_max(1,:);
end

