Dans l’interface GitLab, tu ajoutes une variable de pipeline CI_ENVIRONMENT_NAME avec les valeurs dev, staging, ou prod :

En local, CI_ENVIRONMENT_NAME = dev

Sur MR vers main, CI_ENVIRONMENT_NAME = staging

Sur tag ou release, CI_ENVIRONMENT_NAME = prod