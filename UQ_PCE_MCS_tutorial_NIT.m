%% Tutorial: UQlab - Using PCE-MCS for Reliability Analysis
% This tutorial demonstrates the use of UQlab for reliability analysis of a geotechnical slope problem using:
% 1. Definition of input distributions
% 2. Monte Carlo Simulation (MCS)
% 3. Polynomial Chaos Expansion (PCE) modeling
% 4. Efficiency comparison of PCE-MCS vs. traditional MCS

%% Step 1: Start UQLab
uqlab;

%% Step 2: Define Input Distributions
% We define 3 random input variables: slope angle, cohesion, and friction angle.
% Example distributions are assumed for illustration.

InputOpts.Marginals(1).Name = 'SlopeAngle';
InputOpts.Marginals(1).Type = 'Gaussian';
InputOpts.Marginals(1).Parameters = [30 5];

InputOpts.Marginals(2).Name = 'Cohesion';
InputOpts.Marginals(2).Type = 'Gaussian';
InputOpts.Marginals(2).Parameters = [20 2];

InputOpts.Marginals(3).Name = 'FrictionAngle';
InputOpts.Marginals(3).Type = 'Gaussian';
InputOpts.Marginals(3).Parameters = [35 3];

myInput = uq_createInput(InputOpts);

%% Step 3: Visualize Input Distributions
uq_display(myInput);

%% Step 4: Define the Model
% This is a toy limit state function for slope safety (FOS < 1 is failure)
ModelOpts.mFile = 'slope_limit_state'; % Define this function separately
myModel = uq_createModel(ModelOpts);

%% Step 5: Run Monte Carlo Simulation (MCS) and track time
MCSOpts.Type = 'Reliability';
MCSOpts.Method = 'MC';
MCSOpts.Model = myModel;
MCSOpts.Input = myInput;
MCSOpts.Simulation.MaxSampleSize = 1e5;
% MCSOpts.Simulation.BatchSize = 1e4;
MCSOpts.Simulation.BatchSize = 1e2;
MCSOpts.Simulation.TargetCoV = 0.05;

fprintf('\nRunning Crude MCS...\n');
tic;
myAnalysis_MCS = uq_createAnalysis(MCSOpts);
time_MCS = toc;
Results_MCS = myAnalysis_MCS.Results;

%% Step 6: Train Polynomial Chaos Expansion (PCE)
PCEOpts.Type = 'Metamodel';
PCEOpts.MetaType = 'PCE';
PCEOpts.Input = myInput;
PCEOpts.FullModel = myModel;
PCEOpts.Method = 'LARS';
PCEOpts.Degree = 2:5;
PCEOpts.ExpDesign.NSamples = 100; %Trained on 100 points

fprintf('\nTraining PCE model...\n');
tic;
myPCE = uq_createModel(PCEOpts);
time_PCE_training = toc;

%% Step 7: Use PCE in MCS (Surrogate-based MCS) and track time
PCE_MCS_Opts.Type = 'Reliability';
PCE_MCS_Opts.Method = 'MC';
PCE_MCS_Opts.Model = myPCE;
PCE_MCS_Opts.Input = myInput;
PCE_MCS_Opts.Simulation.MaxSampleSize = 1e5;
% PCE_MCS_Opts.Simulation.BatchSize = 1e4;
PCE_MCS_Opts.Simulation.BatchSize = 1e2;
PCE_MCS_Opts.Simulation.TargetCoV = 0.05;

fprintf('\nRunning PCE-MCS...\n');
tic;
myAnalysis_PCE = uq_createAnalysis(PCE_MCS_Opts);
time_PCE_MCS = toc;
Results_PCE = myAnalysis_PCE.Results;

%% Step 8: Compare Results and Efficiency
fprintf('\n--- Monte Carlo Simulation (MCS) ---\n');
fprintf('Pf (Probability of Failure): %.5e\n', Results_MCS.Pf); 
fprintf('Beta (Reliability Index): %.4f\n', Results_MCS.Beta);
fprintf('Time Taken: %.2f seconds\n', time_MCS);

fprintf('\n--- PCE-based MCS ---\n');
fprintf('Pf (Probability of Failure): %.5e\n', Results_PCE.Pf);
fprintf('Beta (Reliability Index): %.4f\n', Results_PCE.Beta);
fprintf('PCE Training Time: %.2f seconds\n', time_PCE_training);
fprintf('PCE-MCS Time: %.2f seconds\n', time_PCE_MCS);

%% Note to Students:
% Observe how PCE gives a very similar result with much fewer model evaluations and time.
% This illustrates the power of surrogate modeling in reliability analysis.
