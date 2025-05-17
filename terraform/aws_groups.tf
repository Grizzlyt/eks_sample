resource "aws_iam_group" "eks_admin" {
  name = "eks_admin_group"
}

resource "aws_iam_group" "eks_readonly" {
  name = "eks_readonly_group"
}
