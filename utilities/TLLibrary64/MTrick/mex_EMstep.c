#include <math.h>
#include "mex.h"
#include "matrix.h"


unsigned int numnonzeros(const mxArray*);

/*
  mex_EMstep performs one step of (T)EM given the parameters

  usage:  Y = mex_EMstep(X,C,Pw_z,Pz_d)
  or      Y = mex_EMstep(X,C,Pw_z,Pz_d,beta)
  
  where 'X' is the term-document matrix, 'C' the normalization 
  constant (evaluated at the non zero points of 'X', 'Pw_z' the
  conditional distribution over words given the topics, 'Pz_d'
  the document conditioned distribution over the topics. 
  'beta' \elem (0,1] for tempered EM. (default: 1) 
  'X' and 'C' have to be sparse (and of the same structure)
  
  Peter Gehler
  Max Planck Institute for biological Cybernetics
  pgehler@tuebingen.mpg.de
  Feb 2006
*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[]) { 
    double *XPz_dw, *X, *Pw_z, *Pz_d, *C, sumXPz_dw;
    double *Pz_d_out,*Pw_z_out,*sumX;
    double beta;
    mxArray *p;
    int *ir_x,*ir_xy, *jc_x, *jc_xy;
    unsigned int indc, indx, next_indx, element_count, nn,ww;
    unsigned int nWords,nTopics,nDocs;
    bool temperedEM;

    if (((!(mxIsSparse(prhs[0])))||(!(mxIsSparse(prhs[1]))))
	||((nlhs!=2)||!((nrhs==4)||(nrhs==5)))){
	printf("usage: Y = mex_EMstep(X,C,Pw_z,Pz_d)\n");
	printf("   or: Y = mex_EMstep(X,C,Pw_z,Pz_d,beta)\n");
	printf(" where 'X' is the data matrix and 'C' the normalizing constant\n both have to be sparse\n");
	printf(" 'beta' is the temperature parameter for TEM or 1 if not given\n");
	printf(" this function performs one step of EM and returns the updated\n");
	printf(" parameters. \n");
	return;
    }

    nWords = mxGetM(prhs[0]);
    nDocs = mxGetN(prhs[0]);
    nTopics = mxGetN(prhs[2]);

    jc_x = mxGetJc(prhs[0]);
    ir_x = mxGetIr(prhs[0]);
    X    = mxGetPr(prhs[0]);

    C    = mxGetPr(prhs[1]);

    Pw_z = mxGetPr(prhs[2]);
    Pz_d = mxGetPr(prhs[3]);

    if (nrhs == 5)
	beta = *mxGetPr(prhs[4]);
    else
	beta = 1;


    temperedEM = beta !=1;

    /* create output matrices */
    plhs[0] = mxCreateDoubleMatrix(nWords,nTopics,mxREAL);
    Pw_z_out = mxGetPr(plhs[0]);

    plhs[1] = mxCreateDoubleMatrix(nTopics,nDocs,mxREAL);
    Pz_d_out = mxGetPr(plhs[1]);


    p = mxCreateSparse(nWords, nDocs, numnonzeros(prhs[0]), mxREAL);
    jc_xy = mxGetJc(p);
    ir_xy = mxGetIr(p);
    XPz_dw = mxGetPr(p);

    sumX = malloc(nDocs * sizeof(double));
    /*
    p = mxCreateDoubleMatrix(nDocs,1,mxREAL);
    sumX = mxGetPr(p);
    */
    if (!(temperedEM)) { /* plain EM */

	for (nn=0;nn<nTopics;nn++){ /* for every topic */
	    sumXPz_dw = 0;
	    element_count = 0;
	    jc_xy[0] = 0;
	    indx = 0;

	    for (indc = 0; indc < nDocs; indc++) { /* loop over documents */
		sumX[indc] = 0;
		jc_xy[indc+1] = jc_xy[indc]; 
		next_indx = jc_x[indc+1]; /* next column index */
		while (indx < next_indx) {
		    jc_xy[indc+1]++;
		    /* copy element of sparse matrix */
		    
		    ir_xy[element_count] = ir_x[indx];
		    
		    XPz_dw[element_count] = X[indx] * Pz_d[nn+nTopics*indc] * Pw_z[nn*nWords+ir_xy[element_count]] / C[indx];
		    /* this works for one topic */
		    /*XPz_dw[element_count] = X[indx] * Pz_d[indc] * Pw_z[ir_xy[element_count]] / C[indx];*/

		    /* this check might be deleted at some point */
		    if (mxIsNaN(XPz_dw[element_count])){
			printf("isnan!!\n");
			XPz_dw[element_count] = 0;
		    }
		    else
			sumXPz_dw += XPz_dw[element_count];
		    
		    /* calculate the total sum of the elements in X */
		    sumX[indc] += X[indx];
		    
		    /* update sum over rows and sum over columns */
		    Pw_z_out[nn*nWords+ir_xy[element_count]] += XPz_dw[element_count];
		    Pz_d_out[nn+nTopics*indc] += XPz_dw[element_count];
		    
		    indx++;
		    element_count++;
		}
	    }

	    /* normalize Pw_z and Pz_d */
	    for (ww=0;ww<nWords;ww++)
		Pw_z_out[nn*nWords+ww] /= sumXPz_dw;
	    for (ww=0;ww<nDocs;ww++)
		Pz_d_out[nn+nTopics*ww] /= sumX[ww];
	}

    } 
    else {  /* tempered EM version - see comments from above */
	for (nn=0;nn<nTopics;nn++){
	    sumXPz_dw= 0;
	    element_count = 0;
	    jc_xy[0] = 0;
	    indx = 0;
	    for (indc = 0; indc < nDocs; indc++) {
		sumX[indc] = 0;
		jc_xy[indc+1] = jc_xy[indc]; 
		next_indx = jc_x[indc+1]; /* next column index */

		while (indx < next_indx) {
		    jc_xy[indc+1]++;
		    ir_xy[element_count] = ir_x[indx];
		    XPz_dw[element_count] = X[indx] * pow(Pz_d[nn+nTopics*indc]*Pw_z[nn*nWords+ir_xy[element_count]],beta) / C[indx];
		    if (mxIsNaN(XPz_dw[element_count]))
			XPz_dw[element_count] = 0;
		    else
			sumXPz_dw += XPz_dw[element_count];
		    sumX[indc] += X[indx];
		    Pw_z_out[nn*nWords+ir_xy[element_count]] += XPz_dw[element_count];
		    Pz_d_out[nn+nTopics*indc] += XPz_dw[element_count];
		    indx++;
		    element_count++;
		}
	    }
	    for (ww=0;ww<nWords;ww++)
		Pw_z_out[nn*nWords+ww] /= sumXPz_dw;
	    for (ww=0;ww<nDocs;ww++)
		Pz_d_out[nn+nTopics*ww] /= sumX[ww];
	}
    }
    free(sumX);
    mxDestroyArray(p);
    return;
}


/* count number of nonzero entries */
unsigned int numnonzeros(const mxArray *prhs){
    unsigned int nnz;

    if (mxIsSparse(prhs))
	nnz = *(mxGetJc(prhs)+mxGetN(prhs));
      else if (mxIsDouble(prhs)){
     int s=0, i, n;
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
