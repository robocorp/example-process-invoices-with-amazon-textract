*** Settings ***
Resource          common.resource

*** Variables ***
${S3_BUCKET_NAME}    example-amazon-textract-pdf-invoice-bucket
${NUMBER_OF_INVOICES}    %{NUMBER_OF_INVOICES=10}

*** Keywords ***
Process PDF with Amazon Textract
    [Arguments]    ${filename}
    ${job_id}=    Start Document Analysis    ${S3_BUCKET_NAME}    ${filename}
    [Return]    ${job_id}

*** Keywords ***
Wait For PDF Processing Results
    [Arguments]    ${job_ids}
    ${invoices}=    Create List
    ${responses}=    Create List
    FOR    ${i}    IN RANGE    90
        ${jobs_length}=    Get Length    ${job_ids}
        Exit For Loop If    ${jobs_length} == 0
        ${jobs_queue}=    Copy List    ${job_ids}
        FOR    ${job_id}    IN    @{jobs_queue}
            ${response}=    Get Document Analysis    ${job_id}
            IF    "${response}[JobStatus]" == "SUCCEEDED"
            Remove Values From List    ${job_ids}    ${job_id}
            Append To List    ${responses}    ${response}
            END
        END
        Sleep    3s
    END
    FOR    ${response}    IN    @{responses}
        ${model}=    Convert Textract Response To Model    ${response}
        ${invoice}=    Set Variable    ${NONE}
        FOR    ${page}    IN    @{model.pages}
            IF    ${page.form.fields}
            ${invoice}=    Create AWS Invoice    ${page.form.fields}
            Append To List    ${invoices}    ${invoice}
            END
        END
    END
    [Return]    ${invoices}

*** Keywords ***
Save Invoices To Excel
    [Arguments]    ${invoices}
    Create Workbook    ${OUTPUT_DIR}${/}invoices.xlsx
    FOR    ${invoice}    IN    @{invoices}
        &{row}=    Create Dictionary
        ...    To    ${invoice}[to]
        ...    Invoice Number    ${invoice}[invoice_number]
        ...    Order Number    ${invoice}[order_number]
        ...    Invoice Date    ${invoice}[invoice_date]
        ...    Due Date    ${invoice}[due_date]
        ...    Balance Due    ${invoice}[balance_due]
        Append Rows to Worksheet    ${row}    header=True
    END
    Save Workbook

*** Keywords ***
Create PDF Invoice
    [Arguments]    ${index}
    ${filename}=    Set Variable    invoice_${index}.pdf
    ${file_path}=    Set Variable    ${OUTPUT_DIR}${/}${filename}
    Create Random Invoice    ${file_path}    ${index}
    ${upload_status}=    Upload File
    ...    ${S3_BUCKET_NAME}
    ...    ${file_path}
    ...    ${filename}

*** Keywords ***
Create Invoices
    ${bucket_created}=    Create Bucket    ${S3_BUCKET_NAME}
    FOR    ${index}    IN RANGE    1    ${NUMBER_OF_INVOICES}+1
        Create PDF Invoice    ${index}
    END

*** Keywords ***
Get File Keys From Amazon S3 Bucket
    ${files}=    List Files    ${S3_BUCKET_NAME}
    @{keys}=    Create List
    FOR    ${file}    IN    @{files}
        Append To List    ${keys}    ${file}[Key]
    END
    [Return]    ${keys}

*** Keywords ***
Delete Files From Amazon S3 Bucket
    ${keys}=    Get File Keys From Amazon S3 Bucket
    ${deleted}=    Delete Files    ${S3_BUCKET_NAME}    ${keys}
