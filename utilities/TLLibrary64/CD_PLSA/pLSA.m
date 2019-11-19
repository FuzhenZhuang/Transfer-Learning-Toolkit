% function [Pw_z,Pz_d,Pd,Li,perp,beta,Learn] = pLSA(X,Fixed_Pw_z,K,Learn)
%
% Probabilistic Latent semantic alnalysis (pLSA) using (tempered) EM
%
% where
%   X
% Notation:
% X ... (m x nd) term-document matrix (observed data)
%       X(i,j) stores number of occurrences of word i in document j
%
% m  ... number of words (vocabulary size)
% nd ... number of documents
% K  ... number of topics
%
% Fixed_Pw_z ... fixed Pw_z density (for recognition only)
%                leave empty in learning
%                N.B. Must be of size m by K
%
% Learn ... Structure holding all settings
%
% Li   ... likelihood for each iteration
% Pz   ... P(z)
% Pd_z ... P(d|z)
% Pw_z ... P(w|z) corresponds to beta parameter in LDA
%
% Pz_wd ... P(z|w,d) posterior on z
%
%
% References:
% [1] Thomas Hofmann: Probabilistic Latent Semantic Analysis,
% Proc. of the 15th Conf. on Uncertainty in Artificial Intelligence (UAI'99)
% [2] Thomas Hofmann: Unsupervised Learning by Probabilistic Latent Semantic
% Analysis, Machine Learning Journal, 42(1), 2001, pp.177.196
%
%
% This software is based on the implementation from
%
% Josef Sivic
% josef@robots.ox.ac.uk
% 30/7/2004
%
% and
%
% Extended by Rob Fergus
% fergus@csail.mit.edu
% 03/10/05
%
% Peter Gehler
% Max Planck Institute for biological Cybernetics
% pgehler@tuebingen.mpg.de
% Feb 2006



function [Pw_z,Pz_d,Pd,Li,perp,beta,Learn] = pLSA(X,Fixed_Pw_z,K,Learn)

%% small offset to avoid numerical problems
ZERO_OFFSET = 1e-7;

%%% Default settings
if nargin<4
    Learn.Max_Iterations  = 100; % iterate at most 100 iterations
    Learn.Min_Likelihood_Change = 1; % stop after loglikelihood
    % change is smaller than 1
    Learn.Verbosity = 0;
    Learn.saveit = 25; % backup parameters every 25 iterations
end

%
% tempered EM (TEM) or plain EM ?
%
if isfield(Learn,'TEM')
    TEM = Learn.TEM;
else
    TEM = 0;
end

beta = 1; % starting point for Tempered EM annealing


if TEM
    fprintf('using Tempered EM version\n');

    if ~isfield(Learn,'heldout')
        error('Please specify percentage of held out data');
    end

    if ~isfield(Learn,'Folding_Iterations')
        Learn.Folding_Iterations = 25;
        warning('No Iterations for Folding in specified, using %d',Learn.Folding_Iterations);
    end
    shuff = randperm(size(X,2));
    nTrain = ceil((1-Learn.heldout) * size(X,2));
    nTest = size(X,2) - nTrain;

    fprintf('splitting training data into %d training data points\n',nTrain);
    fprintf('... and %d validation points\n',nTest);

    % split into test and training data
    Xtest = X(:,shuff(nTrain+1:end));
    X = X(:,shuff(1:nTrain));
    nq = size(Xtest,2); % # of test documents

    % training on the already estimated parameters can be done only if the
    % validation set is known.
    Learn.shuff = shuff;


else
    if ~isfield(Learn,'heldout');
        Learn.heldout = 0;
    end
    perp = 0;
end

m  = size(X,1); % vocabulary size
nd = size(X,2); % # of documents


% if in recognition, reset Pw_z to fixed distribution
% from learning phase....
if isempty(Fixed_Pw_z)
    %% learning mode
    FIXED_PW_Z = 0;
else
    %% recognition mode
    FIXED_PW_Z = 1;

    %%% check that the size is compatible
    if ((size(Pw_z,1)==size(Fixed_Pw_z,1)) & (size(Pw_z,2)==size(Fixed_Pw_z,2)))
        %% overwrite random Pw_z
        Pw_z = Fixed_Pw_z;
    else
        error('Dimensions of fixed Pw_z density do not match VQ.Codebook_Size and Learn.Num_Topics');
    end
end

Li    = [];
maxit = Learn.Max_Iterations;

% initialize Pz, Pd_z,Pw_z
if TEM
    [Pd,Pz_d,Pw_z,Pq,Pz_q] = pLSA_init(X,K,Xtest);
else
    [Pd,Pz_d,Pw_z] = pLSA_init(X,K);
end
Pw_d = mex_Pw_d(X,Pw_z,Pz_d);

%
% Tempered EM algorithm
%
for it = 1:maxit
    fprintf('Iteration %d \n',it);

    % update the parameters and avoide the big posterior
    [Pw_z,Pz_d] = mex_EMstep(X,Pw_d,Pw_z,Pz_d,beta);

    % update the normalization constant Pw_d
    Pw_d = mex_Pw_d(X,Pw_z,Pz_d,beta);

    % compute log likelihood
    Li(it) = pLSA_logL(X,Pw_z,Pz_d,Pd,Pw_d);

    % for tempered EM we compute the perplexity of the held out dataset
    if TEM
        % fold in held out data
        Pz_q = pLSA_EMfold(Xtest,Pw_z+ZERO_OFFSET,Pz_q,Learn.Folding_Iterations,beta);
        % compute perplexity
        perp(it) = pLSA_logL(Xtest,Pw_z+ZERO_OFFSET,Pz_q,Pq);
    end


    if it > 1

        dLi(it) = Li(it) - Li(it-1);
        fprintf('dLi= %f\n',dLi(it));

        % no TEM and stoping criterion reached
        if (~TEM && dLi(it) < Learn.Min_Likelihood_Change)
            if isfield(Learn,'sfile')
                save(Learn.sfile,'Pw_z','Pz_d','Pd','Li','perp','beta','Learn');
            end
            break;
        end


        if TEM
            dPerp(it) = perp(it) - perp(it-1);
            fprintf('dPerp=%f \n', dPerp(it));

            % perplexity decreased twice
            if TEM & dPerp(it) < 0 & dPerp(it-1) < 0

                % decrease beta
                fprintf('lowering beta to %g\n',beta-.025);
                beta = beta - .025;

                Pw_z_old = Pw_z;
                Pz_d_old = Pz_d;

                % do five EM steps with new beta and check if the logL is
                % getting better
                for tt=1:5
                    [Pw_z,Pz_d] = pLSA_EMstep(X,Pw_z,Pz_d,beta,Pw_d);
                    Pw_d = mex_Pw_d(X,Pw_z,Pz_d,beta);
                end
                % init new Pz_q
                Pz_q = rand(K,nTest);
                Pz_q = Pz_q ./ repmat(sum(Pz_q),K,1);

                Pz_q = pLSA_EMfold(Xtest,Pw_z+ZERO_OFFSET,Pz_q,Learn.Folding_Iterations,beta);
                if perp(it) > pLSA_logL(Xtest,Pw_z+ZERO_OFFSET,Pz_q,Pq)
                    fprintf('decreasing beta does not yield better performance\n');
                    fprintf('stopping here\n');
                    beta = beta + .025;
                    break
                end

            end

        end

        % save the parameters of the model
        if isfield(Learn,'saveit') & (~mod(it,Learn.saveit) & isfield(Learn,'sfile'))
            save(Learn.sfile,'Pw_z','Pz_d','Pd','Li','perp','beta','Learn');
        end

    end

end

if isfield(Learn,'sfile')
    save(Learn.sfile,'Pw_z','Pz_d','Pd','Li','perp','beta','Learn');
end

fprintf('final beta : %g\n',beta);
fprintf('\n');



% [Pd,Pz_d,Pw_z,Pq,Pz_q] = pLSA_init(X,K,Xtest)
%
% initialize the probability distributions
function [Pd,Pz_d,Pw_z,Pq,Pz_q] = pLSA_init(X,K,Xtest)

[nWords,nTrain] = size(X);
Pd = sum(X)./sum(X(:));
Pd = full(Pd);

%
% init mixture components of train...
%
Pz_d = rand(K,nTrain);
Pz_d = Pz_d ./ repmat(sum(Pz_d),K,1);

% Pz_d = ones(K,nTrain)/K;            %zhuangfz

% random assignment
Pw_z = rand(nWords,K);
C    = 1./sum(Pw_z,1);    % normalize to sum to 1
Pw_z = Pw_z * diag(C);

% Pw_z = ones(nWords,K)/nWords;            %zhuangfz


if nargin > 2

    nTest = size(Xtest,2);

    % compute Pq, Pd
    Pq = sum(Xtest)./sum(Xtest(:));

    Pq = full(Pq);

    %
    % ... and test set.
    %
    Pz_q = rand(K,nTest);
    Pz_q = Pz_q ./ repmat(sum(Pz_q),K,1);
%     Pz_q = ones(K,nTest)/K;            %zhuangfz
end

