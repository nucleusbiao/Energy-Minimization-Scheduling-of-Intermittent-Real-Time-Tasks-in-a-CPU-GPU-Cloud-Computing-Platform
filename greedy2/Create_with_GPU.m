function [AssignCreateGPU,valueCreateGPU]=Create_with_GPU(i,k,j,gpu_valid,num_thread,Periods,Time,Energy,Assign,value,gama, thread_in_use, static_power, alpha_cpu, alpha_gpu)
% 用GPU创建一个新的executor

row = i;
column = (k-1)*(num_thread+1) + j; 

resource = [j]; % CPU threads

for q = 1:size(gpu_valid, 2)
    if gpu_valid(q)
        resource = [resource, num_thread+1+q]; % adding GPU index
    end
end

valueCreateGPU = value;
valueCreateGPU{row}{column} = value{row-1}{column};
AssignCreateGPU = Assign;
AssignCreateGPU{row}{column} = Assign{row-1}{column};

for q = 2:size(resource, 2)
    gpu_index = resource(q);
    if Time(row, gpu_index) <= Periods(row)    
        AssignTemp = Assign;
        gpu_valid_temp = gpu_valid;
        gpu_valid_temp(gpu_index-num_thread-1) = 0;
        preGPU_index = 0;
        for p = 1:size(gpu_valid_temp, 2)
            preGPU_index = preGPU_index + gpu_valid_temp(p)*2^(p-1);
        end   
        AssignTemp{row}{column} = Assign{row-1}{preGPU_index*(num_thread+1) + j};
        AssignTemp{row}{column}{end+1} = [i,Periods(i),resource,q];
        oneAssign = AssignTemp{row}{column};
        value = ComputeTotalValueNew(oneAssign,Energy,num_thread,gama, Time, Periods, thread_in_use, static_power, alpha_cpu, alpha_gpu);
        if value > valueCreateGPU{row}{column}
            AssignCreateGPU{row}{column} = oneAssign;
            valueCreateGPU{row}{column} = value;
        end
    end
end