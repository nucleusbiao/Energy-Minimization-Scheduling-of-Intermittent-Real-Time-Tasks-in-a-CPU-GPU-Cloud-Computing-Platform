1. All input data to reproduce the results in the paper is stored to data.zip. Please unzip this file first.
2. The directories of dp, dpRuntime, greedy1, greedy2 and random refer to the approach DP, DPruntime, Greedy1, Greedy2 and Random in this paper. 
3. A simple example to understand how the method works is the file named '(name)_method_test.m' in each directory, where (name) refers to the method name. In this example, the schedule results are stored into the cell array named Assign. 
4. Run the file named '(name)_method_single_server.m' in each directory to get the results of Figs. 3,4,5 in the paper and run the file named '(name)_method_multiple_server.m' to get the results of Fig. 6. You should also run dataScript.m in data directory to fetch useful information from all the results. 
6. Because it may take very long time to get the above results, our test results have been saved in the results directory. You need to run the gnu script by gnuplot to get all the figures. 
