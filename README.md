# TF_EFS_MOUNT

Provides an EFS file system, mount targets and security groups.

## Usage

```hcl
module "efs_mount" {
  source = "github.com/manheim/tf_efs_mount"

  name    = "my-efs-mount"
  subnets = "subnet-abcd1234,subnet-efgh5678"
  vpc_id  = "vpc-abcd1234"

}
```

## Argument Reference

The following arguments are supported:

- ``name`` - (Required) The reference_name of your file system. Also, used in tags.
- ``subnets`` - (Required) A comma separated list of subnet ids where mount targets will be.
- ``vpc_id`` - (Required) The VPC ID where NFS security groups will be.

## Attribute Reference

The following attributes are exported:

- ``name`` - The reference_name of the file system.
- ``file_systemd_id`` - The ID of the file system.
- ``mount_target_ids`` - A comma separated list of mount target ids.
- ``mount_target_interface_ids`` - A comma separated list of network interface ids.
- ``ec2_security_group_id`` - The ID of the security group to apply to EC2 instances.
- ``mnt_security_group_id`` - The ID of the security group applied to mount targets.

