*** Settings ***
Documentation     Processes PDF invoices with Amazon Textract.
...               Saves the extracted invoice data in an Excel file.
Resource          invoices.resource

*** Tasks ***
Process PDF invoices with Amazon Textract
    [Setup]    Initialize Amazon Clients
    @{job_ids}=    Create List
    ${filenames}=    Get File Keys From Amazon S3 Bucket
    FOR    ${filename}    IN    @{filenames}
        ${job_id}=    Process PDF with Amazon Textract    ${filename}
        Append To List    ${job_ids}    ${job_id}
    END
    ${invoices}=    Wait For PDF Processing Results    ${job_ids}
    Save Invoices To Excel    ${invoices}
    [Teardown]    Delete Files From Amazon S3 Bucket

*** Tasks ***
Create Invoices
    [Setup]    Initialize Amazon Clients
    Create Invoices

*** Tasks ***
Delete Files From Amazon S3 Bucket
    [Setup]    Initialize Amazon Clients
    Delete Files From Amazon S3 Bucket
