output "release_name" {
  value = helm_release.chart.name
}

output "chart_version" {
  value = helm_release.chart.version
}