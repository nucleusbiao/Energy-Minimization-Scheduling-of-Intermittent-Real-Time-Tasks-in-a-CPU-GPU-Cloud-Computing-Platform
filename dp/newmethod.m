clc
clear
%%  任务在这里修改就行，插入第一列没有资源情况下，时间功耗无穷大。格式[inf 一个线程时间 2个线程时间 ... gpu1时间 gpu2时间]
%%  结果看Assign，[]内四个数据分别表示任务号，任务周期，分配线程数，gpu号。例如[2,15,3,0]表示任务2分配在3个线程的executor上。最后两位仅有1个0
%任务n=7 线程m=3,gpu数量M=2
Time = [inf,13,10,8,10,7 ; inf,7,6,5,6,5 ; inf,10,8,6,5,7;
        inf,12,11,7,9,5 ; inf,15,14,13,9,7 ; inf,9,7,6,11,13;
        inf 11,9,7,6,10];
Energy = [inf,43,37,33,24,20; inf,23,21,19,18,25; inf,30,26,23,21,29;
          inf,38,35,32,40,25; inf,33,31,27,19,22; inf,15,14,13,20,22;
          inf 28,23,21,13,19];
Periods = [10,15,6,6,15,12,7]; %截止时间等于周期
num_thread = 3;
num_gpu = 2; 
gama = 50;
%% T=[];E=[];
%%
Assign = {};%创建一个空的元胞数组
value = {};
value_temp = [];
for i=1:size(Periods,2)
    for j=1:(num_thread+1)*2^num_gpu
        resource = j;
        m = mod(resource,num_thread+1);
        if m == 0
            m=num_thread+1;
        end
        
        if eq(i,1)                               %第一行 第一个任务
            [Assign,value]=Assign_in_empty(i,j,resource,num_thread,Periods,Time,Energy,m,Assign,value,gama);
        else                                     %任务数 i>1 
             if isempty(Assign{i-1}{j}) 
                 [Assign,value]=Assign_in_empty(i,j,resource,num_thread,Periods,Time,Energy,m,Assign,value,gama);  
            else
                newjob = [i,Periods(i)];
                
                %添加到原有executor上的情况
                valueTemp = [];
                for k = 1:size(Assign{i-1}{j}, 2) %有多少个executor  
                    executor = Assign{i-1}{j}{k};
                    if executor(end) == 0  % executor执行器为cpu
                        scheduleFlag = responseTimeCpu(executor,newjob,Time,Periods);
                        
                    else 
                        scheduleFlag = responseTimeGpu(executor,newjob,Time,Periods,num_thread);  %在已有的executor上验证能否容纳新的任务
                    end
                    
                    if scheduleFlag    %如果能分配，找出任务放在哪个executor上能让“该任务的功耗”最小，即为总功耗最小
                        P_v = 0;
                        e = size(executor,1);
                        if executor(end) == 0   
                            P_v = P_v + Energy(executor(e,1),executor(e,end-1)+1);
                        else
                            P_v = P_v + Energy(executor(e,1),num_thread+executor(e,end)+1);
                        end
                            valueTemp = [valueTemp;1/P_v];
                    else
                        valueTemp = [valueTemp;0];   %不能放下，价值无穷大，最后寻找最小值 value == energy
                    end
                end
                
                [valueMax, index] = max(valueTemp);      %找出能放下的价值最大的executor序号 valueMax记录最大值，index
                if valueMax == 0                         %记录最大值的索引
                    valueMaxMerge = value{i-1}{j};        %不能放下新任务
                else
                    assignTemp = Assign{i-1}{j};
                    if assignTemp{index}(end) == 0
                        assignTemp{index} = [assignTemp{index};[newjob,assignTemp{index}(end-1),0]];  %在这个executor处插入任务
                    else
                        assignTemp{index} = [assignTemp{index};[newjob,0,assignTemp{index}(end)]];  %gpu的executor
                    end
                    valueMaxMerge = Compute_TotalValue(assignTemp,Energy,num_thread,gama);       %计算合并情况下的总功耗
                end
                            
                %分的情况，创建新的executor。 1,线程创建  2，gpu创建
                resourceAssigned = 0;
                value_Sep_max = 0;
                
                if ((m == 1) && (resource ~= 3*(num_thread+1)+1)) || (resource == 2) % J=1,2,6,11, 无法创建新的executor
                    value_Sep_Temp = 0;
                    value_Sep_max = value_Sep_Temp;
                    resourceAssigned = 0;
                    
                elseif resource <= 1*(num_thread+1)  % 3 --> num_thread+1
                    for k=1:m-2
                        if Time(i,k+1) <= Periods(i) 
                            resource_left = resource-1-k;
                            assignTemp = Assign{i-1}{resource_left+1};
                            assignTemp{end+1} = [newjob,k,0];
                            value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                            if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                                value_Sep_max = value_Sep_Temp;
                                resourceAssigned = k;
                            end
                        end
                    end                  
                    
                elseif resource <= 2*(num_thread+1) 
                    %两种分法 gpu上或者cpu上
                    % 1,cpu上
                    for k=1:(m-1)
                        if Time(i,k+1) <= Periods(i) 
                            assignTemp = Assign{i-1}{j-k};
                            assignTemp{end+1} = [newjob,k,0];
                            value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                            if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                                value_Sep_max = value_Sep_Temp;
                                resourceAssigned = k;
                            end
                        end
                    end
                    % 2,在gpu1上
                    if Time(i,num_thread+2) <= Periods(i)
                        assignTemp = Assign{i-1}{m};
                        assignTemp{end+1} = [newjob,0,1];
                        value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                        if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                                value_Sep_max = value_Sep_Temp;
                                resourceAssigned = 1024;        % 1024只是作区分用，代表gpu1，和线程数k区分
                        end
                    end
                    
                elseif resource <= 3*(num_thread+1)
                    % 1,cpu上
                    for k=1:(m-1)
                        if Time(i,k+1) <= Periods(i)
                            assignTemp = Assign{i-1}{j-k};
                            assignTemp{end+1} = [newjob,k,0];
                            value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                            if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                                value_Sep_max = value_Sep_Temp;
                                resourceAssigned = k;
                            end
                        end
                    end
                    % 2,在gpu2上
                    if Time(i,num_thread+3) <= Periods(i)
                        assignTemp = Assign{i-1}{m};
                        assignTemp{end+1} = [newjob,0,2];
                        value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                        if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                                value_Sep_max = value_Sep_Temp;
                                resourceAssigned = 2048;        % 2048只是作区分用，代表gpu2，和线程数k区分
                        end
                    end
                    
                elseif resource == 3*(num_thread+1)+1  
                    %在gpu1上
                    if Time(i,num_thread+2) <= Periods(i)
                        assignTemp = Assign{i-1}{j-1*(num_thread+1)};
                        assignTemp{end+1} = [newjob,0,1];
                        value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                        if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                            value_Sep_max = value_Sep_Temp;
                            resourceAssigned = 1024;
                        end
                    end
                    %在gpu2上
                    if Time(i,num_thread+3) <= Periods(i)
                        assignTemp = Assign{i-1}{j-2*(num_thread+1)};
                        assignTemp{end+1} = [newjob,0,2];
                        value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                        if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                            value_Sep_max = value_Sep_Temp;
                            resourceAssigned = 2048;
                        end
                    end
                    
                    
                else
                    % 1,cpu上
                    for k=1:(m-1)
                        if Time(i,k+1) <= Periods(i)
                            assignTemp = Assign{i-1}{j-k};
                            assignTemp{end+1} = [newjob,k,0];
                            value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                            if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                                value_Sep_max = value_Sep_Temp;
                                resourceAssigned = k;
                            end
                        end
                    end
                    % 2,在gpu1上
                    if Time(i,num_thread+2) <= Periods(i)
                        assignTemp = Assign{i-1}{j-(num_thread+1)};
                        assignTemp{end+1} = [newjob,0,1];
                        value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                        if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                                value_Sep_max = value_Sep_Temp;
                                resourceAssigned = 1024;        % 1024只是作区分用，代表gpu1，和线程数k区分
                        end
                    end
                    
                    % 3,在gpu2上
                    if Time(i,num_thread+3) <= Periods(i)
                        assignTemp = Assign{i-1}{j-2*(num_thread+1)};
                        assignTemp{end+1} = [newjob,0,2];
                        value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                        if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                                value_Sep_max = value_Sep_Temp;
                                resourceAssigned = 2048;        % 1024只是作区分用，代表gpu1，和线程数k区分
                        end
                    end
                end
                
