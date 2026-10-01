# Kadea Chat — Base de données

## Présentation

**Kadea Chat** est une application de messagerie destinée aux apprenants de Kadea.  
Après le développement du frontend, ce livrable met en place la **couche données** en PostgreSQL.

La base stocke les utilisateurs, les conversations, les participations et les messages.  
Elle est conçue pour être exploitable par un futur backend (API REST) qui connectera :

```
Frontend Kadea Chat  →  API Backend  →  PostgreSQL
```

Choix principaux :
- pas de type « privé / groupe » : une conversation flexible via une table de liaison ;
- état **lu / non lu** via `last_read_at` (comportement de la sidebar) ;
- respect de la **3e forme normale (3FN)**.

---

## Technologies

- **PostgreSQL** — système de gestion de base de données
- **pgAdmin** — administration et exécution des requêtes
- **Draw.io** — dictionnaire de données, MCD et MLD
- **SQL** — script de création, données de test et requêtes

---

## Modélisation

### Entités / tables

| Table | Rôle |
|-------|------|
| `users` | Comptes utilisateurs (profil, auth) |
| `conversations` | Fils de discussion |
| `conversation_members` | Qui participe à quelle conversation + lu/non lu |
| `messages` | Contenu échangé (texte ou URL d’image) |

### Relations

| Relation | Type | Traduction |
|----------|------|------------|
| USER ↔ CONVERSATION (PARTICIPE) | **N:N** | table `conversation_members` |
| USER → MESSAGE (ENVOIE) | **1:N** | FK `messages.sender_id` |
| CONVERSATION → MESSAGE (CONTIENT) | **1:N** | FK `messages.conversation_id` |

En 1:N, le côté **N** porte la clé étrangère.  
En N:N, une table de jointure porte les deux FK, avec `UNIQUE (conversation_id, user_id)`.

Le fichier Draw.io contient 3 onglets : **Dictionnaire de données**, **MCD**, **MLD**.  


---

## Installation

### Prérequis

- PostgreSQL installé
- pgAdmin (ou `psql`)

### Étapes

1. Ouvrir pgAdmin et se connecter au serveur PostgreSQL.
2. Ouvrir un **Query Tool** sur la base `postgres`.
3. Exécuter la création de la base :
   ```sql
   CREATE DATABASE kadea_chat;
   ```
4. Se connecter à la base **`kadea_chat`**.
5. Ouvrir le fichier `database.sql` et exécuter :
   - les `CREATE TABLE` (structure) ;
   - les `INSERT` (données de test) ;
6. Vérifier dans pgAdmin : **Databases → kadea_chat → Schemas → public → Tables**.



## Auteur

Prospere Engeba — projet Kadea 
