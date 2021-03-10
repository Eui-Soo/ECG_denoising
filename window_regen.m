function [new_win]=window_regen(L_win,threshold,N_adj)
L=length(L_win);
% threshold=31;%round(max(L_win)/2)-5;
% local_min=threshold;
new_win=L_win;
local_state=0;
conversion_state=0;
for n=1:L    
   if L_win(n)<threshold&&local_state==1
       min_cnt=min_cnt+1;
   elseif L_win(n)>=threshold&&local_state==1
       end_idx=n-1;
       local_state=0;
       conversion_state=1;
   end
   
   if L_win(n)<threshold&&local_state==0
       start_idx=n;
       min_cnt=1;
       local_state=1;       
   end
   
   if conversion_state==1
       c_range=round(min_cnt/N_adj);
       new_win(start_idx:start_idx+c_range)=threshold;%L_win(start_idx-1);
       new_win(end_idx-c_range+1:end_idx)=threshold;%L_win(end_idx+1);
       conversion_state=0;
   end  
end