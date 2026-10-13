# lampy 🛠️

[![Version](https://img.shields.io/github/package-json/v/koromerzhin/lampy)](CHANGELOG.md)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/koromerzhin/lampy/graphs/commit-activity)
[![Continuous Integration](https://github.com/koromerzhin/lampy/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/koromerzhin/lampy/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> Stack LAMP locale sur Docker Swarm : MariaDB, Redis, Mercure, Mailpit,
> phpMyAdmin, Portainer et Traefik, pilotée par [Task](https://taskfile.dev/).

## Services

| Service | Image | Accès |
| ------- | ----- | ----- |
| traefik | traefik:v3.7.14 | proxy.traefik.me (dashboard) |
| mercure | dunglas/mercure:v1.1.2 | interne (/.well-known/mercure) |
| redis | redis:8.10.2 | interne |
| mariadb | mariadb:13.0.2 | 127.0.0.1:3306 |
| mailtest | axllent/mailpit:v1.31.5 | mailtest.traefik.me |
| phpmyadmin | phpmyadmin/phpmyadmin:5.2.3 | phpmyadmin.traefik.me |
| portainer | portainer/portainer-ce:2.45.2 | portainer.traefik.me |
| reverse | alpine:3.23 | certificats traefik.me (one-shot) |

Les frontaux sont sur le réseau `proxylampy`, les backends sur
`serverlampy` (voir `docker-compose.yml`).

## Prérequis

- [task](https://taskfile.dev/) et [Docker](https://docs.docker.com/) (mode Swarm)
- [Node.js](https://nodejs.org/) (version dans `.nvmrc`, `nvm use`) pour le lint
- `openssl` pour (re)générer le mot de passe du dashboard

## Installation

```sh
git clone --recursive https://github.com/koromerzhin/lampy.git lampy
cd lampy
npm ci
```

## Configuration

```sh
cp .env.example .env
```

Éditez `.env` (jamais committé) : mots de passe, clés JWT Mercure
(`openssl rand -hex 32`) et surtout `ADVERTISEADDR`, qui **doit** être une
IP locale existante (`ip -4 addr show`) — sinon `docker swarm init`
échoue avec « must specify a listening address ».

Changez le mot de passe du dashboard Traefik (`admin` / `changeme` par défaut) :

```sh
task lampy:dashboard-password
```

Puis validez la configuration :

```sh
task env:validate
docker compose config --quiet
```

## Déploiement

```sh
task lampy:exec
```

Cela enchaîne : init Swarm → réseaux `overlay` → pull des images →
`docker stack deploy` → attente des 7 services → liste. Suivi au quotidien :

```sh
task lampy:ls
task lampy:waiting
task bash:mariadb   # shell dans un service (mariadb, redis, mercure, …)
```

## ⚠️ Usage local uniquement

Cette stack est calibrée pour un poste de développement : hub Mercure
ouvert (`ALLOW_ANONYMOUS`, CORS `*`), certificats `traefik.me` récupérés en
HTTP, dashboard Traefik protégé par un simple basic-auth. Ne l'exposez pas
telle quelle sur un réseau non maîtrisé.

## Aide

```sh
task --list
task help
task env:show
```

## Intégration continue

- `lint` : `npm ci` + `task lint:all`, avec garde-fou anti-placeholder
  (`CHANGE_ME` interdit dans `traefik/middlewares.yml`).
- `launch` : recrée `.env` depuis l'exemple et déploie la stack complète
  sur le runner — premier endroit où un secret vide ou une image cassée
  se voient (timeout `lampy:waiting`).

## 🤝 Contribution

Contributions, issues et demandes de fonctionnalités bienvenues :
[issues](https://github.com/koromerzhin/lampy/issues).

## 📝 Licence

Copyright © 2019 [koromerzhin](https://github.com/koromerzhin).
Projet sous licence [MIT](https://github.com/koromerzhin/lampy/blob/develop/LICENSE).

## ✨ Contributeurs

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/koromerzhin"><img src="https://avatars0.githubusercontent.com/u/308012?v=4" width="100px;" alt=""/><br /><sub><b>Le TOULLEC Martial</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/apps/mend-bolt-for-github"><img src="https://avatars.githubusercontent.com/in/16809?v=4" width="100px;" alt=""/><br /><sub><b>mend-bolt-for-github[bot]</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/apps/renovate"><img src="https://avatars.githubusercontent.com/in/2740?v=4" width="100px;" alt=""/><br /><sub><b>renovate[bot]</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/apps/dependabot"><img src="https://avatars.githubusercontent.com/in/29110?v=4" width="100px;" alt=""/><br /><sub><b>dependabot[bot]</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.mend.io/free-developer-tools/renovate/"><img src="https://avatars.githubusercontent.com/u/25180681?v=4" width="100px;" alt=""/><br /><sub><b>Mend Renovate</b></sub></a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
