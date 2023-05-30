function [AssignCreateThreads,valueCreateThreads]=Create_with_Threads(i,k,j,gpu_valid,num_thread,Periods,Time,Energy,Assign,value,gama, thread_in_use, static_power, alpha_cpu, alpha_gpu)
% 用CPU线程创建一个新的executor
row = i;
column = (k-1)*(num_thread+1) + j; 
cpuThreads = j;

resource = [j]; % CPU threads

for q = 1:size(gpu_valid, 2)
    if gpu_valid(q)
        resource = [resource, num_thread+1+q]; % adding GPU index
    end
end


valueCreateThreads = value;
valueCreateThreads{row}{column} = value{row-1}{column};
AssignCreateThreads = Assign;
AssignCreateThreads{row}{column} = Assign{row-1}{column};

for q = 2:cpuThreads
    if Time(row,q) <= Periods(row)    
        AssignTemp = Assign;
        AssignTemp{row}{column} = Assign{row-1}{column+1-q};
        AssignTemp{row}{column}{end+1} = [i,Periods(i),q,resource(2:end),1];
        oneAssign = AssignTemp{row}{column};
        value = ComputeTotalValueNew(oneAssign, Energy,  num_thread, gama, Time, Periods, thread_in_use, static_power, alpha_cpu, alpha_gpu);
        if value > valueCreateThreads{row}{column}
            AssignCreateThreads{row}{column} = oneAssign;
            valueCreateThreads{row}{column} = value;
        end
    end
end
