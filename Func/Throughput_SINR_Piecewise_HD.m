function [Throughput] = Throughput_SINR_Piecewise_HD(xap, x, yap, y, num_choose, G, TP_temp, SNR_index, Tran_rate, rho, d_max, Omega, G_0, alpha, sigma2_n, K)
feasible_states = zeros(2^K, K);
Pro_sta = zeros(1, 2^K);
Throughput = zeros(1,K); % each link's transmission probablilty
TP_temp = TP_temp*ones(1,K);
for i = 1:2^K  %note that the state initiate from (0 0 0)
    if feasible_test(i-1, G, K)
        feasible_states(i,:) = bitget(i-1,K:-1:1);
        Pro_sta(i) = exp(sum(feasible_states(i,:).*rho)); % P_{F^i}
    end
end
Pro_sta = Pro_sta/sum(Pro_sta);
for k = 1:K
    index = find(feasible_states(:,k));
    c_k = zeros(1, length(index) );
    for i = 1:length(index)
        index_s = find(feasible_states(index(i),:));%find the interfence link
        IS_tx = 0;
        if length(index_s) > 1
            for j = 1:length(index_s)
                if index_s(j) ~= k 
                    if index_s(j) < num_choose(1)
                        h_rayleigh = sqrt(Omega/2) *(randn(1,1) + 1i*randn(1,1));
                        Temp_Tx = ( sqrt((x(k)-xap(1))^2 + (y(k)-yap(1))^2) )^(-alpha);   %link  Rx_k <-- Tx_j                   
                        IS_tx =  IS_tx + TP_temp(index_s(j))*G_0*Temp_Tx*norm(h_rayleigh)^2;
                    end
                    if index_s(j) < num_choose(2) && index_s(j) > num_choose(1)
                        h_rayleigh = sqrt(Omega/2) *(randn(1,1) + 1i*randn(1,1));
                        Temp_Tx = ( sqrt((x(k)-xap(2))^2 + (y(k)-yap(2))^2) )^(-alpha);   %link  Rx_k <-- Tx_j                   
                        IS_tx =  IS_tx + TP_temp(index_s(j))*G_0*Temp_Tx*norm(h_rayleigh)^2;
                    end
                    if index_s(j) < num_choose(3) && index_s(j) > num_choose(2)
                        h_rayleigh = sqrt(Omega/2) *(randn(1,1) + 1i*randn(1,1));
                        Temp_Tx = ( sqrt((x(k)-xap(3))^2 + (y(k)-yap(3))^2) )^(-alpha);   %link  Rx_k <-- Tx_j                   
                        IS_tx =  IS_tx + TP_temp(index_s(j))*G_0*Temp_Tx*norm(h_rayleigh)^2;
                    end

                else
                    IS_tx = IS_tx+0;
                end
            end
        else
            IS_tx = IS_tx +0;
        end

        h_rayleigh = sqrt(Omega/2) *(randn(1,1) + 1i*randn(1,1));
        SINR_tx = norm(h_rayleigh)^2*Omega*TP_temp(k)*G_0*(d_max^(-alpha))./(IS_tx + sigma2_n);
        c_k(i)= SINR2Rate(SINR_tx, SNR_index,Tran_rate, K); % Here can be changed
    end    
    Throughput(k) =   sum(c_k.*Pro_sta(index > 0)); %transmission rate multiple Markove stionary distribution
end
end



