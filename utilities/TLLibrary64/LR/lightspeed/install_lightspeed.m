%Install_lightspeed
% Compiles mex files for the lightspeed library.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

% thanks to Kevin Murphy for suggesting this routine.

fprintf('Compiling lightspeed mex files...\n');
fprintf('Change directory to lightspeed for this to work.\n');

% Matlab version
v = sscanf(version,'%d.%d.%*s (R%d) %*s');
% v(3) is the R number
% could also use v(3)>=13
atleast65 = (v(1)>6 || (v(1)==6 && v(2)>=5));

% copy matlab's original repmat.m as xrepmat.m
if exist('xrepmat.m') ~= 2
  w = which('repmat','-all');
  cmd = ['"' w{end} '" xrepmat.m'];
  if ispc
    system(['copy ' cmd]);
  else
    system(['cp -rp ' cmd]);
  end
end

% Routines that use LAPACK
if ispc
  if strcmp(mexcompiler,'cl')
    if atleast65
      % version >= 6.5
      lapacklib = fullfile(matlabroot,'extern\lib\win32\microsoft\libmwlapack.lib');
    end
  else
    lapacklib = fullfile(matlabroot,'extern\lib\win32\lcc\libmwlapack.lib');
  end
  if ~exist(lapacklib,'file')
    lapacklib = 'dtrsm.c';
    fprintf('libmwlapack.lib was not found.  To get additional optimizations, paste its location into install_lightspeed.m\n');
  else
    fprintf('Using the lapack library at %s\n',lapacklib);
  end
  %%% Paste the location of libmwlapack.lib %%%
  %lapacklib = '';
  clear functions
  eval(['mex solve_triu.c "' lapacklib '"']);
  eval(['mex solve_tril.c "' lapacklib '"']);
else
  % UNIX
  mex solve_triu.c
  mex solve_tril.c
end

mex -c flops.c
mex sameobject.c
mex int_hist.c
mex -c mexutil.c
mex -c util.c

if ispc
  % Windows
  %if exist('util.obj','file')
  mex addflops.c flops.obj
  mex digamma.c util.obj
  mex gammaln.c util.obj
  mex randbinom.c util.obj
  mex randgamma.c util.obj
  mex repmat.c mexutil.obj
  mex sample_hist.c util.obj
  mex trigamma.c util.obj
  try
    % standalone programs
    % compilation instructions are described at:
    % http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_external/ch1_im15.html#27765
    if atleast65
      % -V5 is required for Matlab >=6.5
      mex -f lccengmatopts.bat matfile.c -V5
      %mex -f msvc71engmatopts.bat matfile.c -V5
    else
      mex -f lccengmatopts.bat matfile.c
    end
    mex -f lccengmatopts.bat test_flops.c
  catch
    disp('Could not install the standalone programs.');
    disp(lasterr)
  end
else
  % UNIX
  mex addflops.c flops.o
  mex digamma.c util.o -lm
  mex gammaln.c util.o -lm
  mex randbinom.c util.o -lm
  mex randgamma.c util.o -lm
  mex repmat.c mexutil.o
  mex sample_hist.c util.o -lm
  mex trigamma.c util.o -lm
  try
    % standalone programs
    if atleast65
      % -V5 is required only for Matlab >=6.5
      mex -f matopts.sh matfile.c -V5
    else
      mex -f matopts.sh matfile.c
    end  
    mex -f matopts.sh test_flops.c
  catch
    disp('Could not install the standalone programs.');
    disp(lasterr);
    fprintf('Note: if matlab cannot find matopts.sh, your installation of matlab is faulty.\nIf you get this error, don''t worry, lightspeed should still work.');
  end
end

fprintf('Done.\n');
