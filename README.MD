# Devops Project 3 : Django webapp CICD

## 1- Objectifs

L'objectif principal est de déployer automatiquement l'application "webapp" fonctionnant en Python avec le framework Django et un base de données postgres.

Cette application foncrionnera conteneurisé sous docker.

Le pipeline de déloiement fonctionne sous jenkins pour la partie CI et sous ansible pour la partie CD.

Les tests de sécurité seront réalisé par snyk dont les resultats seront accessibles dans le workspace Jenkins sous le fichier test_result.log.

```
 build ->  Test -> scan -> push -> Deploy (Prod and  Preprod) -> Test -> Monitor
```

## 2- Pre-Requis

Vous devez avoir a minima 2 environments de déploiement:
  - 1 staging
  - 1 production

Environnement de CI sous jenkins:
- Un serveur jenkins 
- Un agent jenkins nommé "agent1" dans le pramétrage de Jenkins

  L'agent jenkins :
  - Version de Linux : ubuntu 20.x
  - Docker en dernière version
  - Snyk CLI en dernière version

Environnement Ansible 
- 1 serveur Ansible 


## Connectivité 

Accès ssh :
- Serveur Ansible vers les serveurs de production et de staging avec un login faisant parti du groupe root
- l'agent Jenkins doit pourvoir accéder au serveur Ansible en ssh avec un login faisant parti du groupe root

Tous les serveurs cités doivent avoir un accès internet (accès github et dockerHub)


## Variables d'environnement:

  ansibleServer = "" // Serveur Ansible
  stagingServer = "" // IP Serveur d'un des serveur de staging 
  prodServer = "" // IP d'un des serveur de production
  homeDirAnsible = "ansible_deploy" // répertoire 
  USERNAME = "" // Nom de votre user dockerHub
  REPO_GIT = "https://github.com/steissier/devops-project3.git" // Repository GIT 
  IMG_NAME_WEBAPP = "img_webapp" // Nom de l'image qui sera poussée sur le dockerHub
  CONTAINTER_NAME_WEB = "webapp" // Nom du conteneur pour la webapp

Il existe d'autre variable (Ex : Port) qu'il n'est pas souhaitable de modifier.

## Playbook ansible

Voici les exemples de playbook que vous devez déployer sur votre serveur Ansible.

Vous trouverez un exemple fonctionnel dans cette repo
https://github.com/steissier/deploy_webapp_ansible.git

3 fichiers :
Un fichier hosts.yml : faisant l'inventaire de vos environnements 
    prod:
      vars:
        ansible_user: "ubuntu"
        ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
      hosts:
        AnsibleProd:
          ansible_host: "" // Déclarez ici votre environnement de production
    staging:
      vars:
        ansible_user: "ubuntu"
        ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
      hosts:
        AnsibleStaging:
          ansible_host: "" // // Déclarez ici votre environnement de staging
    master:
      vars:
        ansible_connection: local
        ansible_user: "ubuntu"
      hosts:
        AnsibleMaster:
          ansible_host: "localhost

1 fichier main_prod.yml
  - name: "Installation Docker"
    gather_facts: yes
    become: yes
    hosts: "prod"
    roles:
      - role: steissier.docker_role 

  - name: "lancement container staging"
    vars:
      imgNameWebApp: "img_webapp"
      userName: "26021973"
      imgTag: "latest"
      exposePort: "8080"
    hosts: "prod"
    gather_facts: yes
    become: yes
    tasks:
      - name: "lancement postgres"
        docker_container:
          name: "postgres"
          image: "postgres:latest"
          ports:
            - "5432:5432"
          env:
            POSTGRES_USER: postgres
            POSTGRES_PASSWORD: postgres
            POSTGRES_DB: postgres

      - name: "recup container"
        docker_container:
          name: "webapp"
          image: "{{ userName }}/{{ imgNameWebApp }}:{{ imgTag }}"
          ports:
            - "8000:{{ exposePort }}"
          links:
            - postgres



For the docker-compose.yml file (which will be used for deployment), please see the file below and get inspiration from it

```
version: '3.3'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    expose:
      - "8000"
    ports:
      - "8000:8000"
    links:
      - postgres
  postgres:
    image: postgres:9
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
```      

## 3- Build

For build step you need to produce a Dockerfile to containerize application.
For this project we recommend you **python:3** for base image

## 4- Security

The security is an important aspect of this project, please make sure that you keep in mind security bests practises when you write script or any other action you made, because we will pay a special attention to that went we will review your work

## 5- Delivrable

At the end of the project you must provide us:
- A documentation of your work with screenshots
- A Powerpoint the present your work to the audience
- All your source through a documented GitHub repo

## 6- Have Fun

Feel free to add some extra steps, extra tools to make your pipeline more powerful (code analysis, so on and so forth)
We want you to enjoy yourself in this project and explore new possibility offers by the devops world

## 7- Author
This project was created par EAZYTraining, please do not share it, duplicate it ...
To contact us : contact@eazytraining.fr

LAST THING ...
![good luck](https://user-images.githubusercontent.com/18481009/84582398-cad38100-adeb-11ea-95e3-2a9d4c0d5437.gif)
