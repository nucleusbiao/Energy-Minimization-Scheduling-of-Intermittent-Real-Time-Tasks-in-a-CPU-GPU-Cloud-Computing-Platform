function scheduleFlag=responseTimeCpu(executor,newjob,Time,Periods)
resource = executor(end-1);  %executor为cpu ，看第三位
executor = [executor; newjob,resource,0];
num_job = size(executor,1);

for i=1:num_job
    if(Time(executor(i,1),resource+1)*num_job > Periods(executor(i,1)))
        scheduleFlag = false;
        break;
    else
        scheduleFlag = true;
    end
end

        


        
