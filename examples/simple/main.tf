
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# --- Example infrastructure scaffolding (you would bring your own policy) ---
resource "azurerm_resource_group" "rg" {
  name     = "rg-afw-example"
  location = "westeurope"
}

resource "azurerm_firewall_policy" "fp" {
  name                = "fp-example"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

module "azurefirewall_rules" {
  source = "../.."

  firewall_policy_id = azurerm_firewall_policy.fp.id

  rule_collection_groups = [
    {
      name     = "rcg-main"
      priority = 100

      application_rule_collections = [
        {
          name     = "app-allow-web"
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
              name                  = "dns-udp"
              source_addresses      = ["10.10.0.0/16"]
              destination_addresses = ["10.20.0.4"]
              destination_fqdns     = []
              protocols             = ["UDP"]
              destination_ports     = ["53"]
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
              name                = "public-80-to-web1-8080"
              source_addresses    = ["*"]
              destination_address = "20.30.40.50"
              destination_ports   = ["80"]
              protocols           = ["TCP"]
              translated_address  = "10.10.2.10"
              translated_port     = "8080"
            }
          ]
        }
      ]
    }
  ]
}
