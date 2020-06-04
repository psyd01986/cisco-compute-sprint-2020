resource "intersight_adapter_config_policy" "sprint-adapter-config-policy" {
  name        = "sprint-adapter-config-policy"
  description = "Adapter Configuration Policy for Compute Sprint Demo"
  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }
  settings {
    slot_id = "MLOM"
    eth_settings {
      lldp_enabled = true
    }
    fc_settings {
      fip_enabled = true
    }
  }
  profiles {
    moid        = intersight_server_profile.compute-sprint-srv-1.id
    object_type = "server.Profile"
  }
}

resource "intersight_vnic_eth_adapter_policy" "sprint-ethernet-adapter-policy" {
  name = "sprint-ethernet-adapter-policy"
  description = "Ethernet Adapter Policy for Compute Sprint Demo"
  rss_settings = true
  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }
  vxlan_settings {
    enabled = false
  }

  nvgre_settings {
    enabled = false
  }

  arfs_settings {
    enabled = false
  }

  interrupt_settings {
    coalescing_time = 125
    coalescing_type = "MIN"
    count           = 32
    mode            = "MSI"
  }
  completion_queue_settings {
    count     = 16
    ring_size = 1
  }
  rx_queue_settings {
    count     = 8
    ring_size = 4096
  }
  tx_queue_settings {
    count     = 8
    ring_size = 4096
  }
  tcp_offload_settings {
    large_receive = true
    large_send    = true
    rx_checksum   = true
    tx_checksum   = true
  }

}

resource "intersight_vnic_eth_network_policy" "sprint-management-network" {
  name = "sprint-management-network"
  description = "Management Network for Compute Sprint Demo"
  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }
  vlan_settings {
    default_vlan = var.management_vlan
    mode         = "TRUNK"
  }
}

resource "intersight_vnic_eth_network_policy" "sprint-production-network" {
  name = "sprint-client-network"
  description = "Client Network for Compute Sprint Demo"
  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }
  vlan_settings {
    default_vlan = var.production_vlan
    mode         = "TRUNK"
  }
}

resource "intersight_vnic_eth_qos_policy" "sprint-ethernet-qos-policy" {
  name           = "sprint-ethernet-qos-policy"
  description = "Ethernet quality of service for Compute Sprint Demo"
  mtu            = 9000
  rate_limit     = 0
  cos            = 0
  trust_host_cos = false
  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }
}

resource "intersight_vnic_lan_connectivity_policy" "sprint-lan-connectivity-policy" {
  name = "sprint-lan-connectivity-policy"
  description = "LAN Connectivity Policy for Compute Sprint Demo"
  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }
  profiles {
    moid        = intersight_server_profile.compute-sprint-srv-1.id
    object_type = "server.Profile"
  }
}

resource "intersight_vnic_eth_if" "eth0" {
  name  = "eth0"
  order = 0
  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }
  placement {
    id     = "MLOM"
    pci_link = 0
    uplink = 0
  }
  cdn {
    source = "vnic"
    value = "VIC-MLOM-eth0"
  }
  vmq_settings {
    enabled = false
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.sprint-lan-connectivity-policy.id
    object_type = "vnic.LanConnectivityPolicy"
  }
  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.sprint-management-network.id
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.sprint-ethernet-adapter-policy.id
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.sprint-ethernet-qos-policy.id
  }
}

resource "intersight_vnic_eth_if" "eth1" {
  name  = "eth1"
  order = 1
  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }
  placement {
    id     = "MLOM"
    pci_link = 0
    uplink = 1
  }
  cdn {
    source = "vnic"
    value = "VIC-MLOM-eth1"
  }
  vmq_settings {
    enabled = false
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.sprint-lan-connectivity-policy.id
    object_type = "vnic.LanConnectivityPolicy"
  }
  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.sprint-production-network.id
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.sprint-ethernet-adapter-policy.id
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.sprint-ethernet-qos-policy.id
  }
}

resource "intersight_ntp_policy" "sprint-ntp-policy" {
  name    = "sprint-ntp-policy"
  enabled = true
  ntp_servers = [
    "ntp.esl.cisco.com",
    # "10.5.30.2"
  ]
  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }

  profiles {
    moid        = intersight_server_profile.compute-sprint-srv-1.id
    object_type = "server.Profile"
  }
}

resource "intersight_storage_disk_group_policy" "sprint-disk-group-policy" {
  name        = "sprint-disk-group-policy"
  description = "Disk Group Policy for Compute Sprint Demo"
  raid_level  = "Raid5"
  use_jbods   = false
  span_groups {
    disks {
      slot_number = 1
    }
    disks {
      slot_number = 2
    }
    disks {
      slot_number = 3
    }
    disks {
      slot_number = 4
    }
    disks {
      slot_number = 5
    }
  }
  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }
}

resource "intersight_storage_storage_policy" "sprint-storage-policy" {
  name                         = "sprint-storage-policy"
  description                  = "Storage Policy for OS boot drive"
  retain_policy_virtual_drives = true
  unused_disks_state           = "UnconfiguredGood"
  virtual_drives {
    object_type = "storage.VirtualDriveConfig"
    boot_drive = true
    drive_cache = "Default"
    expand_to_available = true
    io_policy = "Default"
    name = "sprint-os-boot"
    access_policy = "ReadWrite"
    disk_group_policy = intersight_storage_disk_group_policy.sprint-disk-group-policy.id
    read_policy = "ReadAhead"
    write_policy = "WriteBackGoodBbu"
  }
  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }

  profiles {
    moid        = intersight_server_profile.compute-sprint-srv-1.id
    object_type = "server.Profile"
  }
}

resource "intersight_boot_precision_policy" "sprint-boot-policy" {
  name                     = "sprint-boot-policy"
  description              = "Boot Policy for Compute Sprint Demo"
  configured_boot_mode     = "Legacy"
  enforce_uefi_secure_boot = false
  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }
  boot_devices {
    enabled     = true
    name        = "disk"
    object_type = "boot.LocalDisk"
    additional_properties = jsonencode({
      Slot = "MSTOR-RAID"
    })
  }
  boot_devices {
    enabled     = true
    name        = "vmedia"
    object_type = "boot.VirtualMedia"
    additional_properties = jsonencode({
      Subtype = "cimc-mapped-dvd"
    })
  }

  profiles {
    moid        = intersight_server_profile.compute-sprint-srv-1.id
    object_type = "server.Profile"
  }
}

resource "intersight_deviceconnector_policy" "sprint-device-connector" {
  name            = "sprint-device-connector"
  lockout_enabled = false
  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }
  profiles {
    moid        = intersight_server_profile.compute-sprint-srv-1.id
    object_type = "server.Profile"
  }  
}