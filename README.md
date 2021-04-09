# Process PDF invoices with Amazon Textract

<img src="images/pdf-textract-excel.png" style="margin-bottom:20px">

This robot processes randomly generated [PDF](https://en.wikipedia.org/wiki/PDF) invoices with [Amazon Textract](https://aws.amazon.com/textract/) and saves the extracted invoice data in an [Excel](https://en.wikipedia.org/wiki/Microsoft_Excel) file.

## Tasks

The robot provides three tasks: `Create Invoices`, `Process PDF invoices with Amazon Textract`, and `Delete Files From Amazon S3 Bucket`.

### Create Invoices

Generates random PDF invoices and uploads them to [Amazon S3](https://aws.amazon.com/s3/) bucket. Saves the generated PDF invoices to the output directory for debugging purposes.

### Process PDF invoices with Amazon Textract

Reads the invoices from the Amazon S3 bucket and processes them with Amazon Textract. Saves the extracted invoice data in an Excel file. Finally, deletes the PDF invoices from the Amazon S3 bucket.

### Delete Files From Amazon S3 Bucket

A utility task for deleting the PDF invoices from the Amazon S3 bucket. Can be executed separately from other tasks when you want to empty the Amazon S3 bucket. Called internally by the `Process PDF invoices with Amazon Textract` task in the teardown phase.

## Prerequisites

### Amazon API key and key ID with access to Amazon S3 and Amazon Textract

The robot requires access to Amazon S3 and Amazon Textract.

### Robocorp Vault

The Amazon API key, key ID, and the AWS region are stored in a vault. Set up [Robocorp Vault](https://robocorp.com/docs/development-guide/variables-and-secrets/vault) either locally or in [Robocorp Cloud](https://robocorp.com/docs/robocorp-cloud/overview).

For a local run, use the following `vault.json` and `env.json`:

`/Users/username/vault.json`:

```json
{
  "aws": {
    "AWS_KEY": "aws-key",
    "AWS_KEY_ID": "aws-key-id",
    "AWS_REGION": "us-east-1"
  }
}
```

`devdata/env.json`:

```json
{
  "RPA_SECRET_MANAGER": "RPA.Robocloud.Secrets.FileSecrets",
  "RPA_SECRET_FILE": "/Users/username/vault.json"
}
```

For Robocorp Cloud run, create a new vault entry in Robocorp Cloud. Enter `aws` as the name. Provide values for the `AWS_KEY`, `AWS_KEY_ID`, and `AWS_REGION` keys.

## Running

- Run the `Create Invoices` task to create the PDF invoices.
- Run the `Process PDF invoices with Amazon Textract` task to process the PDF invoices and to generate the Excel file with the data extracted from the invoices.
- Optional: Run the `Delete Files From Amazon S3 Bucket` task if you want to delete the PDF invoices from the Amazon S3 bucket (the `Process PDF invoices with Amazon Textract` task does this automatically in the teardown phase).

When running in Robocorp Cloud, add the `Create Invoices` and `Process PDF invoices with Amazon Textract` as steps.
