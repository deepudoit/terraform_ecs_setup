variable "key_name" {
  type        = string
  description = "EC2 Key pair"
  default     = "ssh_key"
}

variable "cluster_name" {
  type        = string
  description = "Name of ECS cluster"
  default = "ecs_cluster"
}