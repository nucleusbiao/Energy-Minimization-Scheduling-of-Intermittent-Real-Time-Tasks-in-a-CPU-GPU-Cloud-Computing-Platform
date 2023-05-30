clc
clear
%%  �����������޸ľ��У������һ��û����Դ����£�ʱ�书������󡣸�ʽ[inf һ���߳�ʱ�� 2���߳�ʱ�� ... gpu1ʱ�� gpu2ʱ��]
%%  �����Assign��[]���ĸ����ݷֱ��ʾ����ţ��������ڣ������߳�����gpu�š�����[2,15,3,0]��ʾ����2������3���̵߳�executor�ϡ������λ����1��0
%����n=7 �߳�m=3,gpu����M=2
Time = [inf,13,10,8,10,7 ; inf,7,6,5,6,5 ; inf,10,8,6,5,7;
        inf,12,11,7,9,5 ; inf,15,14,13,9,7 ; inf,9,7,6,11,13;
        inf 11,9,7,6,10];
Energy = [inf,43,37,33,24,20; inf,23,21,19,18,25; inf,30,26,23,21,29;
          inf,38,35,32,40,25; inf,33,31,27,19,22; inf,15,14,13,20,22;
          inf 28,23,21,13,19];
Periods = [10,15,6,6,15,12,7]; %��ֹʱ���������
num_thread = 3;
num_gpu = 2; 
gama = 50;
%% T=[];E=[];
%%
Assign = {};%����һ���յ�Ԫ������
value = {};
value_temp = [];
for i=1:size(Periods,2)
    for j=1:(num_thread+1)*2^num_gpu
        resource = j;
        m = mod(resource,num_thread+1);
        if m == 0
            m=num_thread+1;
        end
        
        if eq(i,1)                               %��һ�� ��һ������
            [Assign,value]=Assign_in_empty(i,j,resource,num_thread,Periods,Time,Energy,m,Assign,value,gama);
        else                                     %������ i>1 
             if isempty(Assign{i-1}{j}) 
                 [Assign,value]=Assign_in_empty(i,j,resource,num_thread,Periods,Time,Energy,m,Assign,value,gama);  
            else
                newjob = [i,Periods(i)];
                
                %��ӵ�ԭ��executor�ϵ����
                valueTemp = [];
                for k = 1:size(Assign{i-1}{j}, 2) %�ж��ٸ�executor  
                    executor = Assign{i-1}{j}{k};
                    if executor(end) == 0  % executorִ����Ϊcpu
                        scheduleFlag = responseTimeCpu(executor,newjob,Time,Periods);
                        
                    else 
                        scheduleFlag = responseTimeGpu(executor,newjob,Time,Periods,num_thread);  %�����е�executor����֤�ܷ������µ�����
                    end
                    
                    if scheduleFlag    %����ܷ��䣬�ҳ���������ĸ�executor�����á�������Ĺ��ġ���С����Ϊ�ܹ�����С
                        P_v = 0;
                        e = size(executor,1);
                        if executor(end) == 0   
                            P_v = P_v + Energy(executor(e,1),executor(e,end-1)+1);
                        else
                            P_v = P_v + Energy(executor(e,1),num_thread+executor(e,end)+1);
                        end
                            valueTemp = [valueTemp;1/P_v];
                    else
                        valueTemp = [valueTemp;0];   %���ܷ��£���ֵ��������Ѱ����Сֵ value == energy
                    end
                end
                
                [valueMax, index] = max(valueTemp);      %�ҳ��ܷ��µļ�ֵ����executor��� valueMax��¼���ֵ��index
                if valueMax == 0                         %��¼���ֵ������
                    valueMaxMerge = value{i-1}{j};        %���ܷ���������
                else
                    assignTemp = Assign{i-1}{j};
                    if assignTemp{index}(end) == 0
                        assignTemp{index} = [assignTemp{index};[newjob,assignTemp{index}(end-1),0]];  %�����executor����������
                    else
                        assignTemp{index} = [assignTemp{index};[newjob,0,assignTemp{index}(end)]];  %gpu��executor
                    end
                    valueMaxMerge = Compute_TotalValue(assignTemp,Energy,num_thread,gama);       %����ϲ�����µ��ܹ���
                end
                            
                %�ֵ�����������µ�executor�� 1,�̴߳���  2��gpu����
                resourceAssigned = 0;
                value_Sep_max = 0;
                
                if ((m == 1) && (resource ~= 3*(num_thread+1)+1)) || (resource == 2) % J=1,2,6,11, �޷������µ�executor
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
                    %���ַַ� gpu�ϻ���cpu��
                    % 1,cpu��
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
                    % 2,��gpu1��
                    if Time(i,num_thread+2) <= Periods(i)
                        assignTemp = Assign{i-1}{m};
                        assignTemp{end+1} = [newjob,0,1];
                        value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                        if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                                value_Sep_max = value_Sep_Temp;
                                resourceAssigned = 1024;        % 1024ֻ���������ã�����gpu1�����߳���k����
                        end
                    end
                    
                elseif resource <= 3*(num_thread+1)
                    % 1,cpu��
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
                    % 2,��gpu2��
                    if Time(i,num_thread+3) <= Periods(i)
                        assignTemp = Assign{i-1}{m};
                        assignTemp{end+1} = [newjob,0,2];
                        value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                        if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                                value_Sep_max = value_Sep_Temp;
                                resourceAssigned = 2048;        % 2048ֻ���������ã�����gpu2�����߳���k����
                        end
                    end
                    
                elseif resource == 3*(num_thread+1)+1  
                    %��gpu1��
                    if Time(i,num_thread+2) <= Periods(i)
                        assignTemp = Assign{i-1}{j-1*(num_thread+1)};
                        assignTemp{end+1} = [newjob,0,1];
                        value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                        if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                            value_Sep_max = value_Sep_Temp;
                            resourceAssigned = 1024;
                        end
                    end
                    %��gpu2��
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
                    % 1,cpu��
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
                    % 2,��gpu1��
                    if Time(i,num_thread+2) <= Periods(i)
                        assignTemp = Assign{i-1}{j-(num_thread+1)};
                        assignTemp{end+1} = [newjob,0,1];
                        value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                        if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                                value_Sep_max = value_Sep_Temp;
                                resourceAssigned = 1024;        % 1024ֻ���������ã�����gpu1�����߳���k����
                        end
                    end
                    
                    % 3,��gpu2��
                    if Time(i,num_thread+3) <= Periods(i)
                        assignTemp = Assign{i-1}{j-2*(num_thread+1)};
                        assignTemp{end+1} = [newjob,0,2];
                        value_Sep_Temp = Compute_TotalValue(assignTemp,Energy,num_thread,gama);
                        if (value_Sep_Temp > valueMaxMerge) && (value_Sep_Temp > value_Sep_max)
                                value_Sep_max = value_Sep_Temp;
                                resourceAssigned = 2048;        % 1024ֻ���������ã�����gpu1�����߳���k����
                        end
                    end
                end
                
