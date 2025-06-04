function [G] = Real_carrier_sensing_graph_HD_plus(x, y, P, S, alpha, G_0, K, arm_choose)
%  P: transmission powers
%  S: carrier sensing thresholds
G = zeros(K,K);
S = S*ones(1,K);
P = P*ones(1,K);
for i = 1:K
    for j = 1:K
        Gamma = (S(i)/(P(j)*G_0))^(-1/alpha); %the semi-major axis of Ellipse area
        Temp0 = sqrt((x(1,i)-x(1,j))^2 + (y(1,i)-y(1,j))^2);%Tx_i -> Tx_j            
        if Temp0 <= Gamma && (arm_choose(i) == arm_choose(j))  %The latter condition refers to the conflict between those who choose the same channel number
            G(i,j)=1;
            G(j,i) = G(i,j);
        end      
    end
    G(i,i) = 0;
end
end
