terraform {
	backend "gcs" {
	bucket = "abcd-11929073-provicd-prod"
	prefix = "Terraform/prd"
	}
}