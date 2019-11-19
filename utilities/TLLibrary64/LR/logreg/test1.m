% tiny
%d = 10;
% medium
d = 100;
% big
%d = 500;
n = 3*d;
%n = 2*d;

if 1
  clear run
if 0
  % experiment 1
  w = randn(d,1);
  % this ensures about 16% training error
  w = sqrt(2)*w/norm(w);
  % training data
  x = randn(d,n);
  s = 1./(1+exp(-w'*x));
  y = (rand(1,n) < s);
  y = 2*y-1;
  if 0
    % test data
    xt = randn(d,1e4);
    s = 1./(1+exp(-w'*xt));
    yt = (rand(1,cols(xt)) < s);
    yt = 2*yt-1;
  end
elseif 1
  % experiment 2
  % positive data
  x = dirichlet_sample(ones(d,1),n);
  w = dirichlet_sample(ones(d,1),2);
  w = log(w(:,1)./w(:,2));
  
  s = 1./(1+exp(-w'*x));
  y = (rand(1,n) < s);
  y = 2*y-1;
  if 1
    % test data
    xt = dirichlet_sample(ones(d,1),n);
    s = 1./(1+exp(-w'*xt));
    yt = (rand(1,cols(xt)) < s);
    yt = 2*yt-1;
  end
else
  % Collins's generator
  x = randn(d,n);
  w = randn(d,1);
  y = sign(w'*x);
  x = x + randn(d,n)*sqrt(0.8);
end

if 0
  % shift the data
  c = 10;
  x = [x+c; ones(1,n)];
  w = [w; -c*sum(w)];
end
end
[d,n] = size(x);


i1 = find(y > 0);
i0 = find(y < 0);
figure(1)
plot(x(1,i1), x(2,i1), 'o', x(1,i0), x(2,i0), 'x')
if d == 2
  draw_line_clip(w(1),w(end),-w(2),'Color','k');
end

w0 = zeros(d,1);
xy = scale_cols(x,y);

if 0
  xyt = scale_cols(xt,yt);
  % find the best lambda
  lambdas = exp(linspace(-4,4,20));
  f = [];
  for i = 1:length(lambdas)
    w = train_newton(xy,w0,lambdas(i));
    f(i) = logProb(xyt,w);
  end
  figure(1)
  semilogx(lambdas,f)
  axis_pct;
  [dummy,i] = max(f);
  lambda = lambdas(i);
else
  lambda = 1e-2;
end
fprintf('lambda = %g\n',lambda)

if exist('run') ~= 1 | ~isfield(run,'Newton')
  disp('Newton')
  [w,run.Newton] = train_newton(xy,w0,lambda);
  wbest = w;
  ebest = run.Newton.e(end);
  % training errors
  s = 1./(1+exp(-wbest'*x));
  fprintf('%g training error\n', mean((s > 0.5) ~= (y > 0)))
end

if ~isfield(run,'Coord')
  disp('Coord')
  %[w,run.Coord] = train_newton2(xy,w0,lambda);
end
if ~isfield(run,'CG')
  disp('CG')
  [w,run.CG] = train_cg(xy,w0,lambda);
end
%disp(length(cg.run.e))
%[w,cg2.run] = train_cg2(xy,w0);
%disp(length(cg2.run.e))
if 0
  % compare by iteration
  figure(3)
  i = 1:length(cg2.run.e);
  plot(i, cg.run.e(i), i, cg2.run.e(i))
  legend('CG','CG2',4)
  return
end

if ~isfield(run,'BFGS')
  disp('BFGS')
  [w,run.BFGS] = train_bfgs(xy,w0,lambda);
end
%[w,run.lmBFGS] = train_lmbfgs(xy,w0,lambda);

%[w,run.sg] = train_sg(xy,w0);
if 0
  fprintf('max(sg.run.e) = %g\n',max(sg.run.e))
  fprintf('max(cg.run.e) = %g\n',max(cg.run.e))
  figure(1)
  plot(sg.run.step)
  figure(2)
  hold on, plot(cg.run.e,'g'), hold off
  figure(3)
  plot(sg.run.w(1,:),sg.run.w(2,:))  
  hold on, plot(cg.run.w(1,:),cg.run.w(2,:),'g'), hold off
  return
end

if ~isfield(run,'FixedH')
  disp('FixedH')
  [w,run.FixedH] = train_bohning(xy,w0,lambda);
end

if ~isfield(run,'Dual') & lambda > 0
  disp('Dual')
  [w,run.Dual] = train_dual(xy,w0,lambda,1);
end
%[w,run.Dual2] = train_dual(xy,w0,lambda,1);
%[w,run.Dual2] = train_dual_cg(xy,w0,lambda);

if ~isfield(run,'MIS') & lambda == 0
  [w,run.MIS] = train_mis(xy,w0,lambda);
end
if ~isfield(run,'IS') & lambda == 0
  %[w,run.IS] = train_is(x,y,w0,lambda);
end

color.Newton = 'k';
color.CG = 'g';
color.BFGS = 'r';
color.lmBFGS = 'm';
color.cg2 = 'r';
color.sg = 'g';
color.Coord = 'm';
color.FixedH = 'c';
color.Dual = 'b';
color.Dual2 = 'm';
color.MIS = 'g';
color.IS = 'k';

linespec.Newton = 'b-.';
linespec.CG = 'g--';
linespec.Coord = 'g-';
linespec.FixedH = 'c-';
linespec.BFGS = 'r-.';
linespec.lmBFGS = 'm-.';
linespec.Dual = 'y-.';
linespec.Dual2 = 'm-.';
linespec.MIS = 'm--';
linespec.IS = 'k--';

% plot cost vs. accuracy
figure(2)
ebest = -Inf;
for f = fieldnames(run)'
  thisrun = getfield(run,char(f));
  ebest = max([ebest max(thisrun.e)]);
end
for f = fieldnames(run)'
  thisrun = getfield(run,char(f));
  %semilogx(thisrun.flops, thisrun.e, getfield(linespec,char(f)));
  thisrun.err = (ebest - thisrun.e)/n;
  run = setfield(run,char(f),thisrun);
  loglog(thisrun.flops, thisrun.err, getfield(color,char(f)));
  hold on
end
hold off
xlabel('FLOPS')
%ylabel('Log-likelihood')
ylabel('Difference from optimal log-likelihood')
axis_pct;
if 1
  ax = axis;
  ax(3) = 1e-10;
  axis(ax);
end
f = fieldnames(run);
legend(f,4)
if 0
  legend off
  f = fieldnames(run);
  h = mobile_text(f{:});
end
set(gcf,'paperpos',[0.25 2.5 8 6])
%print -dpsc expt1_d100_n300.ps
%print -dpsc expt2_d100_n300.ps
%print -dpsc expt25_d100_n300.ps
%print -dpsc expt25_d500_n1500.ps
%print -dpsc expt3_d100_n300.ps
%print -dpsc expt4_d100_n300.ps
% print -dpsc expt2_d300_n1500.ps
% save expt4.mat x y run

if 0
% cosine distance from the best solution
wbest = wbest/norm(wbest);
figure(3)
for f = fieldnames(run)'
  thisrun = getfield(run,char(f));
  thisrun.w = scale_cols(thisrun.w, 1./sqrt(sum(thisrun.w.^2,1)));
  thisrun.acc = sqrt(clip(sqdist(wbest, thisrun.w)));
  run = setfield(run,char(f),thisrun);
  loglog(thisrun.flops, thisrun.acc, getfield(color,char(f)));
  hold on
end
hold off
legend(fieldnames(run),4)
end

for f = fieldnames(run)'
  thisrun = getfield(run,char(f));
  %i = convergence(thisrun.e);
  i = min(find(thisrun.err < 1e-4));
  fprintf('%-9s %11d\n',char(f),thisrun.flops(i))
end
