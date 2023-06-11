function scheduleFlag = responseTimeNew(executor,Time,Periods,num_thread)

scheduleFlag = true;

if eq(executor(end,end), 1) % CPU threads
    resource = executor(end, 3); % CPU threads¸öÊý
    num_job = size(executor,1);
    for i=1:num_job
        if(Time(executor(i,1),resource)*num_job > Periods(executor(i,1)))
            scheduleFlag = false;
            break;
        end
    end
else
    resource = executor(end, 3:end-1); % GPUµÄ±àºÅ
    gpu_index = resource(executor(end,end));
    num_job = size(executor,1);
    T = 0;
    minPeriods = 1e5;
    for i=1:num_job
        T = T+Time(executor(i,1),gpu_index);
        if Periods(executor(i,1)) <= minPeriods
            minPeriods = Periods(executor(i,1));
        end
    end
    if T <= minPeriods
        scheduleFlag = true;
    else
        scheduleFlag = false;
    end
end
