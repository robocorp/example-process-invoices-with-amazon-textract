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
Library           InvoiceModeler
Library           InvoiceGenerator

*** Keywords ***
AWS Initialization
    ${secret}=    Get Secret    aws
    Init Textract Client
    ...  ${secret}[AWS_KEY_ID]  
    ...  ${secret}[AWS_KEY]  
    ...  ${secret}[AWS_REGION]
    Init S3 Client  
    ...  ${secret}[AWS_KEY_ID]  
    ...  ${secret}[AWS_KEY]  
    ...  ${secret}[AWS_REGION]
