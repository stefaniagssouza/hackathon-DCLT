resource "newrelic_alert_policy" "solidarytech_aiops" {
  name                = "SolidaryTech AIOps - Donation Hot Path"
  incident_preference = "PER_POLICY"
}

resource "newrelic_nrql_alert_condition" "donation_error_rate" {
  account_id = var.newrelic_account_id
  policy_id  = newrelic_alert_policy.solidarytech_aiops.id
  type       = "static"
  name       = "Donation service error rate anomaly"
  enabled    = true

  nrql {
    query = "SELECT percentage(count(*), WHERE http.status_code >= 500) FROM Span WHERE service.name = 'donation-service'"
  }

  critical {
    operator              = "above"
    threshold             = 1
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  violation_time_limit_seconds = 3600
}

resource "newrelic_nrql_alert_condition" "donation_latency" {
  account_id = var.newrelic_account_id
  policy_id  = newrelic_alert_policy.solidarytech_aiops.id
  type       = "static"
  name       = "Donation service latency p95 SLO"
  enabled    = true

  nrql {
    query = "SELECT percentile(duration.ms, 95) FROM Span WHERE service.name = 'donation-service'"
  }

  critical {
    operator              = "above"
    threshold             = 300
    threshold_duration    = 600
    threshold_occurrences = "ALL"
  }

  violation_time_limit_seconds = 3600
}

resource "newrelic_nrql_alert_condition" "donation_no_telemetry" {
  account_id = var.newrelic_account_id
  policy_id  = newrelic_alert_policy.solidarytech_aiops.id
  type       = "static"
  name       = "Donation service telemetry missing"
  enabled    = true

  nrql {
    query = "SELECT count(*) FROM Span WHERE service.name = 'donation-service'"
  }

  critical {
    operator              = "below"
    threshold             = 1
    threshold_duration    = 600
    threshold_occurrences = "ALL"
  }

  violation_time_limit_seconds = 3600
}
