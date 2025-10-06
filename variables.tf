
variable "firewall_policy_id" {
  description = "Resource ID of the existing Azure Firewall Policy."
  type        = string
}

variable "rule_collection_groups" {
  description = <<-EOT
    List of Rule Collection Groups to create under the firewall policy.
    Each item supports application, network, and DNAT rule collections.
  EOT

  type = list(object({
    name     = string
    priority = number

    application_rule_collections = optional(list(object({
      name     = string
      priority = number
      action   = string # Allow | Deny
      rules = list(object({
        name                  = string
        source_addresses      = optional(list(string), [])
        source_ip_groups      = optional(list(string), [])
        destination_fqdns     = optional(list(string), [])
        destination_fqdn_tags = optional(list(string), [])
        web_categories        = optional(list(string), [])
        # App rule protocols: Http/Https/Mssql with port
        protocols = list(object({
          type = string
          port = number
        }))
      }))
    })), [])

    network_rule_collections = optional(list(object({
      name     = string
      priority = number
      action   = string # Allow | Deny
      rules = list(object({
        name                   = string
        source_addresses       = optional(list(string), [])
        source_ip_groups       = optional(list(string), [])
        destination_addresses  = optional(list(string), [])
        destination_ip_groups  = optional(list(string), [])
        destination_fqdns      = optional(list(string), [])
        protocols              = list(string) # TCP | UDP | ICMP | Any
        destination_ports      = list(string)
      }))
    })), [])

    nat_rule_collections = optional(list(object({
      name     = string
      priority = number
      action   = string # Dnat
      rules = list(object({
        name                  = string
        source_addresses      = optional(list(string), [])
        source_ip_groups      = optional(list(string), [])
        destination_address   = string
        destination_ports     = list(string)
        protocols             = list(string) # TCP | UDP | Any
        translated_address    = string
        translated_port       = string
      }))
    })), [])
  }))
}
