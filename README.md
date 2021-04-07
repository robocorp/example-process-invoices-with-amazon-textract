# Analyze PDF invoice using Amazon Textract

This robot uses Amazon Textract for analyzing an example PDF invoice. The analysis results are stored as JSON files for easy manual inspection.

## Requirements

### AWS key and key ID

`vault.json`:

```json
{
  "aws": {
    "AWS_KEY_ID": "key-id",
    "AWS_KEY": "key"
  }
}
```

### Amazon S3 and Amazon Textract API access

The robot writes files to an [Amazon S3](https://aws.amazon.com/s3/) bucket, and communicates with the [Amazon Textract](https://aws.amazon.com/textract/) API.
