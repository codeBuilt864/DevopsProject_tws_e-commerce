terraform {
  backend "s3" {
    bucket = "terraform-s3dawe"
    key = "backend-locking"
    region = "eu-west-1"
    use_lockfile = true
  }
}