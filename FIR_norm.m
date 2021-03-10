function output=FIR_norm(data,N_win,fs)
ob_win=length(data)/fs/N_win;
FIR_pwr_buffer=zeros(1,N_win);
output=zeros(size(data));
for n=1:N_win
    FIR_pwr_buffer(n)=mean(abs(data((n-1)*fs*ob_win+1:n*fs*ob_win)).^2);
end
% FIR_pwr=median(sort(FIR_pwr_buffer));
FIR_pwr=0.2751;
for n=1:N_win
    output((n-1)*fs*ob_win+1:n*fs*ob_win)=data((n-1)*fs*ob_win+1:n*fs*ob_win)*sqrt(FIR_pwr/FIR_pwr_buffer(n));
end