FROM docker:dind

# Installation de GitLab Runner
RUN curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash && \
    apt-get install -y gitlab-runner

# Ajout du runner au groupe Docker
RUN usermod -aG docker gitlab-runner

# Point d'entrée : démarre Docker puis GitLab Runner
CMD ["dockerd"]
