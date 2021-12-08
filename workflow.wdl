# https://docs.dockstore.org/en/develop/advanced-topics/best-practices/wdl-best-practices.html

import "imports/common.wdl"
import "imports/augur.wdl"

workflow main_workflow {
    input {
        File sequences
        File metadata
    }
    call index { input: sequences=sequences }
}