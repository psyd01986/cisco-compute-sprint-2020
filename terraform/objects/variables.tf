variable "org_moid" {
  default = "<< Org moid from intersight.com >>"
}

variable "management_vlan" {
  default = 30
}

variable "production_vlan" {
  default = 33
}

variable "compute-sprint-srv-1" {
  default = "<< Server moid from intersight.com >>"
}

variable "remote-server" {
  default = "10.5.30.39"
}

variable "remote-huu-link" {
  default = "http://10.5.30.39/staticfiles/ucs-c240m5-huu-4.1.1f.iso"
}
