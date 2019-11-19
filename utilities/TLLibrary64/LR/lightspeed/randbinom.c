/* compile with: cmex bino_sample.c util.o -lm
 */
#include "mex.h"
#include "util.h"

void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  int rows, cols, n, i;
  double *p, *r;

  if(nrhs != 2)
    mexErrMsgTxt("Usage: r = bino_sample(p, n)");

  /* prhs[0] is first argument.
   * mxGetPr returns double*  (data, col-major)
   * mxGetM returns int  (rows)
   * mxGetN returns int  (cols)
   */
  rows = mxGetM(prhs[0]);
  cols = mxGetN(prhs[0]);
  p = mxGetPr(prhs[0]);
  n = (int)*mxGetPr(prhs[1]);
  if(mxGetM(prhs[1]) != 1 || mxGetN(prhs[1]) != 1)
    mexErrMsgTxt("n must be scalar");

  if(mxIsSparse(prhs[0]))
    mexErrMsgTxt("Cannot handle sparse matrices.  Sorry.");

  /* plhs[0] is first output */
  plhs[0] = mxCreateDoubleMatrix(rows, cols, mxREAL);
  r = mxGetPr(plhs[0]);
  for(i=0;i<rows*cols;i++) {
    *r++ = BinoRand(*p++, n);
  }
}

