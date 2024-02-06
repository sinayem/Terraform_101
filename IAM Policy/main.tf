# Set provider and attach necesary aws credentials
provider "aws" {
  region = "us-east-1"
}
# create a IAM user
resource "aws_iam_user" "admin-user" {
  name = "Intern"
  tags = {
    Description = "New Intern"
  }
}


# This is the policy i want to attach
# {
# "Version": "2012-10-17",
# "Statement": [
# {
# "Effect": "Allow",
# "Action": "*",
# "Resource": "*"
# }
# ]
# }

# First create a policy

resource "aws_iam_policy" "AdminUsers" {
  name = "AdminUsers"
  policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
            }
        ]
    }
  EOF
}
# Attach the policy 
resource "aws_iam_user_policy_attachment" "InternAdminAccess" {
  user = aws_iam_user.admin-user.name
  policy_arn = aws_iam_policy.AdminUsers.arn
}