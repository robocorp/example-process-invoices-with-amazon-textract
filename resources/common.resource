*** Settings ***
Library           Collections
Library           RPA.Cloud.AWS
Library           RPA.Excel.Files
Library           RPA.Robocorp.Vault
Library           InvoiceGenerator
Library           InvoiceModeler

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
