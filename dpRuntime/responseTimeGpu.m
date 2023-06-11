function scheduleFlag = responseTimeGpu(executor, newjob,Time,Periods,num_thread)
resource = executor(end,end);  %最后一列 
executor = [executor; newjob, 0,resource];
num_job = size(executor,1);
T = 0;
minPeriods = 1e5;
for i=1:num_job
    T = T+Time(executor(i,1),num_thread+resource+1);
    if Periods(executor(i,1)) <= minPeriods
        minPeriods = Periods(executor(i,1));
    end
end

if T <= minPeriods
    scheduleFlag = true;
else
    scheduleFlag = false;
end

    



