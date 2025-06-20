function G = slope_limit_state(X)
% Toy limit state function for slope stability
% Inputs:
%   X(:,1) - Slope Angle (degrees)
%   X(:,2) - Cohesion (kPa)
%   X(:,3) - Friction Angle (degrees)

gamma = 18;       % Unit weight (kN/m³)
H = 10;           % Height of slope (m)
FS_threshold = 1; % Factor of Safety threshold for failure

% Extract input variables
slope_angle = X(:,1);
c = X(:,2);
phi = X(:,3);

% Simplified infinite slope model (dry condition)
numerator = c ./ (gamma * H) + tand(phi);
denominator = tand(slope_angle);

FOS = numerator ./ denominator;

% Limit state function: G > 0 => safe, G < 0 => failure
G = FOS - FS_threshold;
end
