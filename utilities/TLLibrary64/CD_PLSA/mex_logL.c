#include <math.h>
#include "mex.h"
#include "matrix.h"


/*
  logL = mex_logL(X,Pw_d,Pd)

  where X is the term-document matrix, Pw_d the distribution over the words
  given the documents and Pd the prior distribution over the documents. 
  X and Pw_d need to be sparse (and of the same structure)

  Peter Gehler
  Max Planck Institute for biological Cybernetics
  pgehler@tuebingen.mpg.de
  Feb 2006
*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[]) { 
    double *X, *Pw_d, *Pd, *logL;
    int *ir_x, *jc_x;
    unsigned int nDocs, indc, indx,next_indx;


    if (((nlhs!=1)||(nrhs!=3))
	||((!(mxIsSparse(prhs[0])))||(!(mxIsSparse(prhs[1]))))){
        printf("usage: logL = mex_logL(X,Pw_d,Pd)\n");
	printf("where 'X' and 'Pw_d' have to be sparse\n");
	return;
    }

    nDocs = mxGetN(prhs[0]);

    X    = mxGetPr(prhs[0]);
    jc_x = mxGetJc(prhs[0]);
    ir_x = mxGetIr(prhs[0]);
    
    Pw_d = mxGetPr(prhs[1]);
    Pd   = mxGetPr(prhs[2]);


    /* create output matrix */
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    logL = mxGetPr(plhs[0]);
    logL[0] =0;
        
    /* loop over only nonzero entries of the data matrix */
    indx = 0;
    for (indc = 0; indc < nDocs; indc++) {
	next_indx = jc_x[indc+1]; /* next column index */
	while (indx < next_indx) {
	    logL[0] += X[indx] * log(Pd[indc] * Pw_d[indx]);
	    indx++;
	}
    }
    
    return;
}


