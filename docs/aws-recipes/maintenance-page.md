---
sidebar_position: 2
---

# Maintenance Page

A GitHub Actions/Terraform deployable maintenace page with gov.uk branding and a configurable message.

![Maintenance Page](screenshots/maintenance-page.png)

## The Premise

We will deploy a stand alone static webpage into AWS S3 and served via CloudFront with HTTPS.

The Maintenance Page is enabled by updating the A record for the domain in Route53.

You can create this as a standalone GitHub project for your service (e.g 'myservice maintenace page') or drop it into an existing project in a sub directory.

## Configure a certificate

You will need to manually create a certificate and reference the arn created from the terraform.

You can use AWS to [request a certificate](https://eu-west-2.console.aws.amazon.com/acm/home?region=eu-west-2#/privatewizard/) for your domain. e.g www.myservice.com. If your service is already running on AWS you might already have this available to use.

Make a note of the ARN that is assigned to your certificate as you will need to add this to your Terraform [code](https://github.com/struds/ops-cookbook/blob/main/example-code/maintenance-page/cloudfront.tf) - of course you could extend the code to make it configurable or even use Terraform to provision a certificate.

## Build and Run

Instructions on how to setup and deploy can be found in this [README](https://github.com/struds/ops-cookbook/blob/main/example-code/maintenance-page/README.md).

A fully working project can be found [here](https://github.com/struds/ops-cookbook/blob/main/example-code/maintenance-page).

## Deploying from GitHub

Make the deployment easier by adding a GitHub Workflow which builds and deploys the site while setting a message for your users.

[GitHub Actions Workflow](https://github.com/struds/ops-cookbook/blob/main/example-code/maintenance-page/workflows/maintenance-page.yml)



