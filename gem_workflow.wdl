workflow run_GEM {

	Array[File]? bgenfiles
	File? samplefile
	Array[File]? pgenfiles
	File? psamfile
	Array[File]? pvarfiles
	Array[File]? bedfiles
	File? famfile
	Array[File]? bimfiles
	Float? maf = 0.005
	File phenofile
	String? sample_id_header = "sampleID"
	String outcome
	Boolean binary_outcome
	String exposure_names
	String? int_covar_names
	String? covar_names
	String? delimiter = ","
	String? missing = "NA"
	Boolean robust
	String? output_style = "minimum"
	Int? stream_snps = 1
	Float? tol = 0.000001
	Int? memory = 10
	Int? cpu = 4
	Int? disk = 50
	Int? preemptible = 0
	Int? threads = 2
	Int? monitoring_freq = 1

	Int n_files = if (defined(bgenfiles)) then length(select_first([bgenfiles])) else if (defined(pgenfiles)) then length(select_first([pgenfiles])) else length(select_first([bedfiles]))

	if (defined(bgenfiles)) {
		scatter (i in range(n_files)) {
			call run_tests_bgen {
				input:
					bgenfile = select_first([bgenfiles])[i],
					samplefile = samplefile,
					maf = maf,
					phenofile = phenofile,
					sample_id_header = sample_id_header,
					outcome = outcome,
					binary_outcome = binary_outcome,
					exposure_names = exposure_names,
					int_covar_names = int_covar_names,
					covar_names = covar_names,
					delimiter = delimiter,
					missing = missing,
					robust = robust,
					output_style = output_style,
					stream_snps = stream_snps,
					tol = tol,
					memory = memory,
					cpu = cpu,
					disk = disk,
					preemptible = preemptible,
					threads = threads,
					monitoring_freq = monitoring_freq
			}
		}
	}

	if (defined(pgenfiles)) {
		scatter (i in range(n_files)) {
			call run_tests_pgen {
				input:
					pgenfile = select_first([pgenfiles])[i],
					psamfile = psamfile,
					pvarfile = select_first([pvarfiles])[i],
					maf = maf,
					phenofile = phenofile,
					sample_id_header = sample_id_header,
					outcome = outcome,
					binary_outcome = binary_outcome,
					exposure_names = exposure_names,
					int_covar_names = int_covar_names,
					covar_names = covar_names,
					delimiter = delimiter,
					missing = missing,
					robust = robust,
					output_style = output_style,
					stream_snps = stream_snps,
					tol = tol,
					memory = memory,
					cpu = cpu,
					disk = disk,
					preemptible = preemptible,
					threads = threads,
					monitoring_freq = monitoring_freq
			}
		}
	}

	if (defined(bedfiles)) {
		scatter (i in range(n_files)) {
			call run_tests_bed {
				input:
					bedfile = select_first([bedfiles])[i],
					famfile = famfile,
					bimfile = select_first([bimfiles])[i],
					maf = maf,
					phenofile = phenofile,
					sample_id_header = sample_id_header,
					outcome = outcome,
					binary_outcome = binary_outcome,
					exposure_names = exposure_names,
					int_covar_names = int_covar_names,
					covar_names = covar_names,
					delimiter = delimiter,
					missing = missing,
					robust = robust,
					output_style = output_style,
					stream_snps = stream_snps,
					tol = tol,
					memory = memory,
					cpu = cpu,
					disk = disk,
					preemptible = preemptible,
					threads = threads,
					monitoring_freq = monitoring_freq
			}
		}
	}

	Array[File]? results_array = if (defined(bgenfiles)) then run_tests_bgen.out else if (defined(pgenfiles)) then run_tests_pgen.out else run_tests_bed.out
	Array[File]? sru = if (defined(bgenfiles)) then run_tests_bgen.system_resource_usage else if (defined(pgenfiles)) then run_tests_pgen.system_resource_usage else run_tests_bed.system_resource_usage
	Array[File]? pru = if (defined(bgenfiles)) then run_tests_bgen.process_resource_usage else if (defined(pgenfiles)) then run_tests_pgen.process_resource_usage else run_tests_bed.process_resource_usage

	call cat_results {
		input:
			results_array = results_array
	}

	output {
		File gem_results = cat_results.all_results
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
		phenofile: "Phenotype filepath."	
		sample_id_header: "Optional column header name of sample ID in phenotype file."
		outcome: "Column header name of phenotype data in phenotype file."
                binary_outcome: "Boolean: is the outcome binary? Otherwise, quantitative is assumed."
		exposure_names: "Column header name(s) of the exposures for genotype interaction testing (space-delimited)."
		int_covar_names: "Column header name(s) of any covariates for which genotype interactions should be included for adjustment in regression (space-delimited). These terms will not be included in any multi-exposure interaction tests. This set should not overlap with exposures or covar_names."
		covar_names: "Column header name(s) of any covariates for which only main effects should be included selected covariates in the pheno data file (space-delimited). This set should not overlap with exposures or int_covar_names."
		delimiter: "Delimiter used in the phenotype file."
		missing: "Missing value key of phenotype file. Default is 'NA'."
                robust: "Boolean: should robust (a.k.a. sandwich/Huber-White) standard errors be used?"
		output_style: "Optional string specifying the output columns to include: minimum (marginal and GxE estimates), meta (minimum plus main G and GxCovariate terms), or full (meta plus additionals fields necessary for re-analysis based on summary statistics alone). Default is 'minimum'."
		stream_snps: "SNP numbers for each GWAS analysis."
		tol: "Convergence tolerance for logistic regression."
		memory: "Requested memory (in GB)."
		cpu: "Minimum number of requested cores."
		disk: "Requested disk space (in GB)."
		preemptible: "Optional number of attempts using a preemptible machine from Google Cloud prior to falling back to a standard machine (default = 0, i.e., don't use preemptible)."
		threads: "Number of threads GEM should use for parallelization over variants."
		monitoring_freq: "Delay between each output for process monitoring (in seconds). Default is 1 second."
	}

        meta {
                author: "Kenny Westerman"
                email: "kewesterman@mgh.harvard.edu"
                description: "Run gene-environment interaction tests using GEM and return a file of summary statistics."
        }
}


