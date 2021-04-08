*** Settings ***
Resource          common.resource

*** Variables ***
${S3_BUCKET_NAME}    example-amazon-textract-pdf-invoice-bucket
${NUMBER_OF_IMG_INVOICES}    %{NUMBER_OF_IMG_INVOICES=10}
${NUMBER_OF_PDF_INVOICES}    %{NUMBER_OF_PDF_INVOICES=10}

*** Keywords ***
Scan Image With AWS Textract
    [Arguments]    ${document_filepath}
    ${response}=    Analyze Document    ${document_filepath}
    ${model}=    Convert Textract Response To Model    ${response}
    ${invoice}=    Set Variable    ${NONE}
    FOR    ${page}    IN    @{model.pages}
        IF    ${page.form.fields}
        ${invoice}=    Create AWS Invoice    ${page.form.fields}
        END
    END
    Log Many    ${response}
    [Return]    ${invoice}

*** Keywords ***
Scan PDF With AWS Textract
    [Arguments]    ${document_name}
    ${job_id}=    Start Document Analysis    ${S3_BUCKET_NAME}    ${document_name}
    [Return]    ${job_id}

*** Keywords ***
Wait For PDF Scans To Complete
    [Arguments]    ${jobs}
    ${invoices}=    Create List
    ${responses}=    Create List
    FOR    ${i}    IN RANGE    90
        ${len}=    Get Length    ${jobs}
        Exit For Loop If    ${len} == 0
        ${jobs_queue}=    Copy List    ${jobs}
        FOR    ${job_id}    IN    @{jobs_queue}
            ${response}=    Get Document Analysis    ${job_id}
            IF    "${response}[JobStatus]" == "SUCCEEDED"
            Remove Values From List    ${jobs}    ${job_id}
            Append To List    ${responses}    ${response}
            END
        END
        Sleep    2s
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
Create Invoice
    ${filename}=    Create Random Invoice
    [Return]    ${filename}

*** Keywords ***
Invoices to Excel
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
Create Invoices
    ${files}=    Create List
    Create Bucket    ${S3_BUCKET_NAME}
    FOR    ${idx}    IN RANGE    1    ${NUMBER_OF_PDF_INVOICES}+1
        ${filename}=    Set Variable    ${OUTPUT_DIR}${/}invoice_${idx}.pdf
        ${order_number}=    Create Random Invoice    ${filename}    ${idx}
        Append To List    ${files}    ${filename}
        ${basename}=    Evaluate    os.path.basename("${filename}")
        Upload File    ${S3_BUCKET_NAME}    ${filename}    ${basename}
    END
    FOR    ${idx}    IN RANGE    1    ${NUMBER_OF_IMG_INVOICES}+1
        ${filename}=    Set Variable    ${OUTPUT_DIR}${/}invoice_${idx}.png
        ${order_number}=    Create Random Image Invoice
        ...    ${CURDIR}${/}template_invoice.png
        ...    ${CURDIR}${/}Roboto-Black.ttf
        ...    ${filename}
        Append To List    ${files}    ${filename}
    END
    [Return]    ${files}
