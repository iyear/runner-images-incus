packer {
  required_plugins {
    incus = {
      version = ">= 1.0.0"
      source  = "github.com/bketelsen/incus"
    }
  }
}

source "incus" "debian" {
  image        = "images:debian/12"
  output_image = "debian-runner"
  skip_publish = true
  reuse        = true
}

build {
  name = "debian-runner"
  sources = ["source.incus.debian"]

  provisioner "shell" {
    scripts = [
      "scripts/install-tools.sh",
      "scripts/install-docker.sh",
      # "scripts/install-runner.sh",
    ]
  }

  # provisioner "shell" {
  #   expect_disconnect = true
  #   inline = ["echo 'Reboot Container'", "sudo reboot"]
  # }
  #
  # provisioner "shell" {
  #   pause_before = "2m0s"
  #   scripts = [
  #     "scripts/cleanup.sh"
  #   ]
  #   start_retry_timeout = "10m"
  # }
}