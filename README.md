# WDL Test

**Repos:**

* [ncov](https://github.com/nextstrain/ncov)
* [zika-tutorial/wdl](https://github.com/nextstrain/zika-tutorial/tree/wdl)
* [corneliusroemer/ncov-simplest](https://github.com/corneliusroemer/ncov-simplest)
* [theiagen/public\_health\_viral\_genomics](https://github.com/theiagen/public_health_viral_genomics)

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

# Option 1: one wrapped task
cromwell run workflow.wdl \
  -i inputs_option1.json \
  -o options.json \
  &> log.txt

# Option 2: separate tasks
git clone https://github.com/nextstrain/zika-tutorial.git

cromwell run workflow.wdl \
  -i inputs_option2.json \
  -o options.json \
  &> log.txt
```

Output:

```
# Option 1
ls -1tr results

|_ auspice/  #<= this one

# Option 2
ls -1tr results

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
