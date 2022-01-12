version 1.0

# Preferred option
task nextstrain_build {
    input {
        File? build_yaml
        String indir = "zika-tutorial-master"
        String outfile = "zika"
        String dockerImage
        String nextstrain_app = "nextstrain"
        String giturl = "https://github.com/nextstrain/zika-tutorial/archive/refs/heads/master.zip"
    }
    command {
        wget ~{giturl}
        unzip master.zip

        PROC=`nproc`
        
        "~{nextstrain_app}" build \
          --cpus $PROC \
          --native ~{indir} \
          ${"--configfile " + build_yaml}

    }
    output {
        File auspice_dir = "~{indir}/auspice/~{outfile}.json"
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

# Test this first, generalize later
task nextstrain_build_zika {
    input {
        File input_zip
        String dockerImage
        String nextstrain_app = "nextstrain"
    }
    command {
        PROC=`nproc`
        unzip ~{input_zip}
        mv zika-tutorial-master zika-tutorial
        "~{nextstrain_app}" build --cpus $PROC --native zika-tutorial
        cp -rf zika-tutorial/results results
        cp -rf zika-tutorial/auspice auspice  
    }
    output {
        File auspice_dir = "auspice/zika.json" # wild cards?
    }
    runtime {
        docker: dockerImage
    }
}