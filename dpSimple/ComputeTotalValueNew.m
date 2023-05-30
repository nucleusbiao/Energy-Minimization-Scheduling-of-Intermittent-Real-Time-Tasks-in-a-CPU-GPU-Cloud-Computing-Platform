function value = ComputeTotalValueNew(assignTemp, Energy, num_thread, gama, Time, Periods, thread_in_use, static_power, alpha_cpu, alpha_gpu)
P_s = static_power;
num = 0;
for i=1:size(assignTemp,2) %executor个数
    num = num + size(assignTemp{i},1);
    for j=1:size(assignTemp{i},1)  %每一个executor中的任务数行数
        resource = assignTemp{i}(j,3:end-1);
        task_id = assignTemp{i}(j,1);
        resource_id = resource(assignTemp{i}(j,end));
        
        if resource_id <= num_thread+1 % 确定是用CPU线程
            power = alpha_cpu*thread_in_use(task_id, resource_id-1)*Time(task_id, resource_id)/Periods(task_id);
        else % 若是用GPU
            power = alpha_gpu(resource_id-1-num_thread)*Time(task_id, resource_id)/Periods(task_id);
        end
        P_s = P_s + power;
        
        % P_s = P_s + Energy(assignTemp{i}(j,1),resource(assignTemp{i}(j,end)));
    end
end
value = num*gama + 1/P_s;
        