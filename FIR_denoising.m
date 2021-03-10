function [denoising_ECG]=FIR_denoising(G,l,L_win,delay)

% Design of smoothing filter coefficients
[flt_length, flt_coeff] = fltcoeff_gen(l);

L_win = circ_shift(L_win,delay);

denoising_ECG = G;
for idx = max(L_win)+1:length(G)-max(L_win)
    flt = flt_coeff{flt_length==L_win(idx)};
    p = (length(flt)-1)/2;
    u = G(idx-p:idx+p);
    denoising_ECG(idx) = flt*u;
end
