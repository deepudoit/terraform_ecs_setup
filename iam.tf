//resource "aws_iam_role" "ecs-instance-role" {
//  name               = "ecs-instance-role-web"
//  path               = "/"
//  assume_role_policy = <<EOT
//{
//    "Effect": "Allow",
//    "Action": [
//        "iam:CreateServiceLinkedRole"
//    ],
//    "Resource": "arn:aws:iam::*:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS*",
//    "Condition": {"StringLike": {"iam:AWSServiceName": "ecs.amazonaws.com"}}
//}
//EOT
//}
//
//resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
//  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
//  role       = aws_iam_role.ecs-instance-role.name
//}
//
//resource "aws_iam_instance_profile" "ecs-service-role" {
//  role = aws_iam_role.ecs-instance-role.name
//}

resource "aws_iam_service_linked_role" "service-role" {
  aws_service_name = "ecs.amazonaws.com"
}