
1. PRP_CG.m is the main function, implementing the algorithm IHR, used in our paper "Inductive Transfer Learning for Unlabeled Target-domain via Hybrid Regularization". In this function, the inherent embedded @fminunc in matlab is also called. Sometimes there is some warning when calling @fminunc, you can try other functions. However, the warning hardly the performance of our algorithm.

2. KneighborFile_test.txt is the neighbor file. e.g., the first line represents the instance ids of the first instance's neighbors. 

Train1.data£¬Test1.data are the data from source domain and target domain, respectively.
Train1.label£¬Test1.label are the label file corresponding to Train1.data£¬Test1.data, respectively.

3. lpexec.m is a demo m-file.


If you have any questions, please feel free to contact the email: zhuangfz@ics.ict.ac.cn. But I can not be sure to answer you in time.

Good luck for your work.