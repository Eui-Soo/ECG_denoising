clear

% load ma
load bw
% load em

load data101_N25000
% load data100_N25000
%% parameter
order=6; % FIR smoothing order
max_L=117;% FIR smoothing, filter max length
Num_comp=90;% AFD smoothing, Number of components
total_time=30;
N_win=15; % 1 2 3 5 6 10 15 30
threshold=41;
N_adj=4;
SNR=10;
fs=Fs;
%% refine data and noise
ecg=ecg(1:fs*total_time)-mean(ecg);
if exist('bw_noise')==1 && exist('ma_noise')==1
    bw_idx=randi([1 length(bw_noise(:,1))-length(ecg)]);
    ma_idx=randi([1 length(ma_noise(:,1))-length(ecg)]);
    bw_noise=bw_noise(bw_idx:bw_idx+length(ecg)-1,1);
    ma_noise=ma_noise(ma_idx:ma_idx+length(ecg)-1,1);
    noise_temp=bw_noise+ma_noise*4;
elseif exist('bw_noise')==1
    bw_idx=randi([1 length(bw_noise(:,1))-length(ecg)]);
    noise_temp=bw_noise(bw_idx:bw_idx+length(ecg)-1,1);
elseif exist('ma_noise')==1
    ma_idx=randi([1 length(ma_noise(:,1))-length(ecg)]);
    noise_temp=ma_noise(ma_idx:ma_idx+length(ecg)-1,1);
elseif exist('em_noise')==1
    em_idx=randi([1 length(em_noise(:,1))-length(ecg)]);
    noise_temp=em_noise(em_idx:em_idx+length(ecg)-1,1);
end
G_origin=ecg;

%% add noise
ecg_pwr=mean(abs(ecg).^2);
if exist('bw_noise')==1 || exist('ma_noise')==1 || exist('em_noise')==1
    noise_pwr=mean(abs(noise_temp(1:length(ecg),1)).^2);
    noise_temp=noise_temp/sqrt(noise_pwr);    
    noise=sqrt(ecg_pwr*10.^(-SNR/10)).*noise_temp;
    ecg_noised=ecg+noise(1:length(ecg),1);
else
    ecg_noised=ecg+sqrt(ecg_pwr*10^(-SNR/10))*randn(size(ecg));
end


%% filter design
load hpf121_360Hz
win_hpf=hpf;
tap=814;
F_cut_high = 0.63; % in Hz
hpf = firls(tap,[0 0.02 F_cut_high fs/2]/fs*2,[0 0 1 1],[100 1]).';
fn = 60; % stopband frequency
hbw = 1.1; % passband쪽에서 stopband의 half bandwidth
hbw2 = 0.01; % stopband쪽에서 stopband의 half bandwidth
bsf = firls(tap,[0 fn-hbw fn-hbw2 fn+hbw2 fn+hbw fs/2]/fs*2,[1 1 0 0 1 1]).';
%% filtering
% DC block filter
data_dc=filter_block(ecg_noised,hpf);
% 60Hz filter
data_60=filter_block(data_dc,bsf);
data_filter_out=data_60;
data_win_input=filter_block(filter_block(ecg_noised,win_hpf),bsf);

%% denoising
denosing_input=data_filter_out;
win_input=FIR_norm(data_win_input,N_win,fs);

warning('off','all');
[L_win,delay]=window_length(win_input,fs,0,max_L,tap/2);
new_win=window_regen(L_win,threshold,N_adj);
FIR_ECG=FIR_denoising(denosing_input,order,new_win,delay);
warning('on','all');

AFD_ECG=AFD_denoising(denosing_input',Num_comp);

%% plot ECG denoising
range=tm(tap/2+1:fs*total_time-tap/2);
figure(1);hold off;
subplot(3,1,1)
plot(range,data_filter_out(tap/2+1:end-tap/2),'k')
grid on
xlabel('time(s)')
axis([range(1) range(end) min(data_filter_out(tap/2+1:end-tap/2))-0.5 max(data_filter_out(tap/2+1:end-tap/2))+0.5])
subplot(3,1,2)
plot(range,FIR_ECG(tap/2+1:end-tap/2),'b')
grid on
xlabel('time(s)')
axis([range(1) range(end) min(FIR_ECG(tap/2+1:end-tap/2))-0.5 max(FIR_ECG(tap/2+1:end-tap/2))+0.5])
subplot(3,1,3)
plot(range,AFD_ECG(tap/2+1:end-tap/2),'r')
grid on
xlabel('time(s)')
axis([range(1) range(end) min(AFD_ECG(tap/2+1:end-tap/2))-0.5 max(AFD_ECG(tap/2+1:end-tap/2))+0.5])

