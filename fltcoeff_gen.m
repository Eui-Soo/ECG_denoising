function [flt_length, flt_coeff] = fltcoeff_gen(l)

flt_length = 3:2:155; % smoothing filter length
% l = 3; % order of smoothing filter
flt_coeff = cell(length(flt_length),1);
for loop=1:length(flt_length)
    
    N = flt_length(loop);
    p = (N-1)/2; % length of uncausal part of smoothing filter
    
    idx = [-p:N-1-p];
    V = zeros(N,l+1);
    for n=1:N
        for ll=1:l+1
            V(n,ll) = idx(n)^(ll-1);
        end
    end
    J = zeros(l+1,1); J(1) = 1;
    
    W_t = J'*((V'*V+0.001*eye(l+1))\V');
    flt_coeff{loop} = W_t;
end

save SmoothFlt flt_length flt_coeff;

% data = sin(2*pi*0.01*[0:999]);
% data = data.';
% data = data + sqrt(0.5*10^(-10/10))*randn(size(data));
% 
% 
% N = 27;
% p = (N-1)/2;
% flt = flt_coeff{flt_length==N};
% s_data = zeros(size(data));
% for idx=(N+1)/2:length(data)-(N-1)/2
%     u = data(idx+p:-1:idx-p);
%     s_data(idx) = flt*u;
%     
% end
% 
% 
% 
% figure(1); hold off;
% plot(data,'b-');
% hold on;
% plot(s_data,'r-','LineWidth',2);