
1. Folder "data" contains the data from 20NewsGroup used in our experiments.
The relationships between the data files and the topics in 20NewsGroup are as follows. 

TrainSelect_8.data  -> rec.autos  
TrainSelect_9.data  -> rec.motorcycles  
TrainSelect_10.data -> rec.sport.baseball  
TrainSelect_11.data -> rec.sport.hockey  
TrainSelect_12.data -> sci.crypt  
TrainSelect_13.data -> sci.electronics  
TrainSelect_14.data -> sci.med  
TrainSelect_15.data -> sci.space  

The data format: 
each line is a triple <wordID, DocumentID, Value>. 
The value in the data file is tf-idf. 

You may read Sections 4 for more details on how to use these data to generate
the tasks of transfer learning with multiple domains.


2. Folder "code" contains the code of our algorithm TriTL.
'TriTL.m' is a general program, which supports multiple-class classification
(not only for binary classification), multiple source domains and multiple target domains.

'TriTL.m' is the main function.
Its Parameters are decipted as follows,

%%% function [Results, Gt] = TriTL(Train_Data,Test_Data,Parameter_Setting)

%%% Input:
1) The parameter "Train_data" is the file, which includes the file pathes of the data from the source domains and the corresponding labels. 
An example file is as follows:

*********************
1
Train1.data
Train1.label
*********************

In this task there is one source domain. 
"Train1.data" includes the features of the data from the first domain.
"Train1.label" includes the labels of data from the first domain. 


2) The parameter "Test_data" is the file, which includes the file pathes of the data from the target domains and the corresponding labels. 
(we only use these labels to calculate the accuracy).
An example file is as follows:

*********************
1
Test.data
Test.label
*********************

In this task there are only 1 target domain. 
"Test.data" includes the features of the data from this target domain.
"Test.label" includes the labels of data from this target domain. 
Our code surports multiple target domains.

3) The parameter "Parameterfile" is the file which includes the parameters in our algorithm.
Specifically, in this file the first line is the number of identical concepts, the seconde line is the number of alike concepts, the third line is the number of distinct concepts, and the fourth line is the number of iterations.

An example file is as follows:

*********************
20
20
10
100
*********************

In this example we set the number of identical concepts to 20, the number of alike concepts to 20, the number of distinct concepts to 10, and the iteration number is 100.

%%% Output
The variable "Results" is a matrix M with size numIteration x numTarget, 
M_{i,j} is the accuracy value in the j-th target domain after the i-th iteration.

The variable "Gt" is a matrix with size n x c, where n is the number of
instances in all target domains (all these instances are ranking in the order of the target domains), 
c is the number of classes. This matrix is actually the conditional praboblity  of p(z|d).


3. Folder "demo" gives an example of running this code. You can run the M-file 'test.m' to reproduce the results of 144 problems in the paper. (In the demo, the initial value of Gt randomly assigned, rather than the prediction results of supervised classifier (e.g., LR).)

Since we use PLSA to initialize the values of p(w|y) this demo also includes the code for PLSA. 
The PLSA software package can be downloaded from "http://www.kyb.tuebingen.mpg.de/bs/people/pgehler/code/index.html". 

4. Notes 

If you encounter the problem of "outOfMemory" in Matlab, try to enlarge the memory for matlab. 
Specifically, you can set it in the file "\boot.ini", 
change '/fastdetect' to '/fastdetect /3GB', and then restart your computer.

If you have any questions, please feel free to contact the email: zhuangfz@ics.ict.ac.cn, ping.luo@hp.com.