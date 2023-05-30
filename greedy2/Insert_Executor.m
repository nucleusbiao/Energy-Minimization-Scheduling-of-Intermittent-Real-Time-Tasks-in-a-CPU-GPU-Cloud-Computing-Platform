function [AssignInsert,valueInsert]=Insert_Executor(i,k,j,gpu_valid,num_thread,Periods,Time,Energy,Assign,value,gama, thread_in_use, static_power, alpha_cpu, alpha_gpu)
% 插入到原有executor中

row = i;
column = (k-1)*(num_thread+1) + j; 

valueInsert = value;
valueInsert{row}{column} = value{row-1}{column};
AssignInsert = Assign;
AssignInsert{row}{column} = Assign{row-1}{column};

executorArrayPre = Assign{row-1}{column};

for q = 1:size(executorArrayPre, 2)
    executorCur =  executorArrayPre{q};
    executorCur = [executorCur; i,Periods(i),executorCur(end,3:end)];
    scheduleFlag = responseTimeNew(executorCur,Time,Periods,num_thread);    
    if scheduleFlag
        oneAssign = Assign{row-1}{column};
        oneAssign{q} = executorCur;
        value = ComputeTotalValueNew(oneAssign,Energy,num_thread,gama, Time, Periods, thread_in_use, static_power, alpha_cpu, alpha_gpu);
        if value > valueInsert{row}{column}
            AssignInsert{row}{column} = oneAssign;
            valueInsert{row}{column} = value;
        end
    end
end