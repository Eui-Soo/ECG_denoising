clc
clear
close all

%% load data
file_idx=137;%
data_tmp=ECG_load(file_idx);

%% parameter
fs = 400; % sampling clock in Hz
order=6; % FIR smoothing order
max_L=117;% FIR smoothing, filter max length
Num_comp=360;% AFD smoothing, Number of components
total_time=length(data_tmp)/fs;
N_win=15; % 1 2 3 5 6 10 15 30
threshold=41;
N_adj=4;

%% filter design
load hpf121_400Hz
load bsf81_400Hz
win_hpf=hpf;
win_bsf=bsf;
tap=120;
% F_cut_high = 0.63; % in Hz
% hpf = firls(tap,[0 0.02 F_cut_high fs/2]/fs*2,[0 0 1 1],[100 1]).';
% fn = 60; % stopband frequency
% hbw = 1.1; % passband쪽에서 stopband의 half bandwidth
% hbw2 = 0.01; % stopband쪽에서 stopband의 half bandwidth
% bsf = firls(tap,[0 fn-hbw fn-hbw2 fn+hbw2 fn+hbw fs/2]/fs*2,[1 1 0 0 1 1]).';

%% filtering
% DC bias removal
data_offset = data_tmp - mean(data_tmp);
% DC block filter
data_dc=filter_block(data_offset,hpf);
% 60Hz filter
data_60=filter_block(data_dc,bsf);

data_filter_out=data_60;
data_win_input=filter_block(filter_block(data_offset,win_hpf),win_bsf);

%% denoising
denoising_input=data_filter_out;
win_input=FIR_norm(data_win_input,N_win,fs);

warning('off','all');
[L_win,delay]=window_length(win_input,fs,0,max_L,tap/2);
new_win=window_regen(L_win,threshold,N_adj);
FIR_ECG=FIR_denoising(denoising_input,order,new_win,delay);
warning('on','all');
AFD_ECG=AFD_denoising(denoising_input',Num_comp);

%% plot ECG denoising
range=linspace(0,total_time,fs*total_time);
figure(1);hold off;
subplot(3,1,1)
plot(range,denoising_input,'k')
grid on
xlabel('time(s)')
axis([range(1) range(end) min(denoising_input)-0.2 max(denoising_input)+0.2])
subplot(3,1,2)
plot(range,FIR_ECG,'b')
grid on
xlabel('time(s)')
axis([range(1) range(end) min(FIR_ECG-0.2) max(FIR_ECG)+0.2])
subplot(3,1,3)
plot(range,AFD_ECG,'r')
grid on
xlabel('time(s)')
axis([range(1) range(end) min(AFD_ECG)-0.2 max(AFD_ECG)+0.2])
