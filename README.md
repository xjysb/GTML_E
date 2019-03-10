# GTML-E: Gas Turbine Modeling Library for Education

**Authors:** [Shubo Yang](https://www.researchgate.net/profile/Shubo_Yang)

**Keywords:** Gas Turbine, Open Source, Simulation, Modeling, MATLAB, Simulink.

![DOI](https://zenodo.org/badge/DOI/NULL.svg)

## What is GTML-E?

The Gas Turbine Modeling Library for Education (GTML-E) is an open source library intended for teaching the modeling and simulation of gas turbines. 

Development of the MATLAB/Simulink library was initiated on behalf of Beihang University to helps a student to learn how to create gas turbine models and related simulations.   

## Getting Started 

Stable releases of GTML-E are located under the <a href= "https://github.com/xjysb/GTML_E/releases" >releases tab</a>.
Note that GTML-E was developed in MATLAB/Simulink R2014a (The Mathworks, Inc.) and it is not guaranteed to work on earlier Matlab versions.

To install GTML-E in the Simulink Library Browser, simply add all folders and subfolders to the Matlab path using the set path option. 

## Citation

If used in published work, please cite the work as:

Shubo Yang. (2019, March 10). GTML-E: Gas Turbine Modeling Library for Education. *Zenodo*.

In addition, please cite the technical report acknowledged below.

## Acknowledgements
The Iterative Newton Raphson Solver block used in GTML-E is based on [T-MATS package](https://github.com/nasa/T-MATS) and the corresponding report [Toolbox for the Modeling and Analysis of Thermodynamic Systems (T-MATS) User's Guide](https://www.researchgate.net/publication/273755877_Toolbox_for_the_Modeling_and_Analysis_of_Thermodynamic_Systems_T-MATS_User's_Guide/citations) by [Chapman, Jeffryes W.](https://www.grc.nasa.gov/www/cdtb/personnel/jeffchapman.html), et al.

<!--Bug report:
 SM changes unsmoothly, which dues to W changing too fast. We should introduce a Volume between Booster and Compressor.+ W - P_err-->