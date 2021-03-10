clc
clear

%% load data
% file_idx=5;%
ECG_buf=zeros(204,12000);
for file_idx=5:208
    file_idx
    data_tmp=ECG_load(file_idx);
    
    %% parameter
    fs = 400; % sampling clock in Hz
    order=6; % FIR smoothing order
    max_L=117;% FIR smoothing, filter max length
    Num_comp=360;% AFD smoothing, Number of components
    total_time=length(data_tmp)/fs;
    N_win=15; % 1 2 3 5 6 10 15 30
    
    %% filter design
    load hpf121_400Hz
    load bsf81_400Hz
    win_hpf=hpf;
    win_bsf=bsf;
    tap=122;
%     F_cut_high = 0.63; % in Hz
%     hpf = firls(tap,[0 0.02 F_cut_high fs/2]/fs*2,[0 0 1 1],[100 1]).';
%     hpf = firls(tap,[0 0.02 F_cut_high fs/2]/fs*2,[0 0 1 1],[100 1]).';
%     fn = 60; % stopband frequency
%     hbw = 1.1; % passband쪽에서 stopband의 half bandwidth
%     hbw2 = 0.01; % stopband쪽에서 stopband의 half bandwidth
%     bsf = firls(tap,[0 fn-hbw fn-hbw2 fn+hbw2 fn+hbw fs/2]/fs*2,[1 1 0 0 1 1]).';
    
    %% filtering
    % DC bias removal
    data_offset = data_tmp - mean(data_tmp);
    % DC block filter
    data_dc=filter_block(data_offset,hpf);
    % 60Hz filter
    data_60=filter_block(data_dc,bsf);
    
    data_filter_out=data_60;
    data_win_input=filter_block(filter_block(data_offset,win_hpf),win_bsf);
    [a,a_idx]=max(abs(data_win_input));
    if data_win_input(a_idx)<mean(data_win_input)
        data_win_input=-data_win_input;
    end
    warning('on','all');
    data_win_input=data_win_input-min(data_win_input);
    data_win_input=data_win_input/max(data_win_input);
    
    
    ECG_buf(file_idx-4,:)=data_win_input.';
    
    
%     %% denoising
%     denoising_input=data_filter_out;
%     win_input=FIR_norm(data_win_input,N_win,fs);
%     
%     warning('off','all');
%     [L_win,delay]=window_length(win_input,fs,0,max_L,tap/2);
%     FIR_ECG=FIR_denoising(denoising_input,order,L_win,delay);
%     [a,a_idx]=max(abs(FIR_ECG));
%     if FIR_ECG(a_idx)<mean(FIR_ECG)
%         FIR_ECG=-FIR_ECG;
%     end
%     warning('on','all');
%     FIR_ECG=FIR_ECG-min(FIR_ECG);
%     FIR_ECG=FIR_ECG/max(FIR_ECG);
%     
%     
%     ECG_buf(file_idx-4,:)=FIR_ECG.';
%     figure(1);hold off
%     plot(FIR_ECG,'-')
%     figure(2);hold off
%     plot(FIR_ECG(1:8:end),'r')
end
% AFD_ECG=AFD_denoising(denoising_input',Num_comp);
save('ECG_denoising3','ECG_buf')
%% plot denoising ECG

% plot(FIR_ECG)
% hold on
% plot(data_tmp)

% range=linspace(0,total_time,length(data_offset));
%
% figure(1);hold off;
% subplot(3,1,1)
% plot(range,denoising_input,'k')
% grid on
% xlabel('time(s)')
% axis([0+tap/2/fs total_time-tap/2/fs -3 3])
% subplot(3,1,2)
% plot(range,FIR_ECG,'b')
% grid on
% xlabel('time(s)')
% axis([0+tap/2/fs total_time-tap/2/fs -3 3])
% subplot(3,1,3)
% plot(range,AFD_ECG,'r')
% grid on
% xlabel('time(s)')
% axis([0+tap/2/fs total_time-tap/2/fs -3 3])

