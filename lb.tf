resource "google_compute_global_forwarding_rule" "global_forwarding_rule" {
    
    name = "${var.prefix}-global-forwarding-rule"
    project = var.project_id
    port_range = "443"
    target = google_compute_target_https_proxy.target_https_proxy.self_link
}

resource "google_compute_ssl_certificate" "lb_certificate" {
    project     = var.project_id
    name_prefix = "${var.prefix}-certificate-"
   
    private_key = chomp(file(".lb-key.pem"))
    certificate = chomp(file(".lb-cert.pem"))

    lifecycle {
        create_before_destroy = true
    }
}

resource "google_compute_target_https_proxy" "target_https_proxy" {

    name             = "${var.prefix}-proxy"
    project          = var.project_id
    url_map          = google_compute_url_map.url_map.self_link
    ssl_certificates = concat(google_compute_ssl_certificate.lb_certificate.*.self_link)
}

locals {
    host_rules = {
        vault = ["vault.hcpoc.bitrock.it"]
        consul = ["consul.hcpoc.bitrock.it"]
        nomad = ["nomad.hcpoc.bitrock.it"]
        http-ingress = [
            "jaeger.hcpoc.bitrock.it",
            "grafana-internal.hcpoc.bitrock.it",
            "elastic-internal.hcpoc.bitrock.it"
        ]
    }
    path_matchers = {
        vault = google_compute_backend_service.backend_service_vault.self_link
        consul = google_compute_backend_service.backend_service_consul.self_link
        nomad = google_compute_backend_service.backend_service_nomad.self_link
        http-ingress = google_compute_backend_service.backend_service_workload.self_link
    }
}

resource "google_compute_url_map" "url_map" {

    name = "${var.prefix}-load-balancer"
    project = var.project_id
    default_service = google_compute_backend_service.backend_service_vault.self_link
    
    dynamic "host_rule" {
        for_each = local.host_rules
        content {
            hosts        = host_rule.value
            path_matcher = host_rule.key
        }
    }
    dynamic "path_matcher" {
        for_each = local.path_matchers
        content {
            name            = path_matcher.key
            default_service = path_matcher.value
        }
    }
}

resource "google_compute_backend_service" "backend_service_vault" {
    
    name = "${var.prefix}-backend-service-vault"
    project = var.project_id
    port_name = "vault"
    protocol = "HTTP"

    health_checks = [ 
        google_compute_health_check.healthcheck_vault.self_link
    ]
    
    dynamic "backend" {
        for_each = google_compute_instance_group.hcpoc_cluster_nodes

        content {
            group = google_compute_instance_group.hcpoc_cluster_nodes[backend.key].self_link
            balancing_mode = "RATE"
            max_rate_per_instance = 100
        }
    }
    
}

resource "google_compute_backend_service" "backend_service_consul" {
    
    name = "${var.prefix}-backend-service-consul"
    project = var.project_id
    port_name = "consul"
    protocol = "HTTP"

    health_checks = [ 
        google_compute_health_check.healthcheck_consul.self_link
    ]

    dynamic "backend" {
        for_each = google_compute_instance_group.hcpoc_cluster_nodes

        content {
            group = google_compute_instance_group.hcpoc_cluster_nodes[backend.key].self_link
            balancing_mode = "RATE"
            max_rate_per_instance = 100
        }
    }
    
}

resource "google_compute_backend_service" "backend_service_nomad" {
    
    name = "${var.prefix}-backend-service-nomad"
    project = var.project_id
    port_name = "nomad"
    protocol = "HTTP"

    health_checks = [ 
        google_compute_health_check.healthcheck_nomad.self_link
    ]

    dynamic "backend" {
        for_each = google_compute_instance_group.hcpoc_cluster_nodes

        content {
            group = google_compute_instance_group.hcpoc_cluster_nodes[backend.key].self_link
            balancing_mode = "RATE"
            max_rate_per_instance = 100
        }
    }
    
}

resource "google_compute_backend_service" "backend_service_workload" {
    
    name = "${var.prefix}-backend-service-workload"
    project = var.project_id
    port_name = "http-ingress"
    protocol = "HTTP"

    health_checks = [ 
        google_compute_health_check.healthcheck_tcp_ingress.self_link
    ]

    backend {
        group = google_compute_region_instance_group_manager.default-workers["def-wrkr-grp"].instance_group
        balancing_mode = "RATE"
        max_rate_per_instance = 100
    }
    
}

resource "google_compute_health_check" "healthcheck_vault" {

    name = "${var.prefix}-healthcheck-vault"
    timeout_sec = 2
    check_interval_sec = 30

    http_health_check {
        port_name          = "vault"
        port_specification = "USE_NAMED_PORT"
        request_path       = "/v1/sys/leader"
    }
}

resource "google_compute_health_check" "healthcheck_consul" {

    name = "${var.prefix}-healthcheck-consul"
    timeout_sec = 2
    check_interval_sec = 30

    http_health_check {
        port_name          = "consul"
        port_specification = "USE_NAMED_PORT"
        request_path       = "/v1/status/leader"
    }
}

resource "google_compute_health_check" "healthcheck_nomad" {

    name = "${var.prefix}-healthcheck-nomad"
    timeout_sec = 2
    check_interval_sec = 30

    http_health_check {
        port_name          = "consul"
        port_specification = "USE_NAMED_PORT"
        request_path       = "/v1/status/leader"
    }
}

resource "google_compute_health_check" "healthcheck_tcp_ingress" {

    name = "${var.prefix}-healthcheck-tcp-ingress"
    timeout_sec = 2
    check_interval_sec = 30

    tcp_health_check {
        port_name          = "http-ingress"
        port_specification = "USE_NAMED_PORT"
        
    }
}
