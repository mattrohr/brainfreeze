% load Symbolic Math Toolbox™ units to keep track of units during calculation
u = symunit;

brainRefractiveIndex = 1.3526; % https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3501791/

OCTSourceWavelength = 1300 * u.nm; % https://www.thorlabs.com/drawings/715461976be72d90-379CEB15-0AEB-DB97-A1FDB8DC4CD35E08/LS2000B-Manual.pdf
OCTSourceFWHM = 200 * u.nm; % https://www.thorlabs.com/drawings/715461976be72d90-379CEB15-0AEB-DB97-A1FDB8DC4CD35E08/LS2000B-Manual.pdf
OCTCoherenceLength = (2 * log(2)) / pi * OCTSourceWavelength^2 / (brainRefractiveIndex * OCTSourceFWHM); % https://doi.org/10.1364/AO.41.005256
OCTCoherenceLength = vpa(OCTCoherenceLength) % convert fractional units to decimal for readability

LSCISourceWavelength = 660 * u.nm; % https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=1500&pn=S1FC660
LSCISourceFWHM = 0.7023 * u.nm; % https://www.thorlabs.com/images/TabImages/S1FC660_Spectrum.gif
LSCICoherenceLength = (2 * log(2)) / pi * LSCISourceWavelength^2 / (brainRefractiveIndex * LSCISourceFWHM); % https://doi.org/10.1364/AO.41.005256
LSCICoherenceLength = vpa(LSCICoherenceLength) % convert fractional units to decimal for readability