%------------------------------------------------------------------------%     
                
                %�ֻ��ߺϵĲ�ͬ����
                if eq(resourceAssigned,0) && (valueMax > 1e-3)  % �ϵ����  
                    Assign{i}{j} = Assign{i-1}{j};
                    executor = Assign{i}{j}{index}; 
                    if executor(end,end) == 0
                        executor = [executor; newjob, executor(end,end-1),0];
                    else
                        executor = [executor; newjob,0,executor(end,end)];
                    end                        
                    Assign{i}{j}{index} = executor;    
                    value{i}{j} = valueMaxMerge;
                    
                elseif ~eq(resourceAssigned,0) % �ֵ����
                    
                    if resource <= 1*(num_thread+1)                      
                        Assign{i}{j} = Assign{i-1}{resource-resourceAssigned};
                        size_executor = size(Assign{i}{j}, 2);  %�����������
                        executor = [newjob, resourceAssigned,0];
                        Assign{i}{j}{size_executor+1} = executor;   
                        value{i}{j} = value_Sep_max;
                        
                    elseif resource <= 2*(num_thread+1)
                        if resourceAssigned == 1024    %��Gpu1
                            Assign{i}{j} = Assign{i-1}{resource-1*(num_thread+1)};
                            size_executor = size(Assign{i}{j}, 2);  %�����������
                            executor = [newjob, 0,1];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        else
                            Assign{i}{j} = Assign{i-1}{resource-resourceAssigned};
                            size_executor = size(Assign{i}{j}, 2);  %�����������
                            executor = [newjob, resourceAssigned,0];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        end
                        
                    elseif resource <= 3*(num_thread+1)
                        if resourceAssigned == 2048    %��Gpu2
                            Assign{i}{j} = Assign{i-1}{resource-2*(num_thread+1)};
                            size_executor = size(Assign{i}{j}, 2);  %�����������
                            executor = [newjob, 0,2];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        else
                            Assign{i}{j} = Assign{i-1}{resource-resourceAssigned};
                            size_executor = size(Assign{i}{j}, 2);  %�����������
                            executor = [newjob, resourceAssigned,0];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        end
                        
                    elseif resource == 3*(num_thread+1)+1
                        if resourceAssigned == 1024
                            Assign{i}{j} = Assign{i-1}{resource-1*(num_thread+1)};
                            size_executor = size(Assign{i}{j}, 2);  %�����������
                            executor = [newjob,0,1];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        else 
                            Assign{i}{j} = Assign{i-1}{resource-2*(num_thread+1)};
                            size_executor = size(Assign{i}{j}, 2);  %�����������
                            executor = [newjob,0,2];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        end
                        
                    else
                        if resourceAssigned == 1024
                            Assign{i}{j} = Assign{i-1}{resource-1*(num_thread+1)};
                            size_executor = size(Assign{i}{j}, 2);  %�����������
                            executor = [newjob,0,1];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        elseif resourceAssigned == 2048 
                            Assign{i}{j} = Assign{i-1}{resource-2*(num_thread+1)};
                            size_executor = size(Assign{i}{j}, 2);  %�����������
                            executor = [newjob,0,2];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        else
                            Assign{i}{j} = Assign{i-1}{resource-resourceAssigned};
                            size_executor = size(Assign{i}{j}, 2);  %�����������
                            executor = [newjob, resourceAssigned,0];
                            Assign{i}{j}{size_executor+1} = executor;   
                            value{i}{j} = value_Sep_max;
                        end
                    end
                           
                else % �ϲ������ֲ�??
                    Assign{i}{j} = Assign{i-1}{j}; 
                    value{i}{j} = value{i-1}{j};
                end
            end
        end
    end
end