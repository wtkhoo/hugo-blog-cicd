# Building a static blog site on AWS

## Overview

This Terraform code deploys a CI/CD pipeline for hosting a static blog site using Hugo on AWS. The static blog site is deployed and hosted in a private S3 bucket. A CloudFront distribution is set up with the S3 bucket as an origin. The CloudFront distribution caches the content from S3 bucket and delivers the pages to the blog readers. 

For more details, read my [blog post](https://blog.wkhoo.com/posts/hugo-blog-cicd-part1/).

![My blog site architecture](https://blog.wkhoo.com/images/hugo-blog-architecture_hu7acd83daea2e855bf8f43ae3c5d8625c_111154_800x640_fit_q50_box.jpeg)

## Requirements

- [Terraform](https://www.terraform.io/downloads) (>= 1.5.0)
- AWS account [configured with proper credentials to run Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)
- A public domain name registration

## Walkthrough

1) Clone this repository to your local machine.

   ```shell
   git clone https://github.com/wtkhoo/hugo-blog-cicd.git
   ```

2) Change your directory to the `hugo-blog-cicd` folder.

   ```shell
   cd hugo-blog-cicd
   ```

3) Run the terraform [init](https://www.terraform.io/cli/commands/init) command to initialize the Terraform deployment and set up the providers.

   ```shell
   terraform init
   ```

4) To customize your deployment, create a `terraform.tfvars` file and specify your values.

    ```
   domain_name                = "blog.example.com"
   subscriber_email_addresses = ["email@example.com"]
   use_default_domain         = false
   hosted_zone                = "example.com"
   acm_certificate_domain     = "blog.example.com"
    ```

5) Next step is to run a terraform [plan](https://www.terraform.io/cli/commands/plan) command to preview what will be created.

   ```shell
   terraform plan
   ```

6) If your values are valid, you're ready to go. Run the terraform [apply](https://www.terraform.io/cli/commands/apply) command to provision the resources.

   ```shell
   terraform apply
   ```

7) When you're done with the demo, run the terraform [destroy](https://www.terraform.io/cli/commands/destroy) command to delete all resources that were created in your AWS environment.

   ```shell
   terraform destroy
   ```

## Questions and Feedback

If you have any questions or feedback, please don't hesitate to [create an issue](https://github.com/wtkhoo/hugo-blog-cicd/issues/new).