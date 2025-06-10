version 1.0

workflow run_GEM {
  input {
    Array[File]? bgenfiles
    Array[File]? pgenfiles
    Array[File]? pvarfiles
    Array[File]? bedfiles
    Array[File]? bimfiles

    String? unused # WDL 1.0 has no "None" value yet. Workaround: using a never-defined optional value.
  }

  Int n_files = if (defined(bgenfiles)) then length(select_first([bgenfiles])) else if (defined(pgenfiles)) then length(select_first([pgenfiles])) else length(select_first([bedfiles]))

  scatter (i in range(n_files)) {
    call run_tests {
      input:
        bgenfile = if defined(bgenfiles) && i < length(select_first([bgenfiles])) && defined(select_first([bgenfiles])[i]) then select_first([bgenfiles])[i] else unused,
        pgenfile = if defined(pgenfiles) && i < length(select_first([pgenfiles])) && defined(select_first([pgenfiles])[i]) then select_first([pgenfiles])[i] else unused,
        pvarfile = if defined(pvarfiles) && i < length(select_first([pvarfiles])) && defined(select_first([pvarfiles])[i]) then select_first([pvarfiles])[i] else unused,
        bedfile  = if defined(bedfiles)  && i < length(select_first([bedfiles]))  && defined(select_first([bedfiles])[i])  then select_first([bedfiles])[i]  else unused,
        bimfile  = if defined(bimfiles)  && i < length(select_first([bimfiles]))  && defined(select_first([bimfiles])[i])  then select_first([bimfiles])[i]  else unused,
    }
  }

  Array[File]  results_array = run_tests.out
  Array[File]? sru = run_tests.system_resource_usage
  Array[File]? pru = run_tests.process_resource_usage

  call cat_results { input: results_array = results_array }

  output {
          File   gem_results = cat_results.all_results
    Array[File]  gem_log = run_tests.log
    Array[File]? system_resource_usage = sru
    Array[File]? process_resource_usage = pru
  }

  parameter_meta {
    bgenfiles: "Array of genotype filepaths in .bgen format. Optional, but either this or pgenfiles must be specified as an input."
    samplefile: "Optional .sample file accompanying the .bgen file. Required for proper function if .bgen does not store sample identifiers."
    pgenfiles: "Array of genotype filepaths in .pgen (PLINK2) format. Optional, but at least one genotype dataset must be specified as an input."
    psamfile: "Sample descriptor file in .psam (PLINK2) format. Optional, but must be included if using the pgenfiles input."
    pvarfiles: "Array of variant descriptor filepaths in .pvar (PLINK2) format. Optional, but must be included if using the pgenfiles input."
    bedfiles: "Array of genotype filepaths in .bed (PLINK1) format. Optional, but at least one genotype dataset must be specified as an input."
    famfile: "Sample descriptor file in .fam (PLINK1) format. Optional, but must be included if using the bedfiles input."
    bimfiles: "Array of variant descriptor filepaths in .bim (PLINK1) format. Optional, but must be included if using the bedfiles input."
    maf: "Minor allele frequency threshold for pre-filtering variants as a fraction (default is 0.005)."
    miss_geno_cutoff: "Maximum threshold value [0, 1.0] to filter variants based on the missing genotype rate. Default is 0.05."
    pheno_file: "Phenotype filepath."
    sampleid_name: "Optional column header name of sample ID in phenotype file."
    pheno_name: "Column header name of phenotype data in phenotype file."
    exposure_names: "Column header name(s) of the exposures for genotype interaction testing (space-delimited)."
    int_covar_names: "Column header name(s) of any covariates for which genotype interactions should be included for adjustment in regression (space-delimited). These terms will not be included in any multi-exposure interaction tests. This set should not overlap with exposures or covar_names."
    covar_names: "Column header name(s) of any covariates for which only main effects should be included selected covariates in the pheno data file (space-delimited). This set should not overlap with exposures or int_covar_names."
    categorical_names: "Names of the exposure or interaction covariate that should be treated as categorical."
    cat_threshold: "A cut-off to determine which exposure or interaction covariate not specified using --categorical-names should be automatically treated as categorical based on the number of levels (unique observations)."
    include_snp_file: "Optional path to file containing a subset of variants in the specified genotype file to be used for analysis. The first line in this file is the header that specifies which variant identifier in the genotype file is used for ID matching. This must be 'snpid' (PLINK or BGEN) or 'rsid' (BGEN only). There should be one variant identifier per line after the header."
    center: "Should exposures and interaction covariates be centered prior to analyis? 0: no, 1: yes, 2: interaction covariates only. Default is 2."
    delimiter: "Delimiter used in the phenotype file."
    kin_delim: "Delimiter used in the kinship file."
    kin_file: "Path to the kinship file."
    kin_diag: "Diagonal value of kinship matrix not accounting for inbreeding."
    missing: "Missing value key of phenotype file. Default is 'NA'."
    robust: "Boolean: should robust (a.k.a. sandwich/Huber-White) standard errors be used?"
    scale: "Boolean: should ALL exposures and covariates be scaled by the standard deviation?"
    output_style: "Optional string specifying the output columns to include: minimum (marginal and GxE estimates), meta (minimum plus main G and GxCovariate terms), or full (meta plus additionals fields necessary for re-analysis based on summary statistics alone). Default is 'minimum'."
    stream_snps: "SNP numbers for each GWAS analysis."
    tol: "Convergence tolerance for logistic regression."
    memory_gb: "Requested memory (in GB)."
    n_cpu: "Minimum number of requested cores."
    disk_gb: "Requested disk space (in GB)."
    preemptible: "Optional number of attempts using a preemptible machine from Google Cloud prior to falling back to a standard machine (default = 0, i.e., don't use preemptible)."
    threads: "Number of threads GEM should use for parallelization over variants."
    monitoring_freq: "Delay between each output for process monitoring (in seconds). Default is 1 second."
    random_slope: "Column name in the phenotype file that contains random slope."
  }

  meta {
    author: "Kenny Westerman"
    email: "kewesterman@mgh.harvard.edu"
    description: "Run gene-environment interaction tests using GEM and return a file of summary statistics."
  }
}


