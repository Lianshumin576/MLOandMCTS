%% BAI
rng(1);
clc;clear;close all;
addpath('../Func')
addpath('../Data')

%==================simulation parameters==========================
%初始化
num_band = 3;
num_ap = 3;
num_sta = 8*[1,1,1]; 
num_channel = [1,1,1];  

x1 = 1:num_channel(1)+1; 
x1 = x1-ones(1,length(x1));
x2 = 1:num_channel(2)+1; 
x2 = x2-ones(1,length(x2));
x3 = 1:num_channel(3)+1; 
x3 = x3-ones(1,length(x3));
[x3,x2,x1] = ndgrid(x3,x2,x1);
arm_space_singlesta = [x1(:) x2(:) x3(:)]; 
arm_space_singlesta = arm_space_singlesta(2:end,:); 

f_c_1 = 2.4e9;
f_c_2 = 5e9;
f_c_3 = 6e9;
G_0_1 = (3e8/f_c_1/(4*pi))^2; 
G_0_2 = (3e8/f_c_2/(4*pi))^2; 
G_0_3 = (3e8/f_c_3/(4*pi))^2; 
TP_temp = 100;
CST_temp = 1e-6;
alpha = 4;
d_max = 5;
Omega = 1;
sigma2_n_dBm = -95; %floor noise level
sigma2_n = 10.^(sigma2_n_dBm/10);
Tran_rate = [20 50 100 150]; %MHz 
sigma2_s1 = Omega*G_0_1*(d_max^(-alpha));
sigma2_s2 = Omega*G_0_2*(d_max^(-alpha));
sigma2_s3 = Omega*G_0_3*(d_max^(-alpha));
TP_dBm = [10, 15, 20; 10, 15, 20; 10, 15, 20];  %transmission power
TP = 10.^(TP_dBm/10);
SNR_index1 = 0.96*TP(1,:)*sigma2_s1./ sigma2_n;
SNR_index2 = 0.96*TP(1,:)*sigma2_s2./ sigma2_n;
SNR_index3 = 0.96*TP(1,:)*sigma2_s3./ sigma2_n;


load location; 
Horizon = 2000;
mc = 1;

    Record_arm = zeros(Horizon, sum(num_sta), mc);
    Record_net_level = zeros(mc, Horizon);
    Record_ap1_sta1_level = zeros(mc, Horizon);
    Record_ap1_sta2_level = zeros(mc, Horizon);
    Record_ap2_sta1_level = zeros(mc, Horizon);
    Record_ap2_sta2_level = zeros(mc, Horizon);
    Record_ap3_sta1_level = zeros(mc, Horizon);
    Record_ap3_sta2_level = zeros(mc, Horizon);
for iteration = 1:mc,iteration
    record_arm = zeros(Horizon, sum(num_sta));
    record_net_level = zeros(1, Horizon);
    record_ap1_sta1_level = zeros(1, Horizon);
    record_ap1_sta2_level = zeros(1, Horizon);
    record_ap2_sta1_level = zeros(1, Horizon);
    record_ap2_sta2_level = zeros(1, Horizon);
    record_ap3_sta1_level = zeros(1, Horizon);
    record_ap3_sta2_level = zeros(1, Horizon);
    fixloc = [];
    Random = [];
    root1 = StateNode_BAI(0, 0, 0, sum(num_sta)-length(fixloc), length(arm_space_singlesta), 0.02/4e8/(sum(num_sta)-length(fixloc)), 1-(1-0.1)^(1/(sum(num_sta)-length(fixloc)))); %  4e8 is for normalization
    root1.travel_time = 1;
    arm = [];
 for T = 1:Horizon,T
[root1, terminal_node1, arm_index] = mcts_plus(root1, sum(num_sta), length(arm_space_singlesta), fixloc, Random); 
ap1arm_index = arm_index(1:num_sta(1));
ap2arm_index = arm_index(num_sta(1)+1:num_sta(1)+num_sta(2));
ap3arm_index = arm_index(num_sta(1)+num_sta(2)+1:end);
C1 = ones(1,24,24);
C2 = ones(1,24,24);
C3 = ones(1,24,24)
for i = 1:24
    
C1(:,:,i) = CS1(i,:);
C2(:,:,i) = CS2(i,:);
C3(:,:,i) = CS3(i,:);
end

throughput_ap1_sta = zeros(1,num_sta(1));
throughput_ap2_sta = zeros(1,num_sta(2));
throughput_ap3_sta = zeros(1,num_sta(3));%ap_level throughput
sta_index_ap1 = zeros(num_band,num_sta(1));
sta_index_ap2 = zeros(num_band,num_sta(2));
sta_index_ap3 = zeros(num_band,num_sta(3));
num_choose1 = zeros(1,num_ap);
num_choose2 = zeros(1,num_ap);
num_choose3 = zeros(1,num_ap);
x_band1 = [];
y_band1 = [];
x_band2 = [];
y_band2 = [];
x_band3 = [];
y_band3 = [];
index_band1 = [];
index_band2 = [];
index_band3 = [];
ap1arm_choose = arm_space_singlesta(ap1arm_index,:);
ap2arm_choose = arm_space_singlesta(ap2arm_index,:);
ap3arm_choose = arm_space_singlesta(ap3arm_index,:);
aparm_choose =  {ap1arm_choose, ap2arm_choose,ap3arm_choose};

