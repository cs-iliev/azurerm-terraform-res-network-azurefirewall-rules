
output "rule_collection_group_ids" {
  description = "Map of Rule Collection Group names to resource IDs."
  value       = { for k, v in azurerm_firewall_policy_rule_collection_group.this : k => v.id }
}

output "rule_collection_group_objects" {
  description = "List of objects containing name and id for created Rule Collection Groups."
  value = [
    for k, v in azurerm_firewall_policy_rule_collection_group.this :
    { name = v.name, id = v.id }
  ]
}