%------------------------------------------------------------------------%     
                
                %分或者合的不同处理
                if eq(resourceAssigned,0) && (valueMax > 1e-3)  % 合的情况  
                    Assign{i}{j} = Assign{i-1}{j};
                    executor = Assign{i}{j}{index}; 
                    if executor(end,end) == 0
                        executor = [executor; newjob, executor(end,end-1),0];
                    else
                        executor = [executor; newjob,0,executor(end,end)];
                    end                        
                    Assign{i}{j}{index} = executor;    
                    value{i}{j} = valueMaxMerge;
                    
                elseif ~eq(resourceAssigned,0) % 分的情况
                    
                    if resource <= 1*(num_thread+1)                      
                        Assign{i}{j} = Assign{i-1}{resource-resourceAssigned};
                        size_executor = size(Assign{i}{j}, 2);  %已有虚拟机数
                        executor = [newjob, resourceAssigned,0];
                        Assign{i}{j}{size_executor+1} = executor;   
                        value{i}{j} = value_Sep_max;
                        
                    elseif resource <= 2*(num_thread+1)
                        if resourceAssigned == 1024    %创Gpu1
                            Assign{i}{j} = Assign{i-1}{resource-1*(num_thread+1)};
                            size_executor = size(Assign{i}{j}, 2);  %已有虚拟机数
                            executor = [newjob, 0,1];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        else
                            Assign{i}{j} = Assign{i-1}{resource-resourceAssigned};
                            size_executor = size(Assign{i}{j}, 2);  %已有虚拟机数
                            executor = [newjob, resourceAssigned,0];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        end
                        
                    elseif resource <= 3*(num_thread+1)
                        if resourceAssigned == 2048    %创Gpu2
                            Assign{i}{j} = Assign{i-1}{resource-2*(num_thread+1)};
                            size_executor = size(Assign{i}{j}, 2);  %已有虚拟机数
                            executor = [newjob, 0,2];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        else
                            Assign{i}{j} = Assign{i-1}{resource-resourceAssigned};
                            size_executor = size(Assign{i}{j}, 2);  %已有虚拟机数
                            executor = [newjob, resourceAssigned,0];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        end
                        
                    elseif resource == 3*(num_thread+1)+1
                        if resourceAssigned == 1024
                            Assign{i}{j} = Assign{i-1}{resource-1*(num_thread+1)};
                            size_executor = size(Assign{i}{j}, 2);  %已有虚拟机数
                            executor = [newjob,0,1];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        else 
                            Assign{i}{j} = Assign{i-1}{resource-2*(num_thread+1)};
                            size_executor = size(Assign{i}{j}, 2);  %已有虚拟机数
                            executor = [newjob,0,2];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        end
                        
                    else
                        if resourceAssigned == 1024
                            Assign{i}{j} = Assign{i-1}{resource-1*(num_thread+1)};
                            size_executor = size(Assign{i}{j}, 2);  %已有虚拟机数
                            executor = [newjob,0,1];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        elseif resourceAssigned == 2048 
                            Assign{i}{j} = Assign{i-1}{resource-2*(num_thread+1)};
                            size_executor = size(Assign{i}{j}, 2);  %已有虚拟机数
                            executor = [newjob,0,2];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        else
                            Assign{i}{j} = Assign{i-1}{resource-resourceAssigned};
                            size_executor = size(Assign{i}{j}, 2);  %已有虚拟机数
                            executor = [newjob, resourceAssigned,0];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        end
                    end
                           
                else % 合不进，分不??
                    Assign{i}{j} = Assign{i-1}{j}; 
                    value{i}{j} = value{i-1}{j};
                end
            end
        end
    end
end