# OIDC setup (rappel rapide)

1. AWS IAM: Provider OIDC `gitlab.com`; rôle avec action `sts:AssumeRoleWithWebIdentity` et condition `gitlab.com:sub` restreinte au projet/branche.
2. GitLab: variable `AWS_ROLE_TO_ASSUME` (ARN du rôle) et token `CI_JOB_JWT_V2` (activé par défaut).
3. Pipeline: le job `prepare:ecr-docker-config` échange le jeton contre des credentials temporaires, puis authentifie Kaniko sur ECR.

Example trust policy snippet:
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Federated": "arn:aws:iam::123456789012:oidc-provider/gitlab.com" },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "gitlab.com:sub": "project_path:namespace/project:ref_type:branch:ref:main"
        }
      }
    }
  ]
}
