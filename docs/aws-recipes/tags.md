---
sidebar_position: 5
---

# Tags

[Terraform null label](https://github.com/cloudposse/terraform-null-label)

```
module "myservice_label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=cf38625a5dde227db04c9cfedc1327d610229fec"
  namespace   = "MT"
  environment = terraform.workspace
  name        = "myservice"

  tags = {
    Owner           = "service-name@madetech.com"
    GovtServiceName = "My Service"
  }
}
```
