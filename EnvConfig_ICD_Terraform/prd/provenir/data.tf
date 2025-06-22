data "google_dns_managed_zone" "this" {
 name=var.project_id
 project=var.project_id
 }