task run_tests_bgen {

	File bgenfile
	File? samplefile
	Float maf
	File phenofile
	String sample_id_header
	String outcome
	Boolean binary_outcome
	String exposure_names
	String? int_covar_names
	String? covar_names
	String delimiter
	String missing
	Boolean robust
	String output_style
	Float tol
	Int threads
	Int stream_snps
	Int memory
	Int cpu
	Int disk
	Int preemptible
	Int monitoring_freq

	String binary_outcome01 = if binary_outcome then "1" else "0"
	String robust01 = if robust then "1" else "0"

	command {
		dstat -c -d -m --nocolor ${monitoring_freq} > system_resource_usage.log &
		atop -x -P PRM ${monitoring_freq} | grep '(GEM)' > process_resource_usage.log &

		/GEM/GEM \
			--bgen ${bgenfile} \
			${"--sample " + samplefile} \
			--maf ${maf} \
			--pheno-file ${phenofile} \
			--sampleid-name ${sample_id_header} \
			--pheno-name ${outcome} \
			--pheno-type ${binary_outcome01} \
			--exposure-names ${exposure_names} \
			${"--int-covar-names " + int_covar_names} \
			${"--covar-names " + covar_names} \
			--delim ${delimiter} \
			--missing-value ${missing} \
			--robust ${robust01} \
			--output-style ${output_style} \
			--tol ${tol} \
			--threads ${threads} \
			--stream-snps ${stream_snps} \
			--out gem_res
	}

	runtime {
		docker: "quay.io/large-scale-gxe-methods/gem-workflow@sha256:9c7041f607a47a5e999a647e4ab145ad3d812e7f63a9d73786068188456b8915"
		memory: "${memory} GB"
		cpu: "${cpu}"
		disks: "local-disk ${disk} HDD"
		preemptible: "${preemptible}"
		gpu: false
		dx_timeout: "7D0H00M"
	}

	output {
		File out = "gem_res"
		File system_resource_usage = "system_resource_usage.log"
		File process_resource_usage = "process_resource_usage.log"
	}
}


