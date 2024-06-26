resource "google_compute_instance" "desktop-server" {
  name         = var.desktop_server_name 
  machine_type = var.get_desktop_machine_type	
  zone         = var.get_desktop_zone	

  boot_disk {
    initialize_params {
      image = var.get_desktop_image
      size  = var.get_desktop_boot_size
      labels = {
        my_label = "desktop-server"
      }
    }
  }

  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network    = var.network	
    subnetwork = var.subnetwork

    access_config {
      // Ephemeral IP
    }
  }

  labels = {
    desktop_server = "true"
  }

  service_account {
    email  = var.svc_email	
    scopes = ["cloud-platform"]
  }

  tags = [var.get_desktop_network_tag]		

  metadata = {
    ssh-keys = "root:${file("/var/lib/jenkins/.ssh/id_rsa.pub")}"
  }
}
