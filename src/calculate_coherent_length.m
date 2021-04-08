% load Symbolic Math Toolbox™ units to keep track of units during calculation
u = symunit;

laserSourceWavelength = 660 * u.nm; % https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=1500&pn=S1FC660
laserSourceFWHM = 0.7023 * u.nm; % https://www.thorlabs.com/images/TabImages/S1FC660_Spectrum.gif
brainRefractiveIndex = 1.3526; % https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3501791/

laserSourceCoherentLength = (2 * log(2)) / pi * laserSourceWavelength^2 / (brainRefractiveIndex * laserSourceFWHM); % https://doi.org/10.1364/AO.41.005256

% convert fractional units to decimal for readability
laserSourceCoherentLength = vpa(laserSourceCoherentLength)