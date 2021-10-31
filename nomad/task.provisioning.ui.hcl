job "provisioning" {
    # Specify this job should run in the region named "us". Regions
    # are defined by the Nomad servers' configuration.
    region = "calvinverse-01"

    # Spread the tasks in this job between us-west-1 and us-east-1.
    datacenters = ["calvinverse-01"]

    # Run this job as a "service" type. Each job type has different
    # properties. See the documentation below for more examples.
    type = "service"

    # Specify this job to have rolling updates, two-at-a-time, with
    # 30 second intervals.
    update {
        stagger      = "30s"
        max_parallel = 2
    }

    # All tasks in this job must run on linux.
    constraint {
        attribute = "${attr.kernel.name}"
        value     = "linux"
    }

    group "ui" {

        # Specify the number of these tasks we want.
        count = 1

        network {
            # This requests a dynamic port named "http". This will
            # be something like "46283", but we refer to it via the
            # label "http".
            port "http" {
                to = 8080
            }

            # This requests a dynamic port named "https". This will
            # be something like "46283", but we refer to it via the
            # label "https".
            port "https" {}
        }

        task "provisioning.ui" {
            driver = "docker"

            config {
                image = "https://testcalvinverse.azurecr.io/service-provisioning-ui-web:0.2.0-health-checks.1"
                force_pull = true
                auth {
                    username = "e3aa18cb-3a80-4975-98e7-0407f0eb68f1"
                    password = "33b9243b-ed6c-4026-921c-64de30f5cc03"
                }
                ports = [ "http" ]
            }

            env {
                CONSUL_DATACENTER_NAME="calvinverse-01"
                CONSUL_DOMAIN_NAME="consulverse"
                CONSUL_SERVER_IPS="hashiserver-0.infrastructure.ad.calvinverse.net;hashiserver-1.infrastructure.ad.calvinverse.net;hashiserver-2.infrastructure.ad.calvinverse.net"
                CONSUL_ENCRYPT="n0LlbThdjJqROGokprQDpw=="
            }

            resources {
                cpu = 500
                memory = 256
            }
        }
    }
}
