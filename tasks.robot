*** Settings ***
Documentation     Processes PDF and image invoices with Amazon Textract.
...               Saves the extracted invoice data in an Excel file.
Resource          invoices.resource

*** Tasks ***
Process PDF invoices with Amazon Textract
    [Setup]    Initialize Amazon Clients
    @{job_ids}=    Create List
    ${pdf_files}=    Get File Keys From Amazon S3 Bucket
    FOR    ${pdf_file}    IN    @{pdf_files}
        ${job_id}=    Process PDF with Amazon Textract    ${pdf_file}
        Append To List    ${job_ids}    ${job_id}
    END
    ${invoices}=    Wait For PDF Processing Results    ${job_ids}
    Save Invoices To Excel    ${invoices}

*** Tasks ***
Process image invoices with Amazon Textract
    [Setup]    Initialize Amazon Clients
    @{invoices}=    Create List
    ${png_files}=    Get Invoice Files    png
    FOR    ${png_file}    IN    @{png_files}
        ${filename}=    Set Variable    ${INVOICES_DIR}${/}${png_file}
        Copy File    ${filename}    ${OUTPUT_DIR}
        ${invoice}=    Process Image With AWS Textract    ${filename}
        IF    ${invoice}
        Append To List    ${invoices}    ${invoice}
        END
    END
    Save Invoices To Excel    ${invoices}

*** Tasks ***
Create Invoices
    [Setup]    Initialize Amazon Clients
    Create Invoices
