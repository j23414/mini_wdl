version 1.0

# Preferred option
task nextstrain_build {
    input {
        File input_dir
        String dockerImage
        String nextstrain_app = "nextstrain"
    }
    command {
        PROC=`nproc`
        "~{nextstrain_app}" build --cpus $PROC --native "${input_dir}"
        cp -rf "${input_dir}/results" results
        cp -rf "${input_dir}/auspice" auspice  
    }
    output {
        File auspice_dir = "auspice"
        File results_dir = "results"
    }
    runtime {
        docker: dockerImage
    }
}

# Snakemake option
task nextstrain_build_snakemake {
    input {
        File input_dir
        String dockerImage
    }
    command {
        PROC=`nproc`
        snakemake -j $PROC --directory "${input_dir}" --snakefile "${input_dir}/Snakefile"
        cp -rf "${input_dir}/results" results
        cp -rf "${input_dir}/auspice" auspice  
    }
    output {
        File auspice_dir = "auspice"
    }
    runtime {
        docker: dockerImage
    }
}
