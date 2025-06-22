provider "google" {
	version = "~> 3.90"
	project = var.project_id
	region = var.region
}
 
provider "google-beta"  {
	version = "~> 3.90"
	project = var.project_id
	region = var.region
}