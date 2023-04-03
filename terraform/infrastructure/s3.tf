resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket
}

resource "aws_s3_bucket_website_configuration" "website_conf" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}


resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.website_bucket.id}/*"
      }
    ]
  })
}


resource "aws_s3_object" "website_upload" {
  for_each     = fileset("../../static-website/", "**")
  bucket       = aws_s3_bucket.website_bucket.id
  key          = each.value
  source       = "../../static-website/${each.value}"
  etag         = filemd5("../../static-website/${each.value}")
  content_type = "text/html"
}
