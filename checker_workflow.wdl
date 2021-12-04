# GEM version 1.4.1

import "gem_workflow.wdl" as gem_wf


workflow checker {

	Array[File] bgenfiles
	Float maf
	File phenofile
	String sample_id_header
	String outcome
	String exposure_names
	String int_covar_names
	String covar_names
	String missing
	Boolean robust
	Int memory
	Int disk
	File expected_sumstats

  call gem_wf.run_GEM {
    input:
			bgenfiles = bgenfiles,
			maf = maf,
			phenofile = phenofile,
			sample_id_header = sample_id_header,
			outcome = outcome,
			exposure_names = exposure_names,
			int_covar_names = int_covar_names,
			covar_names = covar_names,
			missing = missing,
			robust = robust,
			memory = memory,
			disk = disk
  }

  call md5sum {
    input:
			sumstats = run_GEM.gem_results,
			expected_sumstats = expected_sumstats
  }

  meta {
    author: "Kenny Westerman"
    email: "kewesterman@mgh.harvard.edu"
  }

}


task md5sum {

	File sumstats
	File expected_sumstats

  command <<<
		md5sum ${sumstats} > sum.txt
		md5sum ${expected_sumstats} > expected_sum.txt

		# temporarily outputting to stderr for clarity's sake
		>&2 echo "Output checksum:"
		>&2 cat sum.txt
		>&2 echo "-=-=-=-=-=-=-=-=-=-"
		>&2 echo "Truth checksum:"
		>&2 cat expected_sum.txt
		>&2 echo "-=-=-=-=-=-=-=-=-=-"
		>&2 echo "Head of the output file:"
		>&2 head ${sumstats}
		>&2 echo "-=-=-=-=-=-=-=-=-=-"
		>&2 echo "Head of the truth file:"
		>&2 head ${expected_sumstats}

		echo "$(cut -f1 -d' ' expected_sum.txt) ${sumstats}" | md5sum --check
  >>>

  runtime {
    docker: "quay.io/large-scale-gxe-methods/ubuntu:focal-20210325"
  }
}


