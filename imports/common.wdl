
task sanitize_metadata {
    input {
        File metadata
        File configs
    }
    command {
        # metadata_id_columns=config["sanitize_metadata"]["metadata_id_columns"],
        # database_id_columns=config["sanitize_metadata"]["database_id_columns"]
        # parse_location_field=f"--parse-location-field {config['sanitize_metadata']['parse_location_field']}" if config["sanitize_metadata"].get("parse_location_field") else "",
        # rename_fields=config["sanitize_metadata"]["rename_fields"],
        # strain_prefixes=config["strip_strain_prefixes"],
        # error_on_duplicate_strains="--error-on-duplicate-strains" if config["sanitize_metadata"].get("error_on_duplicate_strains") else ""
        python3 scripts/sanitize_metadata.py \
          --metadata {metadata} \
          --metadata-id-columns \${metadata_id_columns} \
          --database-id-columns \${database_id_columns} \${parse_location_field} \
          --rename_fields \${rename_fields} \
          \${error_on_duplicate_strains} \
          --output {santized_metadata}
    }
    output {
        File santized_metadata
    }   
}

task combine_input_metadata {

}

task combining_sequences_for_subsampling {}

task proximity_score {}

task priority_score {}

task mask {}

task compress_build_align {}

task adjust_metadata_regions {}

task translate {}

task build_mutation_summary {}

task colors {}

task recency {}

task logistic_growth {}

task calculate_epiweeks {}

task add_branch_labels {}

task include_hcov19_prefix {}

task finalize {}