# WDL Test

**Repos:**

* [ncov](https://github.com/nextstrain/ncov)
* [zika-tutorial/wdl](https://github.com/nextstrain/zika-tutorial/tree/wdl)
* [corneliusroemer/ncov-simplest](https://github.com/corneliusroemer/ncov-simplest)

**Seems to already exist:**

* https://dockstore.org/search?descriptorType=WDL&entryType=workflows&search=nextstrain
* Terra Workspace: https://app.terra.bio/#workspaces/pathogen-genomic-surveillance/COVID-19_Broad_Viral_NGS

**References:**

* [WDL Best Practices](https://docs.dockstore.org/en/develop/advanced-topics/best-practices/wdl-best-practices.html)
* [broadinstitute/viral-pipelines/pipes](https://github.com/broadinstitute/viral-pipelines/tree/master/pipes)
* [Intro to Docker, WDL, CWL](https://bdcatalyst.gitbook.io/biodata-catalyst-documentation/written-documentation/getting-started/analyze-data-1/dockstore/intro-to-docker-wdl-cwl)

## Local testing

The native install seems to require Java 11 (didn't want to mess up my nextflow environment which requires Java 8, I think...). Therefore went the Homebrew route.

* [ONT Installing Dependencies](https://dockstore.org/workflows/github.com/aryeelab/nanopore_tools/combine_sample_sheets:dev?tab=info)

```
brew install cromwell
```

* https://cromwell.readthedocs.io/en/stable/tutorials/FiveMinuteIntro/

```
# Start docker deamon
ln -s zika-tutorial/data .
ln -s zika-tutorial/config .
cromwell run workflow.wdl -i inputs.json
```

Output:

```
ls -1tr cromwell-executions/workflow/40e06f85-619c-40d3-a544-67b5e63a94e6/

|_ call-IndexSequences
|_ call-Filter
|_ call-Align
|_ call-Tree
|_ call-Refine
|_ call-Ancestral
|_ call-Traits
|_ call-Translate
|_ call-Export
    |_ zika.json        #<= this one!
```

### Option 1: wrap it in one task

This was more difficult than expected. I was expecting to use

```
nextstrain build --cpus ${input_dir}
```

But kept hitting `bin/docker` errors, so used the snakemake command directly. Even then, the output files took a while to reroute.

```
git clone https://github.com/nextstrain/zika-tutorial.git
cromwell run workflow.wdl -i one.json

ls -1tr cromwell-executions/Nextstrain_WRKFLW/254d2b55-a0d6-4b52-841d-5e3fc430b83e/call-build/execution/

#> results/
#> auspice/
```

## Debug Notes

Cromwell runs creates a `cromwell-execution` folder. (In comparison, Nextflow creates a `work` folder. I'm not sure if Snakemake creates a cache folder.) Haven't figured out how to reroute the cromwell output to a separate folder yet.

```
cromwell-executions/
  |_ Nextstrain_WRKFLW/
    |_ 6995bcdf-6c11-4a08-ab08-94bacc5796b2/
      |_ call-build/
        |_ tmp.760887c3
        |
        |_ inputs/
        | |_ -414136411/
        |   |_ zika-tutorial/
        |
        |_ execution/
          |_ script
          |_ script.background
          |_ script.submit
          |_ docker_cid
          |_ rc
          |
          |_ stdout    #<= check these files to debug
          |_ stderr    #<=
          |_ stdout.background
          |_ stderr.background
          |
          |_ results/  #<= output, must be in this folder, can't be in input folder or it will fail
          |_ auspice/
```
