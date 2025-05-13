# Satis S3 Action
Builds a Composer Satis repository and syncs the output to an S3 bucket

## Usage
```yaml
name: publish

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  publish:
    runs-on: ubuntu-latest
    name: Satis S3
    steps:
      - uses: actions/checkout@v3

      - name: Run satis-s3-action
        uses: scottcharlesworth/satis-s3-action@v1
        with:
          s3_bucket: 'satis-s3-action-example'
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: eu-west-2
          AUTH_GITHUB: ${{ secrets.AUTH_GITHUB }}
```

This config assumes you have configured IAM credentials that have access to the target as
[GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets).

### Example Satis config file

You will need a Satis configuration file in your repository. The default name and location for this file is `satis.json`
and it is placed in the repository root. However, you can specify its location using the `config_file` input should you 
wish to store it elsewhere.

More information on the format of the file can be found in the
[Composer documentation](https://getcomposer.org/doc/articles/handling-private-packages.md).

Do not put an `output-dir` key in your configuration file, as it will be ignored by the action at runtime.

```json lines
{
  "name": "My Repository",
  "homepage": "http://packages.example.org",
  "repositories": [
    { "type": "vcs", "url": "https://github.com/mycompany/privaterepo" },
    { "type": "vcs", "url": "http://svn.example.org/private/repo" },
    { "type": "vcs", "url": "https://github.com/mycompany/privaterepo2" }
  ],
  "require-all": true
}
```

### Example IAM Policy

This is an example IAM policy with the minimum required permissions.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::satis-s3-action-example",
                "arn:aws:s3:::satis-s3-action-example/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "*"
        }
    ]
}
```

## Inputs

| Name        | Required | Default      | Description                                                          |
|-------------|----------|--------------|----------------------------------------------------------------------|
| s3_bucket   | **Yes**  | N/A          | The AWS S3 bucket to write the output to                             |
| s3_path     | No       | ''           | The path inside the AWS S3 bucket to write the output to             |
| purge       | No       | 'true'       | Run the purge command after building to remove unreferenced archives |
| config_file | No       | 'satis.json' | The location of the satis config file in the repository              |
| debug       | No       | 'false'      | Output debug information to console                                  |

## Environment Variables

| Name                  | Required | Description                                                                                                                                                                                      |
|-----------------------|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AWS_ACCESS_KEY_ID     | **Yes**  | The AWS access key associated with an IAM user or role                                                                                                                                           |
| AWS_SECRET_ACCESS_KEY | **Yes**  | The AWS secret key associated with the access key                                                                                                                                                |
| AWS_REGION            | **Yes**  | The AWS Region to send requests to                                                                                                                                                               |
| AUTH_GITHUB           | No       | Required for accessing private GitHub repositories and to lift rate limiting. [More info here](https://getcomposer.org/doc/articles/authentication-for-private-packages.md#github-oauth)         |
| AUTH_BITBUCKET_KEY    | No       | The Bitbucket consumer key. Required for accessing private BitBucket repositories. [More info here](https://getcomposer.org/doc/articles/authentication-for-private-packages.md#bitbucket-oauth) |
| AUTH_BITBUCKET_SECRET | No       | The Bitbucket consumer secret.                                                                                                                                                                   |

You are also able to set any environment variables from the
[AWS CLI v2 documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html).

## Credits

This GitHub Action was inspired by the following tutorials and projects:
- [ministryofjustice/satis-s3](https://github.com/ministryofjustice/satis-s3/) (based on [iainmckay/satis-s3](https://github.com/iainmckay/satis-s3))
- [Setting up and securing a private Composer repository](https://alexvanderbist.com/2021/setting-up-and-securing-a-private-composer-repository/) by Alex Vanderbist

## License

[MIT](https://github.com/scottcharlesworth/satis-s3-action/blob/main/LICENSE.txt)

## Author

[Scott Charlesworth](https://scottcharlesworth.dev)