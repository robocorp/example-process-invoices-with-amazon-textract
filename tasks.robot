*** Settings ***
Documentation     Execution report
Resource          invoices.resource

*** Tasks ***
Scan PDF Invoices with AWS Textract
    [Setup]    AWS Initialization
    @{jobs}=    Create List
    ${pdf_files}=    List Files In Directory    resources${/}invoices    *.pdf
    FOR    ${pdf_file}    IN    @{pdf_files}
        ${filename}=    Set Variable    resources${/}invoices${/}${pdf_file}
        ${basename}=    Evaluate    os.path.basename("${filename}")
        Copy File    ${filename}    ${OUTPUT_DIR}
        ${job_id}=    Scan PDF With AWS Textract    ${basename}
        Append To List    ${jobs}    ${job_id}
    END
    ${pdf_scans}=    Wait For PDF Scans To Complete    ${jobs}
    Invoices To Excel    ${pdf_scans}

*** Tasks ***
Scan Image Invoices with AWS Textract
    [Setup]    AWS Initialization
    @{invoices}=    Create List
    ${png_files}=    List Files In Directory    resources${/}invoices    *.png
    FOR    ${png_file}    IN    @{png_files}
        ${filename}=    Set Variable    resources${/}invoices${/}${png_file}
        ${basename}=    Evaluate    os.path.basename("${filename}")
        Copy File    ${filename}    ${OUTPUT_DIR}
        ${invoice}=    Scan Image With AWS Textract    ${filename}
        IF    ${invoice}
        Append To List    ${invoices}    ${invoice}
        END
    END
    Invoices To Excel    ${invoices}

*** Tasks ***
Create Invoices
    [Setup]    AWS Initialization
    Create Invoices
