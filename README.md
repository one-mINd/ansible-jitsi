# ansible-role-jitsi

Ansible role for deploying and managing a self-hosted Jitsi Meet instance using the official docker-jitsi-meet project.

The role automates:
- downloading and configuring docker-jitsi-meet
- generating and managing `.env` configuration
- provisioning internal Jitsi service accounts
- managing Jitsi users
- running and updating Docker containers

The role is intended for fast and reproducible Jitsi deployments with infrastructure-as-code practices.

---

# Quick Start

Create a playbook:

```yaml
#!/usr/bin/env ansible-playbook

- name: Configure jitsi in target hosts
  hosts: all
  remote_user: root
  become: yes

  roles:
    - ansible-role-jitsi
```
Then define internal Jitsi passwords (described below) and run the playbook:

```bash
ansible-playbook playbook.yml
```

# Internal Service Passwords

The following variables are required for internal communication between Jitsi services:

```yaml
jitsi_jicofo_auth_password: secret
jitsi_jvb_auth_password: secret
jitsi_jigasi_xmpp_password: secret
jitsi_jigasi_transcriber_password: secret
jitsi_jibri_recorder_password: secret
jitsi_jibri_xmpp_password: secret
```

These passwords are extremely important and **must be explicitly defined**.

You can generate secure passwords using the included helper script:

```bash
./internal-passwords
```

Example output:

```yaml
jitsi_jicofo_auth_password: 1d8c...
jitsi_jvb_auth_password: 9aa2...
jitsi_jigasi_xmpp_password: 7bc1...
jitsi_jigasi_transcriber_password: e2ff...
jitsi_jibri_recorder_password: 4c99...
jitsi_jibri_xmpp_password: a0d1...
```

You can copy this output directly into your variables file.

## Important

If you later decide to change these passwords, you must remove the existing Jitsi persistent configuration directory:

```bash
rm -rf {{ jitsi_dir }}/.jitsi-meet-cfg
```

Otherwise old Prosody accounts and credentials will remain cached and Jitsi components may fail to authenticate.

# User Management

The role can fully manage Jitsi users through Ansible variables.

Example:

```yaml
jitsi_users:
  - name: admin
    password: strongpassword

  - name: user1
    password: userpassword
```

During deployment the role:

- detects the Prosody container
- removes existing users
- recreates users from `jitsi_users`

This makes user management fully declarative and reproducible.

# Jitsi Configuration via Environment Variables

Jitsi configuration is managed through `jitsi_envs`.

Example:

```yaml
jitsi_envs:
  - PUBLIC_URL=https://meet.example.com
  - TZ=UTC
  - ENABLE_AUTH=1
```

The role renders these variables directly into the `.env` file used by docker-jitsi-meet.

Full list of supported environment variables:

- https://github.com/jitsi/docker-jitsi-meet/blob/master/env.example

# Some Useful Examples of Variable Sets

## Run Jitsi without a reverse proxy

Allow Jitsi to obtain Let's Encrypt certificates automatically:

```yaml
jitsi_envs:
  - ENABLE_LETSENCRYPT=1
  - LETSENCRYPT_DOMAIN=meet.example.com
  - LETSENCRYPT_EMAIL=meet@mail.com
  - LETSENCRYPT_ACME_SERVER=letsencrypt
```

## Limit Java component memory usage

Useful for small VPS instances:

```yaml
jitsi_envs:
  - JICOFO_MAX_MEMORY=2048m
  - VIDEOBRIDGE_MAX_MEMORY=2048m
```

## Restrict access to authorized users only

Enable internal authentication:

```yaml
jitsi_envs:
  - ENABLE_AUTH=1
  - ENABLE_GUESTS=0
  - AUTH_TYPE=internal
```

Only authenticated users will be able to create conferences.
