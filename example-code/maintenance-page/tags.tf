module "myservice_label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=cf38625a5dde227db04c9cfedc1327d610229fec"
  namespace   = "mca"
  environment = terraform.workspace
  name        = "myservice-maintenance-page"

  tags = {
    Owner                  = "myservice@madetech.com"
    GovtServiceName        = "My Service"
    ApplicationServiceName = "My Service Maintenance Page"
  }
}
