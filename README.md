# Backend de DataPass

Les instructions d’installation globale (via VMs / vagrant) se trouvent ici : https://github.com/betagouv/datapass

Pour le développement en local, suivez les instructions ci-dessous:

## Dépendances

* ruby 2.7.3
* postgresql 9.5

## Installation

```sh
bundle install
psql -f db/setup.local.sql
rails db:schema:load
```
