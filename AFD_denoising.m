function [output]=AFD_denoising(G,N)

% Adaptive Fourier decomposition
[an_FFT,coef_FFT,t]=FFT_AFD(G,N,N);
% Make denoised signal
output=real(inverse_AFD(an_FFT,coef_FFT,t));