%throughput caculation
%1.carrier sensing graph

for i = 1:num_ap
    for j = 1:num_sta(i)
        if aparm_choose{i}(j,1)
            num_choose1(i) = num_choose1(i)+1;
            if i == 1
                sta_index_ap1(1,j) = aparm_choose{i}(j,1);
                index_band1 = [index_band1, aparm_choose{i}(j,1)];
                x_band1 = [x_band1,x1(j)];
                y_band1 = [y_band1,y1(j)];
            end
            if i == 2
                sta_index_ap2(1,j) = aparm_choose{i}(j,1);
                index_band1 = [index_band1, aparm_choose{i}(j,1)];
                x_band1 = [x_band1,x2(j)];
                y_band1 = [y_band1,y2(j)];
            end
            if i == 3
                sta_index_ap3(1,j) = aparm_choose{i}(j,1);
                index_band1 = [index_band1, aparm_choose{i}(j,1)];
                x_band1 = [x_band1,x3(j)];
                y_band1 = [y_band1,y3(j)];
            end
        end
    end
end
for i = 1:num_ap
    for j = 1:num_sta(i)
        if aparm_choose{i}(j,2)
            num_choose2(i)=num_choose2(i)+1;
            if i == 1
                sta_index_ap1(2,j) = aparm_choose{i}(j,2);
                index_band2 = [index_band2, aparm_choose{i}(j,2)];
                x_band2 = [x_band2,x1(j)];
                y_band2 = [y_band2,y1(j)];
            end
            if i == 2
                sta_index_ap2(2,j) = aparm_choose{i}(j,2);
                index_band2 = [index_band2, aparm_choose{i}(j,2)];
                x_band2 = [x_band2,x2(j)];
                y_band2 = [y_band2,y2(j)];
            end
            if i == 3
                sta_index_ap3(2,j) = aparm_choose{i}(j,2);
                index_band2 = [index_band2, aparm_choose{i}(j,2)];
                x_band2 = [x_band2,x3(j)];
                y_band2 = [y_band2,y3(j)];
            end
        end
    end
end
for i = 1:num_ap
    for j = 1:num_sta(i)
        if aparm_choose{i}(j,3)
            num_choose3(i)=num_choose3(i)+1;
            if i == 1
                sta_index_ap1(3,j) = aparm_choose{i}(j,3);
                index_band3 = [index_band3, aparm_choose{i}(j,3)];
                x_band3 = [x_band3,x1(j)];
                y_band3 = [y_band3,y1(j)];
            end
            if i == 2
                sta_index_ap2(3,j) = aparm_choose{i}(j,3);
                index_band3 = [index_band3, aparm_choose{i}(j,3)];
                x_band3 = [x_band3,x2(j)];
                y_band3 = [y_band3,y2(j)];
            end
            if i == 3
                sta_index_ap3(3,j) = aparm_choose{i}(j,3);
                index_band3 = [index_band3, aparm_choose{i}(j,3)];
                x_band3 = [x_band3,x3(j)];
                y_band3 = [y_band3,y3(j)];
            end
        end
    end
end

G1 = Real_carrier_sensing_graph_HD_plus(x_band1, y_band1, TP_temp, CST_temp, alpha, G_0_1, length(y_band1), index_band1);
G2 = Real_carrier_sensing_graph_HD_plus(x_band2, y_band2, TP_temp, CST_temp, alpha, G_0_2, length(y_band2), index_band2);
G3 = Real_carrier_sensing_graph_HD_plus(x_band3, y_band3, TP_temp, CST_temp, alpha, G_0_3, length(y_band3), index_band3);
rho1 = log(1*ones(1,length(y_band1))); %CTMN, logarim access intension
rho2 = log(1*ones(1,length(y_band2))); %CTMN, logarim access intension
rho3 = log(1*ones(1,length(y_band3))); %CTMN, logarim access intension
%2.using the V.D version
Throughput1 = Throughput_SINR_Piecewise_HD(xap, x_band1, yap, y_band1, num_choose1,  G1, TP_temp, SNR_index1, Tran_rate, rho1, d_max, Omega, G_0_1, alpha, sigma2_n, length(y_band1));
Throughput2 = Throughput_SINR_Piecewise_HD(xap, x_band2, yap, y_band2, num_choose2,  G2, TP_temp, SNR_index2, Tran_rate, rho2, d_max, Omega, G_0_2, alpha, sigma2_n, length(y_band2));
Throughput3 = Throughput_SINR_Piecewise_HD(xap, x_band3, yap, y_band3, num_choose3,  G3, TP_temp, SNR_index3, Tran_rate, rho3, d_max, Omega, G_0_3, alpha, sigma2_n, length(y_band3));



