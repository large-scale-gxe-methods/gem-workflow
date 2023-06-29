This workflow implements the GEM (Gene-Environment interaction analysis for Millions of samples) tool (https://github.com/large-scale-gxe-methods/GEM). GEM conducts genome-wide gene-environment interaction tests in unrelated individuals while allowing for multiple exposures, control for genotype-covariante interactions, and robust inference.

Author: Kenny Westerman (kewesterman@mgh.harvard.edu)

GEM tool information:

* Source code: https://github.com/large-scale-gxe-methods/GEM
* Expanded documentation: https://large-scale-gxe-methods.github.io
* Manuscript: KE Westerman, DT Pham, et al. GEM: Scalable and flexible gene-environment interaction analysis in millions of samples. *Bioinformatics* (2021). https://doi.org/10.1093/bioinformatics/btab223.

Workflow steps:

* Run GEM (scattered across an array of input files, usually chromosomes)
* Concatenate the outputs into a single summary statistics file

Inputs: 

See the "parameter_meta" section of the .wdl script.

Outputs:

* A summary statistics file containing estimates for genetic main effects and interaction effects as well as p-values for these along with a joint test of genetic main and interaction effects.

Cost estimation:

* Example analysis for reference	
	- Platform: Terra
	- Dataset: UK Biobank (N ~ 350k)
	- Analysis parameters: binary phenotype, single interaction term, 6 covariates
	- Computational resources requested: 4 CPUs, 10GB memory, 250GB disk
* The above analysis completed for chromosome 2 (~1M variants) in about 9 hours, which translates to a cost of approximately $2 based on typical Terra costs assuming non-preemptible machines are used. 
* To extrapolate from the above estimates: Runtime and cost should scale linearly with the sample size and number of variants and will be inversely proportional to the number of cores used.
