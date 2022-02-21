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
  - Docker-composer en dernière version
  - Snyk CLI en dernière version

Environnement Ansible 
- 1 serveur Ansible 


## Connectivité 

Accès ssh :
- Serveur Ansible vers les serveurs de production et de staging avec un login faisant parti du groupe root
- l'agent Jenkins doit pourvoir accéder au serveur Ansible en ssh avec un login faisant parti du groupe root

Tous les serveurs cités doivent avoir un accès internet (accès github et dockerHub)



## Jenkins : Variables d'environnement

```
  ansibleServer = "" // Serveur Ansible
  stagingServer = "" // IP Serveur d'un des serveur de staging 
  prodServer = "" // IP d'un des serveur de production
  homeDirAnsible = "ansible_deploy" // répertoire 
  USERNAME = "" // Nom de votre user dockerHub
  REPO_GIT = "https://github.com/steissier/devops-project3.git" // Repository GIT 
  IMG_NAME_WEBAPP = "img_webapp" // Nom de l'image qui sera poussée sur le dockerHub
  CONTAINTER_NAME_WEB = "webapp" // Nom du conteneur pour la webapp
```

Il existe d'autre variable (Ex : Port) qu'il n'est pas souhaitable de modifier.

## Jenkins : dépendance
Vous devez installer le plugin Global Slack Notifier et réaliser les paramétrages indiqués pour que les status de déploiement soient publiés automatiquement dans votre canal slack

## Jenkins : Crédentials
Veuillez creer les secrets key (credentials) suivants dans Jenkins :
ID : slack pour stocker votre key slacl
ID : dockerhubPswd pour stoker votre password de votre compte docker hub
ID : snykKey pour stocker votre Key snyk.

## Ansible

Dépendance :
Vous devez installer le role pour installer les dépendances Docker pour Ansile
```
ansible-galaxy install steissier.docker_role
```

Voici les exemples de playbook que vous devez déployer sur votre serveur Ansible.

Vous trouverez un exemple fonctionnel dans cette repo GitHub :
https://github.com/steissier/deploy_webapp_ansible.git

3 fichiers :
Un fichier hosts.yml : faisant l'inventaire de vos environnements
``` 
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
          ansible_host: "" // Déclarez ici votre environnement de staging
    master:
      vars:
        ansible_connection: local
        ansible_user: "ubuntu"
      hosts:
        AnsibleMaster:
          ansible_host: "localhost
``` 

Un fichier main_prod.yml
``` 
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
``` 

Un fichier main_staging.yml
```
- name: "Installation Docker"
  gather_facts: yes
  become: yes
  hosts: "staging"
  roles:
    - role: steissier.docker_role

- name: "lancement container staging"
  vars:
    imgNameWebApp: "img_webapp"
    userName: "26021973"
    imgTag: "latest"
    exposePort: "8080"
  hosts: "staging"
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
```

Ces trois fichiers doivent etre déposés dans un sous répertoire du home du user ssh qui assure la connectivité entre l'agent Jenkins (ie agent1) et le serveur Ansible. 
Le nom part défault du répertoire est "ansible_deploy". Vous pouvez le modifier via la variable d'environnement homeDirAnsible

## Lancement
Lorsque vous avez réalisé toutes les opérations vous pouvez configurer votre nouvel item de type pipeline dans jenkins.


## 7- Author
Ce projet a été créer par Sébastien Teissier dans le cadre de sa formation

