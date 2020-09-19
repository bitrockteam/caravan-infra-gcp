# Load balancer with unmanaged instance group | lb-unmanaged.tf
# used to forward traffic to the correct load balancer for HTTP load balancing
resource "google_compute_global_forwarding_rule" "global_forwarding_rule" {
    
    name = "${var.prefix}-global-forwarding-rule"
    project = var.project_id
    port_range = "80"
    target = google_compute_target_http_proxy.target_http_proxy.self_link
}

# used by one or more global forwarding rule to route incoming HTTP requests to a URL map
resource "google_compute_target_http_proxy" "target_http_proxy" {

    name = "${var.prefix}-proxy"
    project = var.project_id
    url_map = google_compute_url_map.url_map.self_link
}

# used to route requests to a backend service based on rules that you define for the host and path of an incoming URL
resource "google_compute_url_map" "url_map" {

    name = "${var.prefix}-load-balancer"
    project = var.project_id
    default_service = google_compute_backend_service.backend_service_vault.self_link

    host_rule {
        hosts        = ["gcp.hcpoc.bitrock.it", "vault.hcpoc.bitrock.it"]
        path_matcher = "vault"
    }
    host_rule {
        hosts        = ["consul.hcpoc.bitrock.it"]
        path_matcher = "consul"
    }
    host_rule {
        hosts        = ["nomad.hcpoc.bitrock.it"]
        path_matcher = "nomad"
    }
    host_rule {
        hosts        = ["jaeger.hcpoc.bitrock.it"]
        path_matcher = "http-ingress"
    }

    path_matcher {
        name            = "vault"
        default_service = google_compute_backend_service.backend_service_vault.id
    }
    path_matcher {
        name            = "consul"
        default_service = google_compute_backend_service.backend_service_consul.id
    }
    path_matcher {
        name            = "nomad"
        default_service = google_compute_backend_service.backend_service_nomad.id
    }
    path_matcher {
        name            = "http-ingress"
        default_service = google_compute_backend_service.backend_service_workload.id
    }
}

# defines a group of virtual machines that will serve traffic for load balancing
resource "google_compute_backend_service" "backend_service_vault" {
    
    name = "${var.prefix}-backend-service-vault"
    project = var.project_id
    port_name = "vault"
    protocol = "HTTP"

    health_checks = [ 
        google_compute_health_check.healthcheck_vault.self_link
    ]

    backend {
        group = google_compute_instance_group.hcpoc_cluster_nodes[0].self_link
        balancing_mode = "RATE"
        max_rate_per_instance = 100
    }
    backend {
        group = google_compute_instance_group.hcpoc_cluster_nodes[1].self_link
        balancing_mode = "RATE"
        max_rate_per_instance = 100
    }
    backend {
        group = google_compute_instance_group.hcpoc_cluster_nodes[2].self_link
        balancing_mode = "RATE"
        max_rate_per_instance = 100
    }
    
}

# defines a group of virtual machines that will serve traffic for load balancing
resource "google_compute_backend_service" "backend_service_consul" {
    
    name = "${var.prefix}-backend-service-consul"
    project = var.project_id
    port_name = "consul"
    protocol = "HTTP"

    health_checks = [ 
        google_compute_health_check.healthcheck_consul.self_link
    ]

    backend {
        group = google_compute_instance_group.hcpoc_cluster_nodes[0].self_link
        balancing_mode = "RATE"
        max_rate_per_instance = 100
    }
    backend {
        group = google_compute_instance_group.hcpoc_cluster_nodes[1].self_link
        balancing_mode = "RATE"
        max_rate_per_instance = 100
    }
    backend {
        group = google_compute_instance_group.hcpoc_cluster_nodes[2].self_link
        balancing_mode = "RATE"
        max_rate_per_instance = 100
    }
    
}

# defines a group of virtual machines that will serve traffic for load balancing
resource "google_compute_backend_service" "backend_service_nomad" {
    
    name = "${var.prefix}-backend-service-nomad"
    project = var.project_id
    port_name = "nomad"
    protocol = "HTTP"

    health_checks = [ 
        google_compute_health_check.healthcheck_nomad.self_link
    ]

    backend {
        group = google_compute_instance_group.hcpoc_cluster_nodes[0].self_link
        balancing_mode = "RATE"
        max_rate_per_instance = 100
    }
    backend {
        group = google_compute_instance_group.hcpoc_cluster_nodes[1].self_link
        balancing_mode = "RATE"
        max_rate_per_instance = 100
    }
    backend {
        group = google_compute_instance_group.hcpoc_cluster_nodes[2].self_link
        balancing_mode = "RATE"
        max_rate_per_instance = 100
    }
    
}

# defines a group of virtual machines that will serve traffic for load balancing
resource "google_compute_backend_service" "backend_service_workload" {
    # count = length(var.workers_groups)
    
    name = "${var.prefix}-backend-service-workload"
    project = var.project_id
    port_name = "http-ingress"
    protocol = "HTTP"

    health_checks = [ 
        google_compute_health_check.healthcheck_http_ingress.self_link
    ]

    backend {
        group = google_compute_region_instance_group_manager.default-workers["def-wrkr-grp"].instance_group
        balancing_mode = "RATE"
        max_rate_per_instance = 100
    }
    
}

# determine whether instances are responsive and able to do work
resource "google_compute_health_check" "healthcheck_vault" {

    name = "${var.prefix}-healthcheck-vault"
    timeout_sec = 2
    check_interval_sec = 5

    http_health_check {
        port_name          = "vault"
        port_specification = "USE_NAMED_PORT"
        request_path       = "/v1/sys/leader"
    }
}

# determine whether instances are responsive and able to do work
resource "google_compute_health_check" "healthcheck_consul" {

    name = "${var.prefix}-healthcheck-consul"
    timeout_sec = 2
    check_interval_sec = 5

    http_health_check {
        port_name          = "consul"
        port_specification = "USE_NAMED_PORT"
        request_path       = "/v1/status/leader"
    }
}

# determine whether instances are responsive and able to do work
resource "google_compute_health_check" "healthcheck_nomad" {

    name = "${var.prefix}-healthcheck-nomad"
    timeout_sec = 2
    check_interval_sec = 5

    http_health_check {
        port_name          = "consul"
        port_specification = "USE_NAMED_PORT"
        request_path       = "/v1/status/leader"
    }
}

# determine whether instances are responsive and able to do work
resource "google_compute_health_check" "healthcheck_http_ingress" {

    name = "${var.prefix}-healthcheck-http-ingress"
    timeout_sec = 2
    check_interval_sec = 5

    http_health_check {
        port_name          = "http-ingress"
        port_specification = "USE_NAMED_PORT"
        # request_path       = "/v1/status/leader"
    }
}

# show external ip address of load balancer
output "load-balancer-ip-address" {
    value = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
}