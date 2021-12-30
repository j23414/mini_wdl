version 1.0

# Wrap in one task
task nextstrain_build {
    input {
        File input_dir
        String dockerImage
    }
    command {
        snakemake -j2 --directory "${input_dir}" --snakefile "${input_dir}/Snakefile"
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


# nextstrain build --cpus 1 "{input_dir}"