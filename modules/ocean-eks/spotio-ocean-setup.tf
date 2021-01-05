resource "spotinst_ocean_aws" "this" {

    depends_on = [ module.eks ]

    name                        = var.cluster_name
    controller_id               = var.cluster_identifier != null ? var.cluster_identifier : module.eks.cluster_id
    region                      = var.region
    max_size                    = var.max_size
    min_size                    = var.min_size
    desired_capacity            = var.desired_capacity
    subnet_ids                  = module.vpc.private_subnets
    image_id                    = var.ami_id != null ? var.ami_id : module.eks.workers_default_ami_id
    security_groups             = [ aws_security_group.all_worker_mgmt.id, module.eks.worker_security_group_id ]
    key_name                    = var.key_name
    associate_public_ip_address = var.associate_public_ip_address
    iam_instance_profile        = aws_iam_instance_profile.workers.arn

    user_data = <<-EOF
        #!/bin/bash
        set -o xtrace
        /etc/eks/bootstrap.sh ${var.cluster_name}
    EOF

    tags {

        key   = "Name"
        value = "${var.cluster_name}-ocean-cluster-node"

    }

    tags {

        key   = "kubernetes.io/cluster/${var.cluster_name}"
        value = "owned"

    }

    autoscaler {

        autoscale_is_enabled     = true
        autoscale_is_auto_config = true

        autoscale_down {

            max_scale_down_percentage = var.max_scale_down_percentage

        }

    }

}
