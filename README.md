
# avm-res-network-azurefirewall-rules

Terraform module for managing **Azure Firewall Policy Rule Collection Groups** — application, network, and DNAT rules —
designed to slot into Azure Landing Zones / VWAN secured hubs. Follows AVM-style patterns and uses the modern
**Firewall Policy** model (not the legacy per-firewall `*_rule_collection` resources).

## Features

- Creates one or many **Rule Collection Groups (RCGs)** under an existing Firewall Policy
- Supports **Application**, **Network**, and **NAT (DNAT)** rule collections
- Strong typing for rules with sensible defaults
- Idempotent, GitOps-friendly inputs (maps/lists) suitable for Terragrunt overlays

## Requirements

- AzureRM provider `~> 4.20`
- An existing **Firewall Policy** (you pass its resource ID)

## Example

```hcl
module "azurefirewall_rules" {
  source = "../.."

  firewall_policy_id = azurerm_firewall_policy.example.id

  rule_collection_groups = [
    {
      name     = "rcg-main"
      priority = 100

      application_rule_collections = [
        {
          name     = "app-allow-outbound-web"
          priority = 100
          action   = "Allow"
          rules = [
            {
              name                 = "out-web"
              source_addresses     = ["10.10.1.0/24"]
              destination_fqdns    = ["*.microsoft.com", "aka.ms"]
              destination_fqdn_tags = []
              web_categories       = []
              protocols = [
                { type = "Http",  port = 80  },
                { type = "Https", port = 443 },
              ]
            }
          ]
        }
      ]

      network_rule_collections = [
        {
          name     = "net-allow-dns"
          priority = 200
          action   = "Allow"
          rules = [
            {
              name                 = "dns-udp"
              source_addresses     = ["10.10.0.0/16"]
              destination_addresses = ["10.20.0.4"]
              destination_fqdns     = []
              protocols            = ["UDP"]
              destination_ports    = ["53"]
            }
          ]
        }
      ]

      nat_rule_collections = [
        {
          name     = "dnat-web"
          priority = 300
          action   = "Dnat"
          rules = [
            {
              name                  = "public-80-to-web1-8080"
              source_addresses      = ["*"]
              destination_address   = "20.30.40.50"   # Public IP on the firewall
              destination_ports     = ["80"]
              protocols             = ["TCP"]
              translated_address    = "10.10.2.10"
              translated_port       = "8080"
            }
          ]
        }
      ]
    }
  ]
}
```

See a runnable example under [`examples/simple`](examples/simple).

## Inputs

- `firewall_policy_id` (string, required): Resource ID of the target Firewall Policy.
- `rule_collection_groups` (list(object), required): One or more RCG definitions:
  - `name` (string), `priority` (number)
  - `application_rule_collections` (list(object))
  - `network_rule_collections` (list(object))
  - `nat_rule_collections` (list(object))

See `variables.tf` for full schema.

## Outputs

- `rule_collection_group_ids`: Map of RCG names to IDs
- `rule_collection_group_objects`: Full objects with name and id for convenience

## Notes

- **SNAT** is not expressed via NAT rule collections in policy-based firewalls; configure it via policy settings (not in this module).
- This module only **adds rule collections**. Creation of the Firewall Policy (and Azure Firewall/vHub) is out of scope.
