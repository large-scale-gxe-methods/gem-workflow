This workflow implements the GEM (Gene-Environment interaction analysis for Millions of samples) tool (https://github.com/large-scale-gxe-methods/GEM). GEM conducts genome-wide gene-environment interaction tests in unrelated individuals while allowing for multiple exposures, control for genotype-covariante interactions, and robust inference.

Author: Kenny Westerman (kewesterman@mgh.harvard.edu)

GEM tool information:

* Manuscript: KE Westerman, DT Pham, et al. GEM: Scalable and flexible gene-environment interaction analysis in millions of samples. bioRxiv (2020) [Preprint] https://doi.org/10.1101/2020.05.13.090803. 
* Source code: https://github.com/large-scale-gxe-methods/GEM
* Expanded documentation: https://large-scale-gxe-methods.github.io/GEM-website/

Workflow steps:

* Run GEM (scattered across an array of input files, usually chromosomes)
* Concatenate the outputs into a single summary statistics file

Inputs: 

* bgenfiles: Array of genotype filepaths in .bgen format. Optional, but either this or pgenfiles must be specified as an input.
* samplefile: Optional .sample file accompanying the .bgen file. Required for proper function if .bgen does not store sample identifiers.
* pgenfiles: Array of genotype filepaths in .pgen (PLINK2) format. Optional, but at least one genotype dataset must be specified as an input.
* psamfile: Sample descriptor file in .psam (PLINK2) format. Optional, but must be included if using the pgenfiles input.
* pvarfiles: Array of variant descriptor filepaths in .pvar (PLINK2) format. Optional, but must be included if using the pgenfiles input.
* bedfiles: Array of genotype filepaths in .bed (PLINK1) format. Optional, but at least one genotype dataset must be specified as an input.
* famfile: Sample descriptor file in .fam (PLINK1) format. Optional, but must be included if using the bedfiles input.
* bimfiles: Array of variant descriptor filepaths in .bim (PLINK1) format. Optional, but must be included if using the bedfiles input.
* maf: Minor allele frequency threshold for pre-filtering variants as a fraction (default is 0.005).
* phenofile: Phenotype filepath.	
* sample_id_header: Optional column header name of sample ID in phenotype file.
* outcome: Column header name of phenotype data in phenotype file.
* binary_outcome: Boolean: is the outcome binary? Otherwise, quantitative is assumed.
* exposure_names: Column header name(s) of the exposures for genotype interaction testing (space-delimited).
* int_covar_names: Column header name(s) of any covariates for which genotype interactions should be included for adjustment in regression (space-delimited). These terms will not be included in any multi-exposure interaction tests. This set should not overlap with exposures or covar_names.
* covar_names: Column header name(s) of any covariates for which only main effects should be included selected covariates in the pheno data file (space-delimited). This set should not overlap with exposures or int_covar_names.
* delimiter: Delimiter used in the phenotype file.
* missing: Missing value key of phenotype file. Default is 'NA'.
* robust: Boolean: should robust (a.k.a. sandwich/Huber-White) standard errors be used?
* output_style: Optional string specifying the output columns to include: minimum (marginal and GxE estimates), meta (minimum plus main G and GxCovariate terms), or full (meta plus additionals fields necessary for re-analysis based on summary statistics alone). Default is 'minimum'.
* stream_snps: SNP numbers for each GWAS analysis.
* tol: Convergence tolerance for logistic regression.
* memory: Requested memory (in GB).
* cpu: Minimum number of requested cores.
* disk: Requested disk space (in GB).
* preemptible: Optional number of attempts using a preemptible machine from Google Cloud prior to falling back to a standard machine (default = 0, i.e., don't use preemptible).
* threads: Number of threads GEM should use for parallelization over variants.
* monitoring_freq: Delay between each output for process monitoring (in seconds). Default is 1 second.

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
