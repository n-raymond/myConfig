Notes
======

## Stocks NG

### Must have pour la MEP

#### Refactoring

* Rapatrier les cas métier de streaming-loader dans stock-ng

#### Dev

* API Go à refaire en scalatra
* Créer une API de test en scalatra (reprendre l'API haskell) => Ecrire des events dans kafka, et les envoyer sur la Gateway
* Finir la partie k8s

#### Fixes

* Cesser de croiser les données avec le référentiel magasin dans stock-movement-normalizer:
  - Supprimer la globale table
* Fixer les tests du processor (qui sont ignorés suite au tuning)

#### Test

* Tests du Processor (sans doute OK)
* Tests de l'API
* Tester une des branches de l'Adapter **/!\ VOIR AVEC THIERRY /!\**
* Tests e2e sur une version figée

### Moins prio

* Amélioration de la machine d'Etat
* Mieux gérer la gestion des erreurs dans Atto
* Refactoring du transformer (suite au tuning)


## Location

### Normalizer (nommé location-persister-offline):

#### General

Le JOB tourne toutes les heures

#### Lexique

* Weekpattern : pattern d'ouverture (Je suis ouvert de telle heure à telle heure pour tel jour)
  Calendar: Exceptions (Je vais être fermé pour tel jour ferier)
  LEX : Livraison Express
  
#### Architecture
  
* On a une class LocaltionPathSupport pour calculer tous les chemins de tous les fichiers dans lesquels on doit piocher

#### Fonctionnement

* On se sert des tags HDFS pour stocker les dernières inputs utilisées. 
  On s'en sert pour comparer les inputs de l'execution et savoir si elles sont identiques (auquel cas le job ne fait rien)
  
* On charge tous les fichier en mémoire (c'est tout petit)

* On groupes en général toutes les données par base magasin

* On construit une location pour chaque PVE_CODE (qui correspond au code Magasin dans Base mag):

#### Amélioration possibles

* Parser de CSV potentiellement à améliorer
* Utiliser des types taggés

## POC Confluent

### Access graphana

admin
prom-operator

### Steps to deploy (with API)

* Deployer kafka-lag-exporter dans un namespace dédié (`kafka-log-exporter`)
* Deployer la pipeline
* Envoyer les messages sur received files
  - Exporter données avec commande hive suivante :
    ```
    select
        value.received,
        value.receptionhost,
        value.created,
        value.filetype,
        value.path,
        value.compressioncodec,
        value.sourcetype,
        value.size
    from platform.received_files
    where
        year = 2019
        and month = 10
        and day >= 24
        and (value.filetype=‘F_ST_STOCKS_DAY.HYP_KRO_UG’ or value.filetype=‘F_ST_STOCKS_DAY.SUP_KRO_UG’)
        and value.received > ‘20191024T17’
        order by received
    ```
  - kubectl run -i --tty busybox --image=radial/busyboxplus:curl --restart=Never -- sh
  - (dans un autre terminal) kubectl cp Téléchargements/received-files-10012020 busybox:/home.received-files-10012020.csv
  - sed -i 's%\t%,%g' received-files-10012020
  - enlever les deux dernières lignes de warnings
  - kubectl exec -it cp-kafka-0 -c cp-kafka-broker -n kafka-rec kafka-console-consumer --topic received-files --bootstrap-server cp-kafka-headless.kafka-rec.svc.cluster.local:9092
    (pour suivre qu'on va bien obtenir des messages)
  - Depuis busybox `curl -v --data-binary @/home/received-files-21012020.csv testing-api.stocks-rec/received-files` où 10.23.152.102 correspond à l'ingress du service testing-api
* Deployer les dashboard sur grafana

### Steps to deploy (with received-files formatter)

* Deployer la pipeline
* Envoyer les messages sur received files
  - Exporter données avec commande hive suivante :
    ```
    select
        value.received,
        value.receptionhost,
        value.created,
        value.filetype,
        value.path,
        value.compressioncodec,
        value.sourcetype,
        value.size
    from platform.received_files
    where
        year = 2019
        and month = 10
        and day >= 24
        and (value.filetype=‘F_ST_STOCKS_DAY.HYP_KRO_UG’ or value.filetype=‘F_ST_STOCKS_DAY.SUP_KRO_UG’)
        and value.received > ‘20191024T17’
        order by received
    ```
  - kubectl cp Téléchargements/received-files-10012020 busybox:/home.received-files-10012020.csv
  - sed -i 's%\t%,%g' received-files-10012020
  - enlever les deux dernières lignes de warnings
  - transformer le fichier avec received-files-formatter (`sbt run`)
  - Avoir le fichier `properties.conf` suivant :
  ```
  ssl.endpoint.identification.algorithm=https
  sasl.mechanism=PLAIN
  request.timeout.ms=20000
  retry.backoff.ms=500
  sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="QEJ3VPFTHZWHNHCA" password="sQk8NX9ic3SEhuZr7w0F4pRnPjQ/h8Ue6T+lnChxZjmbJU5K2s9jeJ8heJ6EtRex";
  security.protocol=SASL_SSL
  ```
  - Envoyer le fichier `properties.conf` sur le pod de la registry : `kubectl cp properties.conf -n kafka-rec cp-schema-registry-645596bbd5-kdrrw:. -c server`
  - Envoyer le fichier json sur le pod de la registry : `kubectl cp received-files-19022020.json -n kafka-rec cp-schema-registry-645596bbd5-kdrrw:. -c server`
  - Lancer un consumer : `kubectl -n kafka-rec exec -it cp-schema-registry-645596bbd5-kdrrw -c server -- env JMX_PORT=1243 kafka-avro-console-consumer --bootstrap-server pkc-empy1.europe-west1.gcp.confluent.cloud:9092 --topic received-files --consumer.config properties.conf`
  - Lancer un producer :
    + Se connecter à la machine : `kubectl -n kafka-rec exec -it cp-schema-registry-645596bbd5-kdrrw -c server -- bash`
    + Lancer le producer : `env JMX_PORT=1244 kafka-avro-console-producer --broker-list pkc-empy1.europe-west1.gcp.confluent.cloud:9092 --topic received-files --producer.config properties.conf --property value.schema='{"doc":"Eventsentwhenwereceiveafileinthegateway-sftp","aliases":["com.carrefour.phenix.pipeline.v1.FileReceivedEvent"],"namespace":"com.carrefour.phenix.file.events","name":"FileReceivedEvent","type":"record","fields":[{"doc":"ISO8601receptiondatetime(inUTCTimeZone)","default":null,"name":"received","type":["null","string"]},{"doc":"receptionhost","default":null,"name":"receptionHost","type":["null","string"]},{"doc":"ISO8601file(generation)datetime(inUTCTimeZone)","default":null,"name":"created","type":["null","string"]},{"doc":"Filetypename","default":null,"name":"fileType","type":["null","string"]},{"doc":"FilePath","default":null,"name":"path","type":["null","string"]},{"doc":"FileCompression","default":null,"name":"compressionCodec","type":["null",{"symbols":["Zip","Gzip","TarGz","Bzip2","Snappy","None","Unknown","Other"],"aliases":["com.carrefour.phenix.pipeline.v1.CompressionCodec"],"name":"CompressionCodec","type":"enum"}]},{"doc":"generationsite","default":null,"name":"sourceType","type":["null",{"symbols":["SalesSite","CentralSite","LogisticsSite","Unknown","Other"],"aliases":["com.carrefour.phenix.pipeline.v1.SourceType"],"name":"SourceType","type":"enum"}]},{"doc":"generationsite","default":null,"name":"entity","type":["null",{"aliases":["com.carrefour.phenix.pipeline.v1.Entity"],"name":"Entity","type":"record","fields":[{"default":null,"name":"type","type":["null",{"symbols":["Store","Application","Warehouse","Other"],"aliases":["com.carrefour.phenix.pipeline.v1.EntityType"],"name":"EntityType","type":"enum"}]},{"default":null,"name":"subType","type":["null","string"]},{"default":null,"name":"keyType","type":["null","string"]},{"default":null,"name":"key","type":["null","string"]}]}]},{"doc":"filesizeinbytes","default":null,"name":"size","type":["null","long"]}]}' < received-files-19022020.json`

## Pour Redis

2/ Sharding
-> Voir pipelining: On attend pas pour emmetre la requête suivante
-> Voir consistent hashing + Client qui peut splitter la requête entre les noeuds
1/ On ne shard pas (tous les noeuds ont la donnée) => Mulitiget OK


## Besoin Carrefour en temps réel

* Problème de perfs et de disponibilité de la donné sur Stocks-API 
* Historique :
   - Les vielles routes (Pour les mouvements (100) et les levels (101) utilisé par Caroline (backoffice magasin)
   - 102 Cherche le dernier niveau connu et aggrège les mouvements plus récents pour avoir le niveau de stock en temps réel (à déprécier pour migrer vers la 116)
   - 103 pareil que la 102 mais pour connaître un niveau de stock à une heure précise dans le passé (Pas de réel usecase donc à déprécier sans remplacement)
   - 114 Stock Temps Réel d'un article pour tous les sites d'un format (hyper / super)
   - 115 Stock Temps Réel d'un article pour une sous partie des sites d'un format
   - 116 Stock Temps Réel par pair d'article magasin

   Vrai besoin => Donner le stock pour un article et une liste de magasins (Par exemple pour chercher un article dans tous les magasins à proximité)
               => Donner le stock pour un magasin et une liste d'article

114, 115, 116 pas suffisant. Raisons :
- On ne reçoit pas les fichiers eod tous les jours => Si on en reçoit pas pendant 2 jours pour un magasin, puisque la table est journalisée, on a plus de stock pour TOUT le magasin.
- Sujet bonus, incohérence sur la volumétrie en entrée entre les evenements et les eod
=> Pas efficace et à risque

## Transmission Phenix Stream API

### EventRecord.

Il faut trouver un autre moyen de trimbaler le rawvalue
Rawkey et Rawvalue surtout utilisé dans le discard. La notion de brut a du sens quand on normalise. Comment avoir un ADT qui descrimine le fait qu'on ou non sur du normalisé.
Un record contient des header. On a besoin des rawkey/value dans le cas ou on normalise (et on veut pouvoir discarder) mais pas dans le cas d'une topic normalisée.
Peut être un ADT.
Ne devrait pas être exposé car construction interne. Mais on l'expose dans l'api transform pour interragir avec le store. Il faudrait faire une surcouche au dessus de la processor API
En passant par les stores, les headers sont pommés.

### XStreamsBuilder

Problematics des Serdes:
- Devraient être demandées par l'API et non déclaré dans la lib : Un deserialiser pour rawkey et un pour rawvalue
- On a besoin que d'un deserialiser. Pas d'un serialiser (il est ici inutile).
- On peut utiliser les implicits pour générer automatiquement les constructions comme Consumed (en attendant les serializers et deserializers implicitements) => Le compilo travaille pour toi.

### Decoder

ADT pour exprimer les cas d'erreur (decodage de la clé, décodage de la valeur, ou les deux)

### XStream

Défaut : Il y a des cas où on n'a pas envie de pouvoir faire des deadletter
toRaw => Risque de péter si on est sur une topic normalisée
=> Peut être splitter XStream

Rajouter les méthodes qui manquent

### Pipeline

signatures de fonctions

### Deadletter

Voir si le fait de l'exposer offrirait plus d'avantage / d'expressivité


### Other

Simplifier l'archi pour avoir un interfaçage plus simple et intuitif

Essayer d'y aller step by step.



## Test de stock v2

* Ce qui a été testé :
  - Le loader eod. On a créé un fichier avec des données maitrisées qu'on a mis sur HDFS. On balance un receive file.
  - Adapter (Une seule des deux branches : Celle liée à eod)
  - Le processor en coupant l'adapteur et en envoyant des données dans la topic en entrée du processor pour regarder la sortie

* On a fait une API rest dans laquelle on envoit du CSV. Elle convertit en avro et envoit dans kafka. Plusieurs cas

TODO:
- A tester absolument => Processor et API

- Figer une version et tester avec
- Tester les autres composants unitairement
- Il faut que l'API REST soit aussi capable d'envoyer sur la gateway HTTP pour faire des tests bout en bout
- Objectif une minute au plus tard pour les message en bout dans la minute. Un peu plus long dans BigQuery
- Kafka connect redis à redémarrer
- API Go à refaire en scalatra classique
- Pour REDIS:
   + Fait un GET unique pour un couple article/magasin
   + Devrait faire un appel pour une liste article/magasin /!\ Si REDIS en cluster multi-get non trivial à cause des shards (pour partir en prod)
     => Workaround temporaire REDIS en non-cluster
        Il faut regarder le temps de reconstruction du REDIS. S'il est trop lent. Il faut mettre plusieurs instances de REDIS montées en parallèle et gérer le heathcheck de Kube pour le rediriger vers une seule instance à jour.

## Transmission Streaming Loader

- Déplacement des types A et B

* stock-store end of day:
   - On regarde le field type
   - Dans la conf on met une liste de field type pour pouvoir filter
   - On publie dans deux topics différents :
      -> Levels
      -> Message results (Donne le resultat d'execution) => Balancé dans BigQuery pour l'exploitation
   - Parsing fait avec Atto (TODO: Mieux gérer la gestion d'erreur)
   - Pistes d'amélioration pour exprimer la machine d'etat

## Transimission Stocks

* 2 Libs => Phenix Streams & Streaming Loader
* Des cas d'utilisation qui utilisent ces deux libs

### Dans stocks-ng
 * Stock-store (encore des parties dans phenix-streams à nettoyer quand OK)

 * Stock Mvm Normalizer:
 Pour requeter le sotck magasin on peut soit demander pour tous les magasins d'un certain type (hyp, sup). On a besoin d'une liste de magasin
      - La jointure ça marche mais il y a un probleme d'encodage
      - La globale table n'a peut être pas d'interet (peut être pas d'interet de croiser avec le referentiel magasin)
      - Validation de la longueur de la clé

 * Stock Mvm Adapter:
    - L'adapter prend le flux normalizé et le flux des eod
    - Deux topologies
        + Prend les Stock levels et sort des stock events
        + Prend les mouvements et sort des stock events
    - Permet de figer l'ordre pour l'unification

 * stock level:
    - Fait le calcul (Pas mal charcuté pour des problèmes de perfs)
    - Utilise des fenêtre (Attention aux messages provenant du futur) => Filtre au préalable les messages qui proviennent du futur (et du passé). Tolérance future de 10 min
    - Validation des clés plus utiles car fait dans le normalizer. Vérifier que c'est bien fait dans les levels
    - 2 types de stores :
        + Un qui garde tous les lvls (l'etat)
        + Un store fenêtré qui garde tous les mouvements (pour la déduplication et le scan)
    - Transformer:
        + Le pire en perf c'est de faire parcourir des range de clés
         => On maintient la date du dernier état calculé, du dernier mouvement calculé pour pouvoir les comparer
            On essaye dès que possible d'éliminer les cas qu'on ne doit pas traiter
        + Dépendence au temps : Pas de possibilité de rejouer
        + Les messages dans le futur devraient être gérés dans le normalizer au lieu du processeur de levels temps réel


TODO:
- Rappatrier les cas métier de streaming-loader dans stock-ng
- Fixer les tests du processor stock level (il faut injecter le temps)
- Finir la partie k8s

Kafka Suppress => Reduire le nombre d'event en sortie au prix de buffer qui grossissent

## Dette technique stocks v1

### StockMovementNormalizer

* Specification: Specifier ce que tu veux pour un flux d'entrée. Pour chaque message on effectue un traitement
* LIbrary of schema = cache de schema
* On reçoit dans la meme topic les mouvement et les levels => On les separe dans 2 topicso

Levels
======
* Normalisation
* Filtre
* Transform

Movements
======
* Normalisation
* Filtre

- Validation des dates : Signature non explicite
- Peu de validations
- Try inutiles
- 2 specification : Chaque message traité 2 fois.
- Jodatime
- Manière de checker stockLevel (cas non traités car pas seulement 0)

### Stocks Levels Persisters

* Créer la table si besoin (avec les bon droits)
* Chercher les éléments pour écrire dans la clé ou le bon shard
* Parsister dans Cassandra

- Le job ne peut fonctionner que deux mois d'affilé
- Pas de validation avant d'envoyer dans Cassandra (peut une clé nulle)
- Filtre sans feedback ou metrics
- Redondances entre des processors
- Problème sur le schema

### Site Stocks Normalizer

* Deserialization du store
* Gestion un peu plus fine pour différentier les stock levels et stock movement

(-) Desavantage par rapport à Spark Streaming : Notion de reseau entre les noeuds spark et les repository server

- Creation de clé sans validation
- Croisement avec un référentiel dans un normalizer
- Micro batching en Spark: Overhead en début de fenêtre car toutes les batch windows sont déclanchées en même temps et les répository servers interrogés en même temps
- Filtre de traitement d'erreur silentieux sans discard !

### Site Stocks Persister

=> Besoin de réduire le nombre de lectures cassandra pour lire en une requete les levels et les movements
   Tables au jour => Si dans la journée on n'a pas de level on est cuit
                  => Fin de journée = lent

* Fait des tables à la journée ou pour le lendemain
* Besoin du level du soir sinon c'est mort

### Stocks API

* Demande de la dernière position pour un site et un produit

- Plusieurs route et version qui poluent l'executables
- Validation faite sans avoir deserialisé
- Pas de validation à certains endroits
- Service qui gère tous les use cases (y compris ceux qui devraient être décommissionés)
- Beaucoup de duplication de code pour un même usecase global (paramétriser en fonction des magasins)

### ATP

Stocks magasins et sotcks entrepots mélangés dans les mêmes tables cassandra => Tout le stockage couplé => Problèmes de perf


## Exposition View

Le fait que c'est un énième Framework Phenix qui force à utiliser un grand nombre de dépendances, ce qui rend les montées de versions difficiles
• Ça ne répond pas au principe des séparations des responsabilité car ça fait tout en même temps (montée de migration des schemas, validation des schemas, conversions d'avro et orc, création de tables hive).
On devrait plutôt séparer ces différentes étapes dans des petits programmes (par exemple une étape pour la conversion en ORC, puis une autre pour mettre à jour la table hive)
• La modélisation du framework est peu modulaire et cloisonne à des cas d'utilisation spécifiques et parfois/souvent non désiré. Ça mène à beaucoup d'over-engineering, par exemple :
  - Ça force à utiliser Spark même dans les cas où on en a pas besoin (petite volumétrie) en raison du fort couplage
  - Quand on utilise Spark, on est forcé d'utiliser des dataframes => On perd la notion de typage et le contrôle sur la donnée
• Ça fait aussi des comparaisons de schemas à runtime (avec de la réflexion il me semble) alors qu'on devrait plutôt se servir des garanties qu'on pourrait avoir à compile-time sur le model de données en ayant un schema fixé pour une version de l'application.
• Il me semble qu'il y a des parties du code qui me paraissent immaintenable (je parle notamment de requêtes SQL de plusieurs dizaines de lignes)
• Il y a du code scala dans les configurations (pas de garanties sur le fonctionnement à compile-time)


## Avantage de XStream

 Le fait de gérer la stratégie de discard à un endroit unique
 • Le fait d'utiliser les headers kafka
 Concernant les headers kafka pour les métadata, je vois comme avantage :
 • Le fait de ne pas avoir à modifier nécessairement les schemas des values :
    - Mélange données fonctionnelles et techniques qui me semblent peut clair et n'intéresse pas le client
    - Impactes sur les perfs car overhead au niveau du parsing à chaque fois qu'on doit exploiter la donnée sans avoir besoin d'utiliser les headers
 • Le fait de ne pas avoir un schéma comme PipelineKey pour stocker les métadata dans les clefs :
    - Rend impossible le fait de faire de la compaction (du fait qu'on ne peut pas réellement exploiter les fonctionnalités de partitionement de kafka)

## Graphana access

admin
prom-operator

# 27/09/19


## Metriques

### Métriques Kafka / Kafka Streams

(Regarder dans store-sock-level-processor)

Tache JMX a démarrer pour exporter les metriques Prometheus. Directement un agent dans la JVM (depuis le .ini)

Déjà fournis par Kafka Streams (Rate / Latence)
 - Message / s par topic
 - Process Rate => Permet de voir à quelle vitesse le stream va
 - Join Rate => Combien de consumers rentrent dans le consumer groupe
 - Lags (en offset) => Est-ce que mon lag est constant est faible ou est-ce qu'il augmente

Pour un job de streaming, il faut regarder à quelle vitesse il traite, si il a du lag et avoir des infos sur les états.

Alerting:
- Trop de join rate
- Process rate
- Lags
- Taille de l'état

Dans un premier temps ne pas créer ses propres métriques

Potentiellement le même dashboard par processor (en se servant de variables comme le namespace, tags k8s)

Metriques Kubernetes

### Dashboard

* Graphana dans k8s
* Il faut créer des dashboard depuis graphana et exporter sous la forme d'un json







# 12/06/19

## Access GCP registry

gcloud container images list --repository=eu.gcr.io/vg1np-pf-phenix-caas-1a

# 07/05/19

## Réunion Phenix Streams

Appli Kafka Stream = Docker Java

Lire le Stock Normalizer

Utilisation de schemas avro => Lib de serde du schema registry de confluence
Potentiellement PLusieurs schema intermediaires
Besoin d'une connection au schema registry => foncition registerCustomSerializers
On définit une pipeline. On créé un flot de controle. Il n'est pas executé de suite
XStreamBuilder est un wrapper au dessus du StreamBuilder classique qui permet de gérer les headers
On va lire le brute en utilisant xStreamBuilder.rawStream avec un décodeur raw
Un décodeur prend un rawKey, un rawValue et donne les headers Kafka



# 04/05/19

## Déploiement phenix streams

Déploiement déclaratif : Je déploie ce que je veux et Kubernetes va faire converger

2 Types de resources:
- De base kubernetes
- Custome

Stateful Set ?
- Problème manque de contexte si on modifie la conf
=> Préférer les opérators

kustomize build overlays/production | kubectl apply -f -

Regarder customize
Bien lire la doc kubernetes





# 10/04/09

Presharedkey VPN: %CarrefourRASKey2018%

# 15/03/09

Hi @mazeboard,

I understand the goal of this module (to give you a simpler way to convert java avro POJO in case classes) and I like the idea since we don't actually have a working tool to do this. However, I don't understand a few things:

* Some of our teammates are currently working on a subject to use a library to compile avro schemas directly to case class instead of compiling it to java plain old objects. Isn't your approach redundant with their work ?

* Are you sure doing reflexion is the good way to achieve this goal ? I think we should really be careful using it since it is well know to be error prone (it removes you the ability to have compile time garanties). For exemple, I see a few things that should draw your attention:

   - By doing reflexion, no compile-time typechecking is done to check that the arguments (token from the given SpecificAvroRecord) really fit to the constructor of your case class.

   - After using the module in some code, if you update the schema of your record and forget to update the case class, you will not get compile-time warnings. This case can be applied in the opposite direction if your case class is updated without updating the record schema.

   - If this module is used a lot, and if you update it, you risk to introduce runtime errors at each call of your implicitly declared `load` functions.

Given those facts, don't you think the case-class generation at compile-time approach using the avro-schema should be a better way?


# 15/02/19

Lorsqu'on met à jour un schema dans un normalizer, il faut mettre à jour la conf dans
application-deployement/curator-exposition-view/templates/application.conf.j2



# 06/02/2019

## List kafka topics in UAT

/opt/kafka/bin/kafka-topics.sh --list --zookeeper master3.uat.phenix.fr.carrefour.com:2181,master2.uat.phenix.fr.carrefour.com:2181,master1.uat.phenix.fr.carrefour.com:2181/kafka


# 24/01/2019

## infolog-normalizer installation

https://phenix-rundeck.edc.carrefour.com/project/Phenix-UAT/job/show/be34de42-95a2-4017-a8ea-da124cecc757?retryExecId=72880
https://phenix-rundeck.edc.carrefour.com/project/Phenix-UAT/execution/show/72883#summary


# 03/12/2018

## Registry credentials

user: phenix_registry_dev
pass: adamApple07



# 06/11/2018

## Solve wrights problem in carrefour-sbt

USER_NAME_OVERRIDE=hdfs carrefour-sbt

# 07/11/2018

## MEP ticket template

+*MEP pre requirement:*+
||Status||Tasks||
|(x)|Release 'component'|
|(/)|Release 'component'|

*+MEP first requirement:+*
||Tasks||
|merge application deployement branch {link}|

+*Deployment steps:*+
||Step||Component||Playbook||Args ansible||Pilot Deployment Validation||
| 1 | | | | |

+*Verifications:*+
* PHX-XXXX:
** changes:
*** desc
** Checks:
*** the deployed version of *component* matches the specification
**** yum info referential-persister-offline
*** the deployed version of the api *apiName*
**** call the *\{host}/apiName/build-info* route and check that the field version is set to the specified 'api version'

# 05/10/2018

## ByPass Nexus and Jenkins

* Create .rpm locally
* scp .rpm
* yum remove
* yum -ivh

# 08/10/2018

## Tlogs-normalizer: listening topic kafka with avro to json conversion

* Connect to offline2 with ssh
* Look version of schema transaction
* /usr/share/kafka-formatter/pipeline-consumer.sh --topic transactions_00 --formatter com.carrefour.phenix.tools.kafka.AvroFormatter --property schema=‘a9591fb6-dd6b-3632-0000-000000000000’


# 31/08/2018

## Cases PR :

- [ ] book and/or swagger has been updated
- [ ] the dependant PR [`short name`]() has been merged
- [ ] phenix-development.properties has been removed
- [ ] all dependencies has been set to RC or stable if possible (last update: )
- [ ] all phenix sbt plugins has been set to the latest stable possible (last update: )
- [ ] all docker images dependencies has been set to the latest version possible (last update: )
- [ ] rebased on develop (last: )
- [ ] the following PR [`short name`]() successfully ran on jenkins with the last update of this PR
- [ ] ready for merge

## Cases PR Lyon :

- [ ] book and/or swagger has been updated
- [ ] all PR comments have been taken into account including the unrightfully collapsed ones
- [ ] the dependant PR [`short name`]() has been merged
- [ ] phenix-development.properties has been removed
- [ ] all dependencies has been set to RC or stable if possible (last update: )
- [ ] all phenix sbt plugins has been set to the latest stable possible (last update: )
- [ ] all docker images dependencies has been set to the latest version possible (last update: )
- [ ] rebased on develop (last: )
- [ ] the git history is clear and contain only commits from this branch
- [ ] the following PR [`short name`]() succesffully ran on jenkins with the last update of this PR
- [ ] ready for merge

# 21/08/2018

## Release candidate (RC)

* Use job ADMIN-release-sbt in Jenkins
* Go in `Build with parameters`
* Select project, branch, RC, and default

## Deploy an api

* Use marathon (web-ui above mesos)



# 02/08/2018

## Environment configurations

* On each environment, you can find the software configuration files in the directory `/etc/phenix/`.
* This file are referenced or include from sourced configuration files


## Other

* The schema manager does not exist anymore in UAT. Confs should use PROD schema manager !


---

# 30/07/18

## Azkaban Access

* login: azkaban
* mdp uat: DEacTduBa11onA23%
* mdp pilot: PIacTduBa11onA23%


## Operations to use debug mode in intellIJ

* Use version 4 of scala-build image in Dockerfile
* Set fork in IntegrationTest to false
* Bind port 5005 to 5005 in docker-compose file to connect debugger inside of it
* Run sbt-remote


## Code that needs cleaning

* StoreMetiDrvEngineIT
    - hadoopConf variable is useless

* ProductStructSupsSpec (parser)
    - Success must be replaced by Try

* Fixture in IT (persister-offline)
    - Each fixture is declared as a val ===> Eager : 2/3 seconds of useless loading per each class ===> Could be lazy value or def to load only desired models


## Study to know if a refactor is necessary in Jobs (some code could/should be factorized)

* CityEngineJob
    - sendNotification is a duplication

* CustomerRefBaseEngineJob
    - sendNotification is a duplication

* PickupPointEngineJob
    - Override of parseAndSave function is useless
    - Save is a duplication
    - sendNotification is a duplication

* ProductLotEngineJob
    - Save is a duplication
    - sendNotification is a duplication

* ProductStrBuEngineJob
    - Save is a duplication
    - sendNotification is a duplication

* ProductVlEngineJob
    - Save is a duplication
    - sendNotification is a duplication

* SiteServicesEngineJob
    - sendNotification is a duplication

* StoreEngineJob
    - sendNotification is a duplication

* StoreMetiDrvEngineJob
    - Save is a duplication
    - sendNotification is a duplication

* SupplierEngineJob
    - sendNotification is a duplication

* SupplierWarehouseEngineJob
    - sendNotification is a duplication

* WarehouseEngineJob
    - sendNotification is a duplication

==> A refactorization of the code may be considered !

