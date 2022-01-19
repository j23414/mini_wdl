version 1.0

# Preferred option
task nextstrain_build {
    input {
        File? build_yaml
        String dockerImage
        String nextstrain_app = "nextstrain"
        String giturl = "https://github.com/nextstrain/zika-tutorial/archive/refs/heads/master.zip"
    }
    command {
        # Pull ncov, zika or similar repository
        wget -O master.zip ~{giturl}
        INDIR=`unzip -Z1 master.zip | head -n1 | sed 's:/::g'`
        unzip master.zip

        # Max out the number of threads
        PROC=`nproc`

        # Run nextstrain
        "~{nextstrain_app}" build \
          --cpus $PROC \
          --native $INDIR \
          ${"--configfile " + build_yaml}

        mv $INDIR/auspice .
    }
    output {
        Array[File] auspice_dir = glob("auspice/*.json")
    }
    runtime {
        docker: dockerImage
    }
}

# Snakemake option
task nextstrain_build_snakemake {
    input {
        File input_zip
        String dockerImage
    }
    command {
        INDIR=`unzip -Z1 ~{input_zip} | head -n1 | sed 's:/::g'`
        unzip ~{input_zip}

        PROC=`nproc`
        snakemake -j $PROC --directory "$INDIR" --snakefile "$INDIR/Snakefile"
        cp -rf "$INDIR/results" results
        cp -rf "$INDIR/auspice" auspice

        zip -r auspice.zip auspice
    }
    output {
        File auspice_dir = "auspice.zip"
        Array[File] auspice_dir = glob("auspice/*.json")
    }
    runtime {
        docker: dockerImage
    }
}
