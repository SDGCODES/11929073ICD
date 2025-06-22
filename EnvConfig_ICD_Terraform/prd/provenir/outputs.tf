output "lb_forward_ip_address" {
 value = google_compute_forwarding_rule.fe_provenir.ip_address
 }
 
 output "fqdn" {
	value = google_dns_record_set.fqdn_provenir.name
	}