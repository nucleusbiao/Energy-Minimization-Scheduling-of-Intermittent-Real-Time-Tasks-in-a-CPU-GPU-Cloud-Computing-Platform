function gpu_valid = interpretK(k, num_gpu)

gpu_set_index = k -1;
b=dec2bin(gpu_set_index, num_gpu);
gpu_valid = [];
for i = 1:length(b)
    x = str2num(b(i));
    if x
        gpu_valid = [1, gpu_valid];
    else
        gpu_valid = [0, gpu_valid];
    end
end