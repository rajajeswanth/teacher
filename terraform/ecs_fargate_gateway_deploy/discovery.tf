#discovery.tf

resource "aws_service_discovery_private_dns_namespace" "student_teacher_dns_namespace" {
  name        = "studentteacher.local"
  description = "Studen Teacher Local"
  vpc         = aws_vpc.main.id
}

resource "aws_service_discovery_service" "student_dns_discovery_service" {
  name = "student"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.student_teacher_dns_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 2
  }
}

resource "aws_service_discovery_service" "teacher_dns_discovery_service" {
  name = "teacher"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.student_teacher_dns_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 2
  }
}
