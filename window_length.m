function [L_win, delay]=window_length(ecg,fs,gr,max_L,tap)
ecg(1:tap)=ecg(tap+1);
ecg(end-tap:end)=ecg(end-tap-1);
%% Inputs
% ecg : raw ecg vector signal 1d signal
% fs : sampling frequency e.g. 200Hz, 400Hz and etc
% gr : flag to plot or not plot (set it 1 to have a plot or set it zero not to see any plots
%% Outputs
% N_val : sequence of window sizes
% delay : number of samples which the signal is delayed due to the filtering

%% ================= Now Part of BioSigKit ==================== %%
if ~isvector(ecg)
    error('ecg must be a row or column vector');
end
if nargin < 3
    gr = 1;   % on default the function always plots
end
ecg = ecg(:); % vectorize

%% ======================= Initialize =============================== %
delay = 0;
ax = zeros(1,6);

%% ============ Noise cancelation(Filtering)( 5-15 Hz) =============== %%
if fs == 200
    % ------------------ remove the mean of Signal -----------------------%
    ecg = ecg - mean(ecg);
    %% ==== Low Pass Filter  H(z) = ((1 - z^(-6))^2)/(1 - z^(-1))^2 ==== %%
    %%It has come to my attention the original filter doesnt achieve 12 Hz
    %    b = [1 0 0 0 0 0 -2 0 0 0 0 0 1];
    %    a = [1 -2 1];
    %    ecg_l = filter(b,a,ecg);
    %    delay = 6;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Wn = 12*2/fs;
    N = 3;                                                                  % order of 3 less processing
    [a,b] = butter(N,Wn,'low');                                             % bandpass filtering
    ecg_l = filtfilt(a,b,ecg);
    ecg_l = ecg_l/ max(abs(ecg_l));
    %% ======================= start figure ============================= %%
    if gr
        figure(1); hold off;
        ax(1) = subplot(321);plot(ecg);axis tight;title('Raw signal');
        ax(2)=subplot(322);plot(ecg_l);axis tight;title('Low pass filtered');
    end
    %% ==== High Pass filter H(z) = (-1+32z^(-16)+z^(-32))/(1+z^(-1)) ==== %%
    %%It has come to my attention the original filter doesn achieve 5 Hz
    %    b = zeros(1,33);
    %    b(1) = -1; b(17) = 32; b(33) = 1;
    %    a = [1 1];
    %    ecg_h = filter(b,a,ecg_l);    % Without Delay
    %    delay = delay + 16;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Wn = 5*2/fs;
    N = 3;                                                                  % order of 3 less processing
    [a,b] = butter(N,Wn,'high');                                            % bandpass filtering
    ecg_h = filtfilt(a,b,ecg_l);
    ecg_h = ecg_h/ max(abs(ecg_h));
    if gr
        ax(3)=subplot(323);plot(ecg_h);axis tight;title('High Pass Filtered');
    end
else
    %%  bandpass filter for Noise cancelation of other sampling frequencies(Filtering)
    f1=5;                                                                      % cuttoff low frequency to get rid of baseline wander
    f2=15;                                                                     % cuttoff frequency to discard high frequency noise
    Wn=[f1 f2]*2/fs;                                                           % cutt off based on fs
    N = 3;                                                                     % order of 3 less processing
    [a,b] = butter(N,Wn);                                                      % bandpass filtering
    ecg_h = filtfilt(a,b,ecg);
    ecg_h = ecg_h/ max( abs(ecg_h));
    if gr
        ax(1) = subplot(3,2,[1 2]);plot(ecg);axis tight;title('Raw Signal');
        ax(3)=subplot(323);plot(ecg_h);axis tight;title('Band Pass Filtered');
    end
end
%% ==================== derivative filter ========================== %%
% ------ H(z) = (1/8T)(-z^(-2) - 2z^(-1) + 2z + z^(2)) --------- %
% if fs ~= 200
int_c = 5/(fs*1/40);
b = interp1(1:5,[1 2 0 -2 -1].*(1/8)*fs,1:int_c:5);
% else
%     b = [1 2 0 -2 -1].*(1/8)*fs;
% end

ecg_d = filtfilt(b,1,ecg_h);
ecg_d = ecg_d/max(ecg_d);

if gr
    ax(4)=subplot(324);plot(ecg_d);
    axis tight;
    title('Filtered with the derivative filter');
end
%% ========== Squaring nonlinearly enhance the dominant peaks ========== %%
% ecg_s = ecg_d.^2;
ecg_s = abs(ecg_d);
if gr
    ax(5)=subplot(325);
    plot(ecg_s);
    axis tight;
    title('Squared');
end

%% ============  Moving average ================== %%
%-------Y(nt) = (1/N)[x(nT-(N - 1)T)+ x(nT - (N - 2)T)+...+x(nT)]---------%
MA_len = 0.1;
ecg_m = conv(ecg_s ,ones(1 ,round(MA_len*fs))/round(MA_len*fs));
delay = delay + floor(MA_len*fs)/2;

if gr
    ax(6)=subplot(326);plot(ecg_m);
    axis tight;
    title('Averaged with 30 samples length,Black noise,Green Adaptive Threshold,RED Sig Level,Red circles QRS adaptive threshold');
    axis tight;
end


% figure(3); hold off;
% max_L = 97;
offset = 0;
temp = 0.99*max(ecg_m) - ecg_m;
temp = temp - min(temp) - offset; % make minimum '0'
temp(temp<0) = 0;
temp = round(temp/max(temp)*(max_L+1)/2); % scaling

L_win = 2*temp-1;
for n=1:length(L_win)
    if L_win(n) < 4
        L_win(n) = 3;
    elseif L_win(n) > max_L
        L_win(n) = max_L;
    end
    
end
for n=1:length(L_win)
    if L_win(n) < mean(L_win)-50
        L_win(n) = 3;
    end
end
% plot(N_val);
% axis('tight')

end
