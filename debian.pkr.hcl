packer {
  required_plugins {
    incus = {
      version = ">= 1.0.0"
      source  = "github.com/bketelsen/incus"
    }
  }
}

source "incus" "debian" {
  image        = "images:debian/12/cloud"
  output_image = "debian-runner"
  reuse        = true
}

locals {
  tmp_path     = "/tmp"
  scripts_path = "scripts"

  toolset_path = "${local.scripts_path}/toolset"
  toolset_file = "toolset.json"

  runner_home = "/home/runner/actions-runner"
  toolcache_path = "/opt/hostedtoolcache"
}

build {
  name = "debian-runner"
  sources = ["source.incus.debian"]

  provisioner "shell" {
    environment_vars = [
      "RUNNER_HOME=${local.runner_home}",
      "AGENT_TOOLSDIRECTORY=${local.toolcache_path}",
    ]
    scripts = [
      "${local.scripts_path}/install-tools.sh",
      "${local.scripts_path}/install-docker.sh",
      "${local.scripts_path}/install-runner.sh",
      "${local.scripts_path}/install-powershell.sh"
    ]
  }

  provisioner "file" {
    source      = "${local.toolset_path}/${local.toolset_file}"
    destination = "${local.tmp_path}"
  }

  provisioner "shell" {
    environment_vars = [
      "TOOLSET_CONF=${local.tmp_path}/${local.toolset_file}",
      "AGENT_TOOLSDIRECTORY=${local.toolcache_path}",
    ]
    scripts = [
      "${local.toolset_path}/Install-Toolset.ps1"
    ]
  }

  provisioner "shell" {
    expect_disconnect = true
    inline = ["echo 'Reboot Container'", "sudo reboot"]
  }

  provisioner "shell" {
    pause_before = "1m0s"
    scripts = [
      "${local.scripts_path}/cleanup.sh"
    ]
    start_retry_timeout = "10m"
  }
}