function [c] = SINR2Rate(SINR, SNR_index,Tran_rate, K)
%  SINR: the received SINR
%  c: the transmission rate
Tran_rate = Tran_rate*1e6;
c = Tran_rate(1)*ones(1,length(SINR));
% e = K+6; %useless
for i = 1:length(SINR)
    if SINR(i) > SNR_index(3)
        c(i) = Tran_rate(4);
    elseif SINR(i) > SNR_index(2) && SINR(i) <= SNR_index(3)
        c(i) = Tran_rate(3);
    elseif SINR(i) > SNR_index(1) && SINR(i) <= SNR_index(2)
        c(i) = Tran_rate(2);
    else
        c(i) = Tran_rate(1);
    end
end



