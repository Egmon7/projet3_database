-- ============================================================
-- Kadea Chat — database.sql
-- Phase 5 : création de la base et des tables
-- PostgreSQL
-- ============================================================

-- 1. Création de la base
-- Exécuter cette ligne séparément dans pgAdmin (Query Tool connecté à postgres),
-- puis se connecter à la base kadea_chat avant d'exécuter le reste.
CREATE DATABASE kadea_chat;

-- ============================================================
-- 2. Tables (ordre : sans FK d'abord, puis tables dépendantes)
-- ============================================================

-- Table users (côté 1)
CREATE TABLE users (
    id          SERIAL PRIMARY KEY,
    full_name   VARCHAR(150) NOT NULL,
    email       VARCHAR(255) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    avatar_url  TEXT,
    bio         TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table conversations (côté 1)
CREATE TABLE conversations (
    id          SERIAL PRIMARY KEY,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table conversation_members (jointure N:N + lu/non lu)
CREATE TABLE conversation_members (
    id               SERIAL PRIMARY KEY,
    conversation_id  INT NOT NULL,
    user_id          INT NOT NULL,
    joined_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_read_at     TIMESTAMPTZ,
    CONSTRAINT fk_cm_conversation
        FOREIGN KEY (conversation_id) REFERENCES conversations(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_cm_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE,
    CONSTRAINT uq_cm_conversation_user
        UNIQUE (conversation_id, user_id)
);

-- Table messages (côté N — cède les FK)
CREATE TABLE messages (
    id               SERIAL PRIMARY KEY,
    conversation_id  INT NOT NULL,
    sender_id        INT NOT NULL,
    content          TEXT NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ,
    CONSTRAINT fk_messages_conversation
        FOREIGN KEY (conversation_id) REFERENCES conversations(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_messages_sender
        FOREIGN KEY (sender_id) REFERENCES users(id)
        ON DELETE CASCADE
);

-- ============================================================
-- Fin Phase 5 — structure créée (tables vides)
-- ============================================================

-- ============================================================
-- Phase 6 : données de test réalistes
-- Ordre : users → conversations → conversation_members → messages
-- ============================================================

-- 6.1 Utilisateurs (6)
INSERT INTO users (full_name, email, password, avatar_url, bio) VALUES
('Egmon7',        'egmonegmon340@gmail.com', '$2b$10$exemplehash231', 'https://res.cloudinary.com/demo/image/upload/egmon.jpg', 'Apprenant Kadea — fullstack'),
('Jack Mulonda',  'jack@gmail.com',          '$2b$10$exemplehash542', 'https://res.cloudinary.com/demo/image/upload/jack.jpg', 'Dev en formation à Kadeat'),
('Josephine',     'josephine@gmail.com',     '$2b$10$exemplehash533', NULL, 'Dev en formation à Kadea'),
('David Mbiya',   'david@gmail.com',         '$2b$10$exemplehash948', 'https://res.cloudinary.com/demo/image/upload/david.jpg', 'UI / UX et frontend'),
('Fidele Kas',    'fidele@gmail.com',        '$2b$10$exemplehash112', NULL, 'Backend et bases de données'),
('Elie Ngoy',     'elie@gmail.com',          '$2b$10$exemplehash642', 'https://res.cloudinary.com/demo/image/upload/elie.jpg', NULL);

-- 6.2 Conversations (4)
INSERT INTO conversations DEFAULT VALUES; -- id 1 : Egmon ↔ Jack
INSERT INTO conversations DEFAULT VALUES; -- id 2 : Egmon ↔ Josephine
INSERT INTO conversations DEFAULT VALUES; -- id 3 : Jack ↔ David
INSERT INTO conversations DEFAULT VALUES; -- id 4 : David ↔ Fidele

-- 6.3 Participants — d'abord sans last_read_at (personne n'a encore de messages à lire)
INSERT INTO conversation_members (conversation_id, user_id) VALUES
(1, 1), (1, 2),   -- Conv 1 : Egmon ↔ Jack
(2, 1), (2, 3),   -- Conv 2 : Egmon ↔ Josephine
(3, 2), (3, 4),   -- Conv 3 : Jack ↔ David
(4, 4), (4, 5);   -- Conv 4 : David ↔ Fidele

-- 6.4 Messages — created_at automatique (DEFAULT NOW())
-- Conversation 1 : Egmon ↔ Jack
INSERT INTO messages (conversation_id, sender_id, content) VALUES
(1, 1, 'Salut Jack, tu as avancé sur le projet chat ?'),
(1, 2, 'Oui Egmon, j''ai fini la sidebar ce matin.'),
(1, 1, 'Super ! Tu peux m''envoyer une capture ?'),
(1, 2, 'https://res.cloudinary.com/demo/image/upload/sidebar-chat.png'),
(1, 1, 'Parfait, on se voit en cours alors.'),
(1, 2, 'Ok, à tout à l''heure !');

-- Conversation 2 : Egmon ↔ Josephine
INSERT INTO messages (conversation_id, sender_id, content) VALUES
(2, 3, 'Egmon, tu peux m''aider sur PostgreSQL ?'),
(2, 1, 'Bien sûr Josephine. Tu bloques sur quoi ?'),
(2, 3, 'Les clés étrangères et le ON DELETE CASCADE.'),
(2, 1, 'CASCADE supprime les lignes enfants avec le parent.'),
(2, 3, 'Merci, c''est plus clair maintenant.'),
(2, 1, 'https://res.cloudinary.com/demo/image/upload/schema-mld.png'),
(2, 3, 'Top, je recopie ça dans Draw.io.');

-- Conversation 3 : Jack ↔ David
INSERT INTO messages (conversation_id, sender_id, content) VALUES
(3, 2, 'David, tu travailles sur le design du chat ?'),
(3, 4, 'Oui, je peaufine les bulles de messages.'),
(3, 2, 'Tu peux partager ta maquette ?'),
(3, 4, 'https://res.cloudinary.com/demo/image/upload/maquette-chat.png'),
(3, 2, 'Merci David, très propre comme design !');

-- Conversation 4 : David ↔ Fidele
INSERT INTO messages (conversation_id, sender_id, content) VALUES
(4, 5, 'David, on se répartit le README et le SQL ?'),
(4, 4, 'Oui Fidele. Je prends le README, tu prends les requêtes.'),
(4, 5, 'Deal. Je commence les JOIN ce soir.'),
(4, 4, 'Parfait, on valide demain en classe.');

-- Message modifié (updated_at renseigné après coup)
UPDATE messages SET update_at = NOW()
WHERE conversation_id = 3
  AND sender_id = 2
  AND content = 'Kitoko mon cher!';

-- 6.5 Simulation lu / non lu — APRÈS les messages (NOW() = moment où l'user ouvre le chat)
-- Conv 1 : Egmon a lu, Jack non lu (last_read_at reste NULL)
UPDATE conversation_members SET last_read_at = NOW()
WHERE conversation_id = 1 AND user_id = 1;

-- Conv 2 : Egmon et Josephine ont lu
UPDATE conversation_members SET last_read_at = NOW()
WHERE conversation_id = 2 AND user_id IN (1, 3);

-- Conv 3 : Jack a lu, David non lu
UPDATE conversation_members SET last_read_at = NOW()
WHERE conversation_id = 3 AND user_id = 2;

-- Conv 4 : David et Fidele ont lu
UPDATE conversation_members SET last_read_at = NOW()
WHERE conversation_id = 4 AND user_id IN (4, 5);

-- ============================================================
-- Fin Phase 6 — données de test
-- Phase 7 : requêtes SQL de validation
-- ============================================================
