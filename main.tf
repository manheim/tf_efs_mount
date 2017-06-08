resource "random_id" "creation_token" {
  byte_length   = 8
  prefix        = "${var.name}-"
}

resource "aws_efs_file_system" "efs" {
  creation_token = "${random_id.creation_token.hex}"

  tags {
    Name = "${var.name}"
    CreationToken = "${random_id.creation_token.hex}"
    terraform = "true"
  }
}

resource "aws_efs_mount_target" "efs" {
  count = "${length(split(",", var.subnets))}"

  file_system_id = "${aws_efs_file_system.efs.id}"
  subnet_id      = "${element(split(",", var.subnets), count.index)}"
  security_groups = ["${aws_security_group.mnt.id}"]
}

resource "aws_security_group" "ec2" {
  name        = "${var.name}-ec2"
  description = "Allow traffic out to NFS for ${var.name}-mnt."
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "allow_nfs_out_to_${var.name}-mnt"
    terraform = "true"
  }
}

resource "aws_security_group_rule" "nfs-out" {
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id = "${aws_security_group.ec2.id}"
  source_security_group_id = "${aws_security_group.mnt.id}"
}

resource "aws_security_group" "mnt" {
  name        = "${var.name}-mnt"
  description = "Allow traffic from instances using ${var.name}-ec2."
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "allow_nfs_in_from_${var.name}-ec2"
    terraform = "true"
  }
}

resource "aws_security_group_rule" "nfs-in" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id = "${aws_security_group.mnt.id}"
  source_security_group_id = "${aws_security_group.ec2.id}"
}
