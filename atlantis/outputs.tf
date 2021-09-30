//output "full-names-of-repos" {
//  value = data.github_repository.repo.*.name
//}

output "atlantis_url" {
  value = module.atlantis.atlantis_url
}