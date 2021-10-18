resource "aws_cloudfront_distribution" "s3_distribution" {
  tags = module.myservice_label.tags
  origin {
    domain_name = aws_s3_bucket.maintenance-page.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.maintenance-page.bucket
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = [var.cloudfront_domain_name]

  custom_error_response {
    error_code         = "404"
    response_code      = "200"
    response_page_path = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.maintenance-page.bucket

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  price_class = "PriceClass_100" // Least expensive option, caches in North America and Europe

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:232705206979:certificate/81e60b16-3fd4-4027-8288-aa41ace2dafa"
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "Necessary to restrict S3 bucket access to only the Cloudfront distribution."
}
