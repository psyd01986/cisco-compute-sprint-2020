resource "intersight_server_profile" "compute-sprint-srv-1" {
  name = "compute-sprint-srv-1"

  organization {
    object_type = "organization.Organization"
    moid = var.org_moid
  }

  assigned_server {
    moid = var.compute-sprint-srv-1
    object_type = "compute.RackUnit"
  }
  action = "Deploy"
}