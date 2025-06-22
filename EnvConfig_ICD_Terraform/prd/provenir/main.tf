resource "google_compute_instance_temple" "tp_provenir" {
	name = var.tp_name
	machine_type = var.machine_type
	can_ip_forward = false
	project = var.project_id
	
 disk {
 source_image = "projects/$var.image_project_id}/global/images/family/${var.image_family}"
 disk_size_gb = var.root_vol_size
 disk_encryption_key {
  kms_key_self_link = "project/${var.cmek_project_id}/locations/${var.region}/keyRings/${var.cmek_ring_gce}/cryptokeys/${var.cmek_name_gce}"
   }
  }
  network_interface {
   subnetwork = local.subnetwork1.subnetwork
   network_ip = local.subnetwork1.network_ip
   }
   
   service_account {
	email = format("%s@%s.iam.gserviceaccount.com", var.service_account, var.project_id}
	scopes = [
	"cloud-platform"
	]
	}
	
 tags = var.tags
 labels = var.labels
 matadeta = var.metadatas
 }
 
resource "google_compute_health_check" "hc_provenir" {
 project = var.project_id
 name = var.hc_name
 timeout_sec = 3
 check_interval_sec = 10
 healthy_threshold = 4
 unhealthy_threshold = 5
 
 tcp_health_check {
  port = "8161"
  }
 }
 
resource "google_compute_region_instance_group_manager" "mig_provenir" {
project = var.project_id
name = var.mig_name
base_instance_name = var.mig_vm_name
region = var.region
version {
 name = var.tp_name
 instance_template = google_compute_instance_template.tp_provenir.id
 }
 
 auto_healing_policies {
  health_check = google_compute_health_check.hc_provenir.id
  initial_delay_sec = 90
  }
 }
 
 resource "google_compute_region_autoscaler" "as_provenir" {
 provider = google_beta
 project = var.project_id
 name = format("%s-autoscaler" , var.mig_name)
 region = var.region
 target = google_compute_region_instance_group_manager.mig_provenir.id
 
 
 autoscaling_policy {
 max_replicas = 5
 min_replicas = 5
 cooldown_period = 200
 
 metric {
   name = "pubsub.googleapis.com/subscription/num_undelivered_messages"
   filter = "resource.type = pubsub_subscription AND resource.labels.subscription_id = \"sub-transaction-prd\""
   single_instance_assignment = 2
   }
   }
   }
   
  resource "google_compute_region_backend_service" "be_provenir" {
    project = var.project_id
	name = var.lb_be_name
	region = var.region
	health_checks = [google_compute_health_check.hc_provenir.id]
	backend {
	 group = google_compute_region_instance_group_manager.mig_provenir.instance.group
	 }
	}
	
   
  resource "google_compute_forwarding_rule" "fe_provenir" {
   project = var.project_id
   name = var.lb_fe_name
   region = var.region
   
   ip_address = var.lb_fe_ip
   load_balancing_scheme = "INTERNAL"
   ip_protocol = "TCP"
   backend_service = google_compute_region_backend_service.be_provenir.id
   all_ports = true
   subnetwork = local.subnetwork1.subnetwork
}

resource "google_dns_record_set" "fqdn_provenir" {
 name = "gce-provenir-icd-${lower(var.env)}-lb.${data.google_dns_managed_zone.this.dns_name}"
 project = var.project_id
 type = "A"
 ttl = 300

managed_zone = data.google_dns_managed_zone.this.name

rrdatas = [google_compute_forwarding_rule.fe_provenir.ip_address]
} 
 
