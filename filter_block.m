function output=filter_block(data,filter)
temp = [data((length(filter)-1)/2:-1:1); data; data(end:-1:end-(length(filter)-1)/2)];
out = conv(temp,filter);
output = out(length(filter):end-length(filter));