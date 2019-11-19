This is a library of efficient and useful matlab functions, with an
emphasis on statistics.
See Contents.m for a synopsis.

You can place the lightspeed directory anywhere.
To make sure lightspeed is always in your path, create a startup.m
file in your matlab directory, if you don't already have one, and add
a line like this:
  addpath(genpath('c:\matlab\lightspeed'))
Replace 'c:\matlab\lightspeed' with the location of the lightspeed directory.

There are some Matlab Extension (MEX) files that need to be compiled.
This can be done in matlab via:
  cd c:\matlab\lightspeed
  install_lightspeed

If you are using Matlab 7 and Microsoft Visual C++ as your compiler 
(recommended), then you will need to download a patch:
ftp://ftp.mathworks.com/pub/tech-support/solutions/s1-QK7PM/libmwlapack.lib
Place the file in $MATLAB/extern/lib/win32/microsoft/msvc60/libmwlapack.lib
where $MATLAB is your root MATLAB directory.

You can find timing tests in the files test_*.m

Tom Minka
