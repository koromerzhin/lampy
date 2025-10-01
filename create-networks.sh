#!/bin/bash

# Script pour créer les réseaux overlay nécessaires pour Docker Swarm

echo "Création des réseaux overlay pour Docker Swarm..."

# Créer le réseau proxylampy
if ! docker network ls | grep -q "proxylampy"; then
    echo "Création du réseau proxylampy..."
    docker network create --driver overlay --attachable proxylampy
else
    echo "Le réseau proxylampy existe déjà."
fi

# Créer le réseau serverlampy
if ! docker network ls | grep -q "serverlampy"; then
    echo "Création du réseau serverlampy..."
    docker network create --driver overlay --attachable serverlampy
else
    echo "Le réseau serverlampy existe déjà."
fi

echo "Réseaux créés avec succès !"
echo ""
echo "Pour déployer la stack, utilisez :"
echo "docker stack deploy -c docker-compose.yml lampy"