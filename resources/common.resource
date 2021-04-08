*** Settings ***
Library           Collections
Library           OperatingSystem
Library           String
Library           RPA.Cloud.AWS
Library           RPA.Excel.Files
Library           RPA.PDF
Library           RPA.Robocloud.Items
Library           RPA.Robocloud.Secrets
Library           RPA.Tables
Library           DemoLibrary
Library           InvoiceGenerator
Library           InvoiceModeler

*** Variables ***
${INVOICES_DIR}=    resources${/}invoices

*** Keywords ***
Initialize Amazon Clients
    ${secret}=    Get Secret    aws
    Init Textract Client
    ...    ${secret}[AWS_KEY_ID]
    ...    ${secret}[AWS_KEY]
    ...    ${secret}[AWS_REGION]
    Init S3 Client
    ...    ${secret}[AWS_KEY_ID]
    ...    ${secret}[AWS_KEY]
    ...    ${secret}[AWS_REGION]

*** Keywords ***
Get Basename
    [Arguments]    ${filename}
    ${basename}=    Evaluate    os.path.basename("${filename}")
    [Return]    ${basename}
