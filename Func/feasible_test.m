function [flag] = feasible_test(state, G, K)
% note that infeasible state occur if there are two or more '1' in a test state;
%   state : test state
%   G : carrier sensing graph
%   K : the number of links
flag =1;
Temp = bitget(state, K:-1:1);
if sum(Temp) > 1
    Index = find(Temp > 0);
    L = length(Index);
    Index_0 = [Index, Index(1)]; % For example, test state (1 1 1), the Index_0 = [1 2 3 1];  
    for n = 1:L
        for m = n+1:L+1
            if G(Index_0(n), Index_0(m)) == 1
                flag = 0;
                break;
            end
        end
    end
end
end

