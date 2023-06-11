function value = Compute_TotalValue(assignTemp,Energy,num_thread,gama)
P_s = 0;
num = 0;
for i=1:size(assignTemp,2) %executor个数
    num = num + size(assignTemp{i},1);
    for j=1:size(assignTemp{i},1)  %每一个executor中的任务数 行数
        if assignTemp{i}(end) == 0
            P_s = P_s + Energy(assignTemp{i}(j,1),assignTemp{i}(j,3)+1);
        else
            P_s = P_s + Energy(assignTemp{i}(j,1),assignTemp{i}(j,4)+num_thread+1);
        end
    end
end
value = num*gama + 1/P_s;
        