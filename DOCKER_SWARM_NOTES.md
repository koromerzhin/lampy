# Corrections Docker Swarm

## Modifications apportées

### docker-compose.yml
1. **Version mise à jour** : De 3.8 à 3.9 pour Docker Swarm
2. **Réseaux** : Changement de `bridge` à `overlay` pour Docker Swarm
3. **Services** :
   - Ajout de `replicas: 1` dans la section deploy
   - Suppression des `depends_on` (non supporté en mode Swarm)
   - Suppression des `restart` (géré par Swarm automatiquement)
   - Ajout de `traefik.docker.network=proxylampy` pour les services exposés
   - Configuration des volumes avec `type: bind` explicite
   - Contraintes de placement pour les services stateful (manager nodes)
   - Mode `ingress` pour les ports au lieu de `host`

### config/traefik/traefik.yml
1. **Provider Docker** : 
   - Ajout de `swarmMode: true`
   - `exposedByDefault: false` pour plus de sécurité
   - Configuration du réseau par défaut : `network: proxylampy`
   - Ajout de `watch: true` pour les providers
2. **Suppression** : Retrait du provider `swarm` obsolète

### Nouveaux fichiers
1. **create-networks.sh** : Script pour créer les réseaux overlay nécessaires

## Déploiement

1. Initialiser Docker Swarm (si pas déjà fait) :
   ```bash
   docker swarm init
   ```

2. Créer les réseaux overlay :
   ```bash
   ./create-networks.sh
   ```

3. Déployer la stack :
   ```bash
   docker stack deploy -c docker-compose.yml lampy
   ```

## Commandes utiles

- Voir les services : `docker service ls`
- Voir les détails d'un service : `docker service ps <service_name>`
- Voir les logs d'un service : `docker service logs <service_name>`
- Mettre à jour un service : `docker service update <service_name>`
- Supprimer la stack : `docker stack rm lampy`

## Notes importantes

- Les volumes nommés sont partagés entre tous les nœuds du cluster
- Les services avec des données persistantes sont contraints aux nœuds manager
- Traefik est configuré pour détecter automatiquement les services Docker Swarm
- Les réseaux overlay permettent la communication entre services sur différents nœuds