task run_tests {
  input {
    # Scattered inputs
       File? bgenfile
       File? pgenfile
       File? pvarfile
       File? bedfile
       File? bimfile

    # Additional required inputs
       File? psamfile
       File? samplefile
       File? famfile
       File  pheno_file
     String  pheno_name
     String  sampleid_name

    # Options
       File? kin_file
       File? include_snp_file
     String? exposure_names
     String? covar_names
     String? int_covar_names
     String? categorical_names
     String? random_slope
     String  kin_delim        = ","
     String  delimiter        = ","
     String  missing          = "NA"
     String  output_style     = "minimum"
    Boolean  scale            = false
    Boolean  robust           = false
      Float  kin_diag         = 1.0
      Float  miss_geno_cutoff = 0.05
      Float  maf              = 0.001
      Float  tol              = 0.0000001
        Int  center           = 2
        Int  cat_threshold    = 2

    # Compute resources
        Int threads         = 3
        Int n_cpu           = 4
        Int disk_gb         = 50
        Int memory_gb       = 10
        Int preemptible     = 0
        Int maxRetries      = 0
        Int stream_snps     = 1
        Int monitoring_freq = 1
  }

  String robust01 = if robust then "1" else "0"
  String  scale01 = if scale  then "1" else "0"

  command <<<
    dstat -c -d -m --nocolor ~{monitoring_freq} > system_resource_usage.log &
    atop -x -P PRM ~{monitoring_freq} | grep '(GEM)' > process_resource_usage.log &

    /GEM \
      ~{"--bgen "              +          bgenfile} \
      ~{"--sample "            +        samplefile} \
      ~{"--pgen "              +          pgenfile} \
      ~{"--pvar "              +          pvarfile} \
      ~{"--psam "              +          psamfile} \
      ~{"--bed "               +           bedfile} \
      ~{"--bim "               +           bimfile} \
      ~{"--fam "               +           famfile} \
      ~{"--kin-file "          +          kin_file} \
      ~{"--include-snp-file "  +  include_snp_file} \
      ~{"--exposure-names "    +    exposure_names} \
      ~{"--covar-names "       +       covar_names} \
      ~{"--int-covar-names "   +   int_covar_names} \
      ~{"--categorical-names " + categorical_names} \
      ~{"--random-slope "      +      random_slope} \
      --kin-delim                      ~{kin_delim} \
      --kin-diag                        ~{kin_diag} \
      --maf                                  ~{maf} \
      --miss-geno-cutoff        ~{miss_geno_cutoff} \
      --pheno-file                    ~{pheno_file} \
      --sampleid-name              ~{sampleid_name} \
      --pheno-name                    ~{pheno_name} \
      --cat-threshold              ~{cat_threshold} \
      --center                            ~{center} \
      --scale                            ~{scale01} \
      --delim                          ~{delimiter} \
      --missing-value                    ~{missing} \
      --robust                          ~{robust01} \
      --output-style                ~{output_style} \
      --tol                                  ~{tol} \
      --threads                          ~{threads} \
      --stream-snps                  ~{stream_snps} \
      --out gem_res > gem_log.log
  >>>

  runtime {
    docker: "quay.io/large-scale-gxe-methods/gem-workflow@sha256:ab7c82aaa2e77e265b597a4a204bc30c83a94a4cba3d4d10935dfa0d74ecfec3"
    memory: "~{memory_gb} GB"
    cpu: "~{n_cpu}"
    disks: "local-disk ~{disk_gb} HDD"
    preemptible: "~{preemptible}"
    maxRetries: "~{maxRetries}"
    gpu: false
    dx_timeout: "7D0H00M"
  }

  output {
    File out = "gem_res"
    File log = "gem_log.log"
    File system_resource_usage = "system_resource_usage.log"
    File process_resource_usage = "process_resource_usage.log"
  }
}


task cat_results {
  input { Array[File] results_array }

  command <<<
    head -1 ~{results_array[0]} > all_results.txt && \
      for res in ~{sep=" " results_array}; do tail -n +2 $res >> all_results.txt; done
  >>>
  
  runtime {
    docker: "quay.io/large-scale-gxe-methods/ubuntu:focal-20210325"
    disks: "local-disk 10 HDD"
  }

  output { File all_results = "all_results.txt" }
}
