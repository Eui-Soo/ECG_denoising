function output=ECG_load(file_idx)
file_idx=sprintf('%03d',file_idx);
file_idx=strcat(file_idx,'*.txt');

if sum(strcmp(file_idx,{'001*.txt','002*.txt','003*.txt','004*.txt'}))
    cd 'ECG sample 1';
    file=dir(file_idx);
    cd ..
else
    cd 'ECG sample 2';
    file=dir(file_idx);
    cd ..
end

first_sample={'001C-2-A6A6_20191010_193128_af0_65.16_sq0_71.35_hr72.55_self_oriecg.txt',...
    '002chanyoung.park@i-skylabs.com_1571644641769_C-2-A6A6_ecg.txt',...
    '003HM_190502_big60Hz_1556762741128_test_ecg.txt',...
    '004HM_190502_small60Hz_1556763748901_test_ecg.txt'};
if sum(strcmp(file.name,first_sample))
    addpath('ECG sample 1');
    f=fopen(file.name);
    temp = textscan(f,'%f');
    fclose(f);
    output = temp{1}/1e4;
else
    addpath('ECG sample 2');
    f=fopen(file.name);
    temp = textscan(f,'%f');
    fclose(f);
    output = temp{1}/1e3;
end