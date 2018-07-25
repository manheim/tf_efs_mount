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
- ``file_system_id`` - The ID of the file system.
- ``file_system_dns_name`` - The DNS name of the file system.
- ``mount_target_ids`` - A comma separated list of mount target ids.
- ``mount_target_interface_ids`` - A comma separated list of network interface ids.
- ``ec2_security_group_id`` - The ID of the security group to apply to EC2 instances.
- ``mnt_security_group_id`` - The ID of the security group applied to mount targets.

## How to use in EC2-Instance

You can allow access to the EFS and mount it in an EC2 instance like this:

```hcl
resource "aws_key_pair" "user-ssh-key" {
  key_name   = "your-key-name"
  public_key = "your-public-ssh-key"
}

resource "aws_instance" "example-instance-with-efs" {
  ami                    = "ami-abc123"
  subnet_id              = "subnet-345abc"
  vpc_security_group_ids = [
    "${module.efs_mount.ec2_security_group_id}", # EFS access
  ]
  instance_type          = "t2.micro"

  key_name = "${aws_key_pair.user-ssh-key.key_name}"

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }

    inline = [
      # mount EFS volume
      # https://docs.aws.amazon.com/efs/latest/ug/gs-step-three-connect-to-ec2-instance.html
      # create a directory to mount our efs volume to
      "sudo mkdir -p /mnt/efs",
      # mount the efs volume
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${module.efs_mount.file_system_dns_name}:/ /mnt/efs",
      # create fstab entry to ensure automount on reboots
      # https://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot.html#mount-fs-auto-mount-on-creation
      "sudo su -c \"echo '${module.efs_mount.file_system_dns_name}:/ /mnt/efs nfs4 defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab\"" #create fstab entry to ensure automount on reboots
    ]
  }
}

```

Please note that you need to take care of adding some EFS/NFS capabilities to your instance first. For example, when running this on ubuntu, you can add the following lines to the start of your provisioner-script:
```hcl
    inline = [
      # Install dependencies required for ubuntu
      "sudo apt-get update",
      "sudo apt-get install -y nfs-common",
      # [...]
    ]
```
