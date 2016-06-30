output "name" {
  value = "${var.name}"
}

output "file_system_id" {
  value = "${aws_efs_file_system.efs.id}"
}

output "mount_target_ids" {
  value = "${join(",", aws_efs_mount_target.efs.*.id)}"
}

output "mount_target_interface_ids" {
  value = "${join(",", aws_efs_mount_target.efs.*.network_interface_id)}"
}

output "ec2_security_group_id" {
  value = "${aws_security_group.ec2.id}"
}

output "mnt_security_group_id" {
  value = "${aws_security_group.mnt.id}"
}
