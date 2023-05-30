function [Assign,value] = Assign_in_empty(i,j,resource,num_thread,Periods,Time,Energy,m,Assign,value,gama)
if  resource <= 1*(num_thread+1) 
    if Time(i,resource) <= Periods(i)
        Assign{i}{j}{1} = [i,Periods(i),resource-1,0];% Executor 记录执行的任务和分配的线程数/gpu
        value{i}{j} = 1*gama+1/Energy(i,resource);
    else
        Assign{i}{j} = {};
        value{i}{j} = 0;
    end
                
elseif resource <= 2*(num_thread+1) 
    temp = [Time(i,m) <= Periods(i),Time(i,num_thread+2) <= Periods(i)];
    temp = 2*temp(1) + temp(2);
    switch temp
        case 3
            if Energy(i,m) <= Energy(i,num_thread+2)
                Assign{i}{j}{1} = [i,Periods(i),m-1,0];% Executor 记录执行的任务和分配的线程数/gpu
                value{i}{j} = 1*gama+1/Energy(i,m);
            else
                Assign{i}{j}{1} = [i,Periods(i),0,1];
                value{i}{j} = 1*gama+1/Energy(i,num_thread+2);
            end
        case 2
            Assign{i}{j}{1} = [i,Periods(i),m-1,0];
            value{i}{j} = 1*gama+1/Energy(i,m);

        case 1
            Assign{i}{j}{1} = [i,Periods(i),0,1];
            value{i}{j} = 1*gama+1/Energy(i,num_thread+2);

        otherwise
            Assign{i}{j} = {};
            value{i}{j} = 0;
    end                 
elseif j<= 3*(num_thread+1)    
    temp = [Time(i,m) <= Periods(i),Time(i,num_thread+1+2) <= Periods(i)];
    temp = 2*temp(1) + temp(2);
    switch temp
        case 3
            if Energy(i,m) <= Energy(i,num_thread+1+2)
                Assign{i}{j}{1} = [i,Periods(i),m-1,0];% Executor 记录执行的任务和分配的线程数/gpu
                value{i}{j} = 1*gama+1/Energy(i,m);
            else
                Assign{i}{j}{1} = [i,Periods(i),0,2];
                value{i}{j} = 1*gama+1/Energy(i,num_thread+3);
            end
        case 2
            Assign{i}{j}{1} = [i,Periods(i),m-1,0];
            value{i}{j} = 1*gama+1/Energy(i,m);

        case 1
            Assign{i}{j}{1} = [i,Periods(i),0,2];
            value{i}{j} = 1*gama+1/Energy(i,num_thread+3);

        otherwise
            Assign{i}{j} = {};
            value{i}{j} = 0;
    end  


else  
    temp = [Time(i,m) <= Periods(i),Time(i,num_thread+2) <= Periods(i),Time(i,num_thread+3) <= Periods(i)];
    temp = 4*temp(1) + 2*temp(2)+temp(3);
    switch temp
        case 7
            [~,idx] = min([Energy(i,m),Energy(i,num_thread+2),Energy(i,num_thread+3)]);
            if idx == 1
                Assign{i}{j}{1} = [i,Periods(i),m-1,0];% Executor 记录执行的任务和分配的线程数/gpu
                value{i}{j} = 1*gama+1/Energy(i,m);
            else
                Assign{i}{j}{1} = [i,Periods(i),0,idx-1];
                value{i}{j} = 1*gama+1/Energy(i,num_thread+idx);
            end

        case 6
            if Energy(i,m) <= Energy(i,num_thread+2)
                Assign{i}{j}{1} = [i,Periods(i),m-1,0];% Executor 记录执行的任务和分配的线程数/gpu
                value{i}{j} = 1*gama+1/Energy(i,m);
            else
                Assign{i}{j}{1} = [i,Periods(i),0,1];
                value{i}{j} = 1*gama+1/Energy(i,num_thread+2);
            end

        case 5
            if Energy(i,m) <= Energy(i,num_thread+3)
                Assign{i}{j}{1} = [i,Periods(i),m-1,0];% Executor 记录执行的任务和分配的线程数/gpu
                value{i}{j} = 1*gama+1/Energy(i,m);
            else
                Assign{i}{j}{1} = [i,Periods(i),0,2];
                value{i}{j} = 1*gama+1/Energy(i,num_thread+3);
            end
        case 4
            Assign{i}{j}{1} = [i,Periods(i),m-1,0];
            value{i}{j} = 1*gama+1/Energy(i,m);

        case 3
            if Energy(i,num_thread+2) <= Energy(i,num_thread+3)
                Assign{i}{j}{1} = [i,Periods(i),0,1];
                value{i}{j} = 1*gama+1/Energy(i,num_thread+2);
            else
                Assign{i}{j}{1} = [i,Periods(i),0,2];
                value{i}{j} = 1*gama+1/Energy(i,num_thread+3);
            end

        case 2
            Assign{i}{j}{1} = [i,Periods(i),0,1];
            value{i}{j} = 1*gama+1/Energy(i,num_thread+2); 

        case 1
            Assign{i}{j}{1} = [i,Periods(i),0,2];
            value{i}{j} = 1*gama+1/Energy(i,num_thread+3);
        otherwise
            Assign{i}{j} = {};
            value{i}{j} = 0;
    end
end