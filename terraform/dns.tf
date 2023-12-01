locals {
  nodes = [
    oci_core_instance.k8s-1,
    oci_core_instance.k8s-2
  ]
}

resource "oci_dns_rrset" "rancher_server" {
  depends_on = [ oci_core_instance.rancher-server ]
  zone_name_or_id = var.dns_zone_id
  compartment_id = var.compartment_id
  domain = var.domain
  rtype = var.typeA

  items {
    domain = var.domain
    rdata = oci_core_instance.rancher-server.public_ip
    rtype = var.typeA
    ttl = var.rrset_items_ttl
  }
}

resource "oci_dns_rrset" "nodes" {
  depends_on = [ oci_dns_rrset.rancher_server ]
  count = var.instances_count > 1 ? 1 : 0
  #Required
  zone_name_or_id = var.dns_zone_id
  domain = "*.${var.domain}"
  rtype = var.typeA

  dynamic "items" {
    for_each = local.nodes
    iterator = node
    content {
      #Required
      domain = "*.${var.domain}"
      rdata = node.value["public_ip"]
      rtype = var.typeA
      ttl = var.rrset_items_ttl
    }
  }
}