%ap_level throught
throughput_ap1 = sum(Throughput1(1:num_choose1(1)))+sum(Throughput2(1:num_choose2(1)))+sum(Throughput3(1:num_choose3(1)));
throughput_ap2 = sum(Throughput1(1+num_choose1(1):num_choose1(1)+num_choose1(2)))+sum(Throughput2(1+num_choose2(1):num_choose2(1)+num_choose2(2)))+sum(Throughput3(1+num_choose3(1):num_choose3(1)+num_choose3(2)));
throughput_ap3 = sum(Throughput1(1+num_choose1(1)+num_choose1(2):num_choose1(1)+num_choose1(2)+num_choose1(3)))...
+sum(Throughput2(1+num_choose2(1)+num_choose2(2):num_choose2(1)+num_choose2(2)+num_choose2(3)))+sum(Throughput3(1+num_choose3(1)+num_choose3(2):num_choose3(1)+num_choose3(2)+num_choose3(3)));
throughput = throughput_ap1+throughput_ap2+throughput_ap3;
num_choose = num_choose1+num_choose2+num_choose3;
root1.backpropogate(terminal_node1, throughput/4e8);% /4e8 is  for normalizing



%ap1_sta_level throught
for i = 1:num_choose1(1)
   k = find(sta_index_ap1(1,:));
   throughput_ap1_sta = throughput_ap1_sta + Throughput1(i)*[zeros(1,k(i)-1),1,zeros(1,num_sta(1)-k(i))];
end
for i = 1:num_choose2(1)
   k = find(sta_index_ap1(2,:));
   throughput_ap1_sta = throughput_ap1_sta + Throughput2(i)*[zeros(1,k(i)-1),1,zeros(1,num_sta(1)-k(i))];
end
for i = 1:num_choose3(1)
   k = find(sta_index_ap1(3,:));
   throughput_ap1_sta = throughput_ap1_sta + Throughput3(i)*[zeros(1,k(i)-1),1,zeros(1,num_sta(1)-k(i))];
end

%ap2_sta_level throught
for i = 1:num_choose1(2)
   k = find(sta_index_ap2(1,:));
   throughput_ap2_sta = throughput_ap2_sta + Throughput1(num_choose1(1)+i)*[zeros(1,k(i)-1),1,zeros(1,num_sta(2)-k(i))];
end
for i = 1:num_choose2(2)
   k = find(sta_index_ap2(2,:));
   throughput_ap2_sta = throughput_ap2_sta + Throughput2(num_choose2(1)+i)*[zeros(1,k(i)-1),1,zeros(1,num_sta(2)-k(i))];
end
for i = 1:num_choose3(2)
   k = find(sta_index_ap2(3,:));
   throughput_ap2_sta = throughput_ap2_sta + Throughput3(num_choose3(1)+i)*[zeros(1,k(i)-1),1,zeros(1,num_sta(2)-k(i))];
end

%ap3_sta_level throught
for i = 1:num_choose1(3)
   k = find(sta_index_ap3(1,:));
   throughput_ap3_sta = throughput_ap3_sta + Throughput1(num_choose1(1)+num_choose1(2)+i)*[zeros(1,k(i)-1),1,zeros(1,num_sta(3)-k(i))];
end
for i = 1:num_choose2(3)
   k = find(sta_index_ap3(2,:));
   throughput_ap3_sta = throughput_ap3_sta + Throughput2(num_choose2(1)+num_choose2(2)+i)*[zeros(1,k(i)-1),1,zeros(1,num_sta(3)-k(i))];
end
for i = 1:num_choose3(3)
   k = find(sta_index_ap3(3,:));
   throughput_ap3_sta = throughput_ap3_sta + Throughput3(num_choose3(1)+num_choose3(2)+i)*[zeros(1,k(i)-1),1,zeros(1,num_sta(3)-k(i))];
end
record_net_level(T) = throughput;
record_ap1_sta1_level(T) = throughput_ap1_sta(1);
record_ap1_sta2_level(T) = throughput_ap1_sta(2);
record_ap2_sta1_level(T) = throughput_ap2_sta(1);
record_ap2_sta2_level(T) = throughput_ap2_sta(2);
record_ap3_sta1_level(T) = throughput_ap3_sta(1);
record_ap3_sta2_level(T) = throughput_ap3_sta(2);
record_arm(T,:) = arm_index;
 end
 Record_net_level(iteration,:) = record_net_level;
 Record_ap1_sta1_level(iteration,:) = record_ap1_sta1_level;
 Record_ap1_sta2_level(iteration,:) = record_ap1_sta2_level;
 Record_ap2_sta1_level(iteration,:) = record_ap2_sta1_level;
 Record_ap2_sta2_level(iteration,:) = record_ap2_sta2_level;
 Record_ap3_sta1_level(iteration,:) = record_ap3_sta1_level;
 Record_ap3_sta2_level(iteration,:) = record_ap3_sta2_level;
 Record_arm(:,:,iteration) = record_arm;
end

save BAI_mc1000_T2000_rng1 Record_arm Record_net_level Record_ap1_sta1_level Record_ap1_sta2_level Record_ap2_sta1_level Record_ap2_sta2_level Record_ap3_sta1_level Record_ap3_sta2_level