task run_tests_pgen {

	File pgenfile
	File psamfile
	File pvarfile
	Float maf
	File phenofile
	String sample_id_header
	String outcome
	Boolean binary_outcome
	String exposure_names
	String? int_covar_names
	String? covar_names
	String delimiter
	String missing
	Boolean robust
	String output_style
	Float tol
	Int threads
	Int stream_snps
	Int memory
	Int cpu
	Int disk
	Int preemptible
	Int monitoring_freq

	String binary_outcome01 = if binary_outcome then "1" else "0"
	String robust01 = if robust then "1" else "0"

	command {
		dstat -c -d -m --nocolor ${monitoring_freq} > system_resource_usage.log &
		atop -x -P PRM ${monitoring_freq} | grep '(GEM)' > process_resource_usage.log &

		/GEM/GEM \
			--pgen ${pgenfile} \
			--psam ${psamfile} \
			--pvar ${pvarfile} \
			--maf ${maf} \
			--pheno-file ${phenofile} \
			--sampleid-name ${sample_id_header} \
			--pheno-name ${outcome} \
			--pheno-type ${binary_outcome01} \
			--exposure-names ${exposure_names} \
			${"--int-covar-names " + int_covar_names} \
			${"--covar-names " + covar_names} \
			--delim ${delimiter} \
			--missing-value ${missing} \
			--robust ${robust01} \
			--output-style ${output_style} \
			--tol ${tol} \
			--threads ${threads} \
			--stream-snps ${stream_snps} \
			--out gem_res
	}

	runtime {
		docker: "quay.io/large-scale-gxe-methods/gem-workflow@sha256:9c7041f607a47a5e999a647e4ab145ad3d812e7f63a9d73786068188456b8915"
		memory: "${memory} GB"
		cpu: "${cpu}"
		disks: "local-disk ${disk} HDD"
		preemptible: "${preemptible}"
		gpu: false
		dx_timeout: "7D0H00M"
	}

	output {
		File out = "gem_res"
		File system_resource_usage = "system_resource_usage.log"
		File process_resource_usage = "process_resource_usage.log"
	}
}


task run_tests_bed {

	File bedfile
	File famfile
	File bimfile
	Float maf
	File phenofile
	String sample_id_header
	String outcome
	Boolean binary_outcome
	String exposure_names
	String? int_covar_names
	String? covar_names
	String delimiter
	String missing
	Boolean robust
	String output_style
	Float tol
	Int threads
	Int stream_snps
	Int memory
	Int cpu
	Int disk
	Int preemptible
	Int monitoring_freq

	String binary_outcome01 = if binary_outcome then "1" else "0"
	String robust01 = if robust then "1" else "0"

	command {
		dstat -c -d -m --nocolor ${monitoring_freq} > system_resource_usage.log &
		atop -x -P PRM ${monitoring_freq} | grep '(GEM)' > process_resource_usage.log &

		/GEM/GEM \
			--bed ${bedfile} \
			--fam ${famfile} \
			--bim ${bimfile} \
			--maf ${maf} \
			--pheno-file ${phenofile} \
			--sampleid-name ${sample_id_header} \
			--pheno-name ${outcome} \
			--pheno-type ${binary_outcome01} \
			--exposure-names ${exposure_names} \
			${"--int-covar-names " + int_covar_names} \
			${"--covar-names " + covar_names} \
			--delim ${delimiter} \
			--missing-value ${missing} \
			--robust ${robust01} \
			--output-style ${output_style} \
			--tol ${tol} \
			--threads ${threads} \
			--stream-snps ${stream_snps} \
			--out gem_res
	}

	runtime {
		docker: "quay.io/large-scale-gxe-methods/gem-workflow@sha256:9c7041f607a47a5e999a647e4ab145ad3d812e7f63a9d73786068188456b8915"
		memory: "${memory} GB"
		cpu: "${cpu}"
		disks: "local-disk ${disk} HDD"
		preemptible: "${preemptible}"
		gpu: false
		dx_timeout: "7D0H00M"
	}

	output {
		File out = "gem_res"
		File system_resource_usage = "system_resource_usage.log"
		File process_resource_usage = "process_resource_usage.log"
	}
}


task cat_results {

	Array[File] results_array

	command {
		head -1 ${results_array[0]} > all_results.txt && \
			for res in ${sep=" " results_array}; do tail -n +2 $res >> all_results.txt; done
	}
	
	runtime {
		docker: "quay.io/large-scale-gxe-methods/ubuntu:focal-20210325"
		disks: "local-disk 10 HDD"
	}

	output {
		File all_results = "all_results.txt"
	}
}
