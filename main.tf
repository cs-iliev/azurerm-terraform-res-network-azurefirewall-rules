
locals {
  rcgs = var.rule_collection_groups
}

resource "azurerm_firewall_policy_rule_collection_group" "this" {
  for_each           = { for rcg in local.rcgs : rcg.name => rcg }
  name               = each.value.name
  firewall_policy_id = var.firewall_policy_id
  priority           = each.value.priority

  ##########################################################################
  # Application Rule Collections
  ##########################################################################
  dynamic "application_rule_collection" {
    for_each = coalesce(try(each.value.application_rule_collections, null), [])
    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name = rule.value.name

          source_addresses = length(try(rule.value.source_addresses, [])) > 0 ? rule.value.source_addresses : null
          source_ip_groups = length(try(rule.value.source_ip_groups, [])) > 0 ? rule.value.source_ip_groups : null

          destination_fqdns      = length(try(rule.value.destination_fqdns, [])) > 0 ? rule.value.destination_fqdns : null
          destination_fqdn_tags  = length(try(rule.value.destination_fqdn_tags, [])) > 0 ? rule.value.destination_fqdn_tags : null
          web_categories         = length(try(rule.value.web_categories, [])) > 0 ? rule.value.web_categories : null

          dynamic "protocols" {
            for_each = try(rule.value.protocols, [])
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
        }
      }
    }
  }

  ##########################################################################
  # Network Rule Collections
  ##########################################################################
  dynamic "network_rule_collection" {
    for_each = coalesce(try(each.value.network_rule_collections, null), [])
    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name = rule.value.name

          source_addresses      = length(try(rule.value.source_addresses, [])) > 0 ? rule.value.source_addresses : null
          source_ip_groups      = length(try(rule.value.source_ip_groups, [])) > 0 ? rule.value.source_ip_groups : null
          destination_addresses = length(try(rule.value.destination_addresses, [])) > 0 ? rule.value.destination_addresses : null
          destination_ip_groups = length(try(rule.value.destination_ip_groups, [])) > 0 ? rule.value.destination_ip_groups : null
          destination_fqdns     = length(try(rule.value.destination_fqdns, [])) > 0 ? rule.value.destination_fqdns : null

          protocols         = rule.value.protocols
          destination_ports = rule.value.destination_ports
        }
      }
    }
  }

  ##########################################################################
  # NAT Rule Collections (DNAT)
  ##########################################################################
  dynamic "nat_rule_collection" {
    for_each = coalesce(try(each.value.nat_rule_collections, null), [])
    content {
      name     = nat_rule_collection.value.name
      priority = nat_rule_collection.value.priority
      action   = nat_rule_collection.value.action

      dynamic "rule" {
        for_each = nat_rule_collection.value.rules
        content {
          name = rule.value.name

          source_addresses    = length(try(rule.value.source_addresses, [])) > 0 ? rule.value.source_addresses : null
          source_ip_groups    = length(try(rule.value.source_ip_groups, [])) > 0 ? rule.value.source_ip_groups : null
          destination_address = rule.value.destination_address
          destination_ports   = rule.value.destination_ports
          protocols           = rule.value.protocols

          translated_address = rule.value.translated_address
          translated_port    = rule.value.translated_port
        }
      }
    }
  }
}
