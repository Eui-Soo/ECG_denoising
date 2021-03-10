function y=circ_shift(x,p)
y=zeros(size(x));
if p>0
   y(1:length(x)-p)=x(p+1:end);
   y(length(x)-p+1:end)=x(1:p);
elseif p<0
   y(1:abs(p))=x(end-p+1:end);
   y(abs(p)+1:end)=x(1:end-p);
else
    y=x;
end