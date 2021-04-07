*** Settings ***
Documentation     Analyze PDF invoice using Amazon Textract.
Library           RPA.Cloud.AWS
...               region=us-east-1
...               robocloud_vault_name=aws
Library           RPA.JSON
Suite Setup       Init Amazon clients

*** Variables ***
${PDF}=           example-invoice.pdf
${S3_BUCKET}=     example-amazon-textract-pdf-invoice-bucket

*** Keywords ***
Init Amazon clients
    Init S3 Client    use_robocloud_vault=${True}
    Init Textract Client    use_robocloud_vault=${True}

Upload PDF
    Create Bucket    ${S3_BUCKET}
    Upload File    ${S3_BUCKET}    ${CURDIR}${/}${PDF}

Start analysis
    ${job_id}=    Start Document Analysis
    ...    bucket_name_in=${S3_BUCKET}
    ...    bucket_name_out=${S3_BUCKET}
    ...    object_name_in=${PDF}
    [Return]    ${job_id}

Wait for analysis
    [Arguments]    ${job_id}
    FOR    ${i}    IN RANGE    50
        ${result}=    Get Document Analysis    ${job_id}
        Exit For Loop If    "${result}[JobStatus]" == "SUCCEEDED"
        Sleep    5s
    END
    [Return]    ${result}

Save result
    [Arguments]    ${result}
    ${pages_and_text}=    Get Pages And Text    ${result}
    ${words}=    Get Words
    ${tables}=    Get Tables
    ${cells}=    Get Cells
    Save JSON To File    ${result}    ${OUTPUT_DIR}${/}result.json
    Save JSON To File    ${pages_and_text}    ${OUTPUT_DIR}${/}pages-and-text.json
    Save JSON To File    ${words}    ${OUTPUT_DIR}${/}words.json
    Save JSON To File    ${tables}    ${OUTPUT_DIR}${/}tables.json
    Save JSON To File    ${cells}    ${OUTPUT_DIR}${/}cells.json

*** Tasks ***
Analyze PDF invoice using Amazon Textract
    Upload PDF
    ${job_id}=    Start analysis
    ${result}=    Wait for analysis    ${job_id}
    Save result    ${result}
