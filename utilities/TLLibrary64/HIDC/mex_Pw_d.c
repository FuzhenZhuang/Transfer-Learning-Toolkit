#include <math.h>
#include "mex.h"
#include "matrix.h"


/*
  mex_Pw_d.c 
  
  computes the normalization constant during EM learning for PLSI. 
  The elements are computed only at those positions needed, therefore 

  Peter Gehler
*/

unsigned int numnonzeros(const mxArray*);


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[]) { 
    double *Pw_d, *pr_x, *Pw_z, *Pz_d;
    double beta;
    int *ir_x, prev_ir_x,*ir_Pw_d, *jc_x, *jc_Pw_d, *bad_index;
    int element_count, nTopics;
    int nn,ii,jj;
    unsigned int nWords, nDocs, indc, indx, indy, next_indx;
    bool temperedEM;

    /* sanity check of the parameters */
    if ((!(mxIsSparse(prhs[0])))
	||(!((nrhs==3)||(nrhs==4)))) {
	printf("usage : C = mex_Estep(X,Pw_z,Pz_d)\n");
	printf("   or : C = mex_Estep(X,Pw_z,Pz_d,beta)\n");
	printf(" computes the normalization oonstant 'C' only for those values\n");
	printf(" which are needed (nonzeros of X). If no 'beta' is given this function\n");
	printf(" does plain EM, TEM otherwise\n");
	return;
    }

    nWords = mxGetM(prhs[0]);	/* prhs[0] - X; prhs[1] - Pw_z; prhs[2] - Pz_d */
    nDocs  = mxGetN(prhs[0]);
    nTopics = mxGetM(prhs[2]);	
    jc_x = mxGetJc(prhs[0]);
    ir_x = mxGetIr(prhs[0]);
    pr_x = mxGetPr(prhs[0]);

    Pw_z = mxGetPr(prhs[1]);
    Pz_d = mxGetPr(prhs[2]);

    if (nrhs == 4)
	beta = *mxGetPr(prhs[3]); /* prhs[3] - beta */
    else
	beta = 1;

    temperedEM = beta!=1;

    /* sanity check of the parameters */
    if ((! ( mxGetM(prhs[1]) == nWords))|| (!(mxGetN(prhs[1]) == nTopics) ) ){
	printf("Dimensions mismatch of Pw_z, should be of size %d x %d\n",nWords,nTopics);
	return;
    }
    if ((!(mxGetM(prhs[2])==nTopics))||(!(mxGetN(prhs[2])==nDocs))){
	printf("Dimensions mismatch of Pz_d, should be of size %d x %d\n",nTopics,nDocs);
	return;
    }

    /* create sparse output matrix */
    plhs[0] = mxCreateSparse(nWords, nDocs, numnonzeros(prhs[0]), mxREAL);
    jc_Pw_d = mxGetJc(plhs[0]);
    ir_Pw_d = mxGetIr(plhs[0]);
    Pw_d = mxGetPr(plhs[0]);
        
    element_count = 0;
    jc_Pw_d[0] = 0;
    indx = 0;


    if (!(temperedEM)){ /* plain EM */
	for (indc = 0; indc < nDocs; indc++) {
	    jc_Pw_d[indc+1] = jc_Pw_d[indc]; 
	    next_indx = jc_x[indc+1];; /* next column index */
	    while (indx < next_indx) { /* while nonzero entries in the matrix */
		
		jc_Pw_d[indc+1]++; /* point to next index */
		
		/* copy element of sparse matrix */
		ir_Pw_d[element_count] = ir_x[indx];

		ii = indc;
		jj = ir_Pw_d[element_count];
		
		Pw_d[element_count] = 0;

		/* sum over all topics */
		for (nn=0;nn<nTopics;nn++)
		    Pw_d[element_count] += Pz_d[ii*nTopics+nn] * Pw_z[jj+nWords*nn];

		indx++;
		element_count++;
	    }
	}
    }
    else { /* tempered EM - see comments in plain EM */
	for (indc = 0; indc < nDocs; indc++) {
	    jc_Pw_d[indc+1] = jc_Pw_d[indc]; 
	    next_indx = jc_x[indc+1];
	    while (indx < next_indx) {
		jc_Pw_d[indc+1]++;
		ir_Pw_d[element_count] = ir_x[indx];
		ii = indc;
		jj = ir_Pw_d[element_count];
		Pw_d[element_count] = 0;
		for (nn=0;nn<nTopics;nn++)
		    Pw_d[element_count] += pow(Pz_d[ii*nTopics+nn] * Pw_z[jj+nWords*nn],beta);
		indx++;
		element_count++;
	    }
	}
    }
    
    return;
}


/* fast implementation of nnz(..) */
unsigned int numnonzeros(const mxArray*prhs)
{
    unsigned int nnz;
    
    if (mxIsSparse(prhs))
	nnz = *(mxGetJc(prhs)+mxGetN(prhs));
    else if (mxIsDouble(prhs)){
	int i, n;
	double *xr, *xi;
	nnz = 0;
	n=mxGetNumberOfElements(prhs);
	xr=mxGetPr(prhs);
	xi=mxGetPi(prhs);
	if (xi!=NULL)
	    for (i=0;i<n;i++){
		if (xr[i]!=0) nnz++;
		else if (xi[i]!=0) nnz++;
	    }
	else
	    for (i=0;i<n;i++) if (xr[i]!=0) nnz++;
    }
    else
	mexErrMsgTxt("Function not defined for variables of input class");
    
    return(nnz);
}
