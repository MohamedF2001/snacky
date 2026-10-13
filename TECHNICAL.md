# Snacky - Documentation Technique & Spécifications API / Technical Documentation & API Specs

---

## Sommaire / Table of Contents

1. [Présentation Générale / Executive Summary](#1-présentation-générale--executive-summary)
2. [Architecture du Projet / Project Architecture](#2-architecture-du-projet--project-architecture)
3. [Détail des Modules & Fonctionnalités / Feature & Module Breakdown](#3-détail-des-modules--fonctionnalités--feature--module-breakdown)
   - [Auth / Authentification](#auth--authentification)
   - [Categories / Catégories](#categories--catégories)
   - [Products / Produits](#products--produits)
   - [Orders / Commandes](#orders--commandes)
   - [Promotions](#promotions)
   - [Dashboard / Tableau de Bord](#dashboard--tableau-de-bord)
   - [Virtual 360° / Visite Virtuelle](#virtual-360--visite-virtuelle)
4. [Spécifications Backend & API (`snackyApi`) / Backend & API Specs (`snackyApi`)](#4-spécifications-backend--api-snackyapi--backend--api-specs-snackyapi)
   - [Configuration & URL de Base / Configuration & Base URL](#configuration--url-de-base--configuration--base-url)
   - [Endpoints API / API Endpoints](#endpoints-api--api-endpoints)
   - [Formats des Données & DTOs / Data Formats & DTOs](#formats-des-données--dtos--data-formats--dtos)
5. [Gestion d'État & Navigation / State Management & Routing](#5-gestion-détat--navigation--state-management--routing)
6. [Réseau & Gestion des Erreurs / Network & Error Handling](#6-réseau--gestion-des-erreurs--network--error-handling)
7. [Design System, Thème & Ressources / Design System, Theme & Assets](#7-design-system-thème--ressources--design-system-theme--assets)
8. [Guide de Migration vers Next.js & Équivalences / Next.js Migration Guide & Equivalences](#8-guide-de-migration-vers-nextjs--équivalences--nextjs-migration-guide--equivalences)

---

## 1. Présentation Générale / Executive Summary

### 🇫🇷 Français
**Snacky** est une application multiplateforme de gestion et de commande de restauration rapide (Fast Food), initialement développée avec **Flutter**. Elle intègre un système d'administration complet (Tableau de bord, gestion du catalogue, commandes, promotions) ainsi qu'une expérience d'immersion virtuelle en 360° pour la présentation de locaux ou de restaurants.

L'application communique avec l'API Backend **`snackyApi`** (Node.js / Express / MongoDB / Cloudinary) hébergée sur [snacky-api.vercel.app](https://snacky-api.vercel.app/) et disponible sur GitHub à l'adresse [https://github.com/MohamedF2001/snackyApi](https://github.com/MohamedF2001/snackyApi).

L'objectif principal de ce document est de fournir une cartographie technique exhaustive de l'application Flutter et de son Backend afin d'en faciliter la réécriture, la génération de code, la migration ou la réimplémentation avec d'autres technologies web modernes comme **Next.js**.

### 🇬🇧 English
**Snacky** is a cross-platform fast-food management and ordering application initially built with **Flutter**. It features a comprehensive administration system (Dashboard, catalogue management, orders, promotions) alongside an immersive 360° virtual tour experience for showcasing restaurant premises.

The app interfaces with the **`snackyApi`** backend (Node.js / Express / MongoDB / Cloudinary) deployed at [snacky-api.vercel.app](https://snacky-api.vercel.app/) and hosted on GitHub at [https://github.com/MohamedF2001/snackyApi](https://github.com/MohamedF2001/snackyApi).

The main purpose of this document is to provide an exhaustive technical mapping of both the Flutter application and its connected backend API to streamline project generation, re-engineering, migration, or re-implementation using modern web frameworks such as **Next.js**.

---

## 2. Architecture du Projet / Project Architecture

### 🇫🇷 Français
Le projet Flutter respecte les principes de la **Clean Architecture** modulée par fonctionnalité (*Feature-driven Architecture*). Chaque module métier est isolé et découpé en trois couches distinctes :

1. **Data Layer** : Modèles de données (`models`), sources de données distantes/locales (`datasources`), implémentation des répertoires (`repositories`) et cartographes de données (`mappers`).
2. **Domain Layer** : Entités purement métier (`entities`), contrats d'interfaces (`repositories`) et cas d'utilisation (`usecases`).
3. **Presentation Layer** : Interface utilisateur (`views`, `widgets`) et gestionnaires d'état (`providers` avec Flutter Riverpod).

#### Structure des Répertoires
```
lib/
├── app.dart                   # Configuration GoRouter, AuthGuard & FastFoodApp root
├── main.dart                  # Point d'entrée principal (ProviderScope)
├── home.dart                  # Page d'accueil / Navigation principale
├── hero_banner.dart           # Bannière promotionnelle
├── virtual.dart               # Module de visite virtuelle 360° (Panorama / Cardboard VR)
├── const/                     # Design System (Couleurs, Styles, Thèmes, Typographie)
│   ├── app_colors.dart
│   ├── app_input_style.dart
│   ├── app_style.dart
│   └── app_theme.dart
├── core/                      # Services partagés et utilitaires fondamentaux
│   ├── config/                # Configuration globale (ex: URL API)
│   ├── error/                 # Gestion globale des échecs (Failures & Freezed)
│   ├── network/               # Client HTTP Dio pré-configuré
│   └── utils/                 # Helpers / Debug tools
└── features/                  # Modules métiers (Clean Architecture)
    ├── auth/                  # Authentification utilisateur & session
    ├── categories/            # Gestion des catégories de produits
    ├── dashboard/             # Statistiques et métriques admin
    ├── orders/                # Gestion & suivi des commandes
    ├── products/              # Gestion du catalogue de produits
    └── promotions/            # Gestion des offres promotionnelles
```

### 🇬🇧 English
The Flutter project adheres to **Clean Architecture** principles structured in a **Feature-driven** format. Every business module is decoupled and segregated into three distinct layers:

1. **Data Layer**: Data transfer objects (`models`), remote/local data sources (`datasources`), repository implementations (`repositories`), and data mappers (`mappers`).
2. **Domain Layer**: Pure business entities (`entities`), repository interfaces (`repositories`), and use cases (`usecases`).
3. **Presentation Layer**: UI components (`views`, `widgets`) and state controllers (`providers` using Flutter Riverpod).

#### Directory Map
```
lib/
├── app.dart                   # GoRouter configuration, Auth Guard & FastFoodApp root widget
├── main.dart                  # Main entry point wrapping ProviderScope
├── home.dart                  # Home page / Main navigation shell
├── hero_banner.dart           # Hero promotional banner component
├── virtual.dart               # 360° Virtual tour module (Panorama / Cardboard VR)
├── const/                     # Design System (Colors, Text Styles, Theme, Typography)
│   ├── app_colors.dart
│   ├── app_input_style.dart
│   ├── app_style.dart
│   └── app_theme.dart
├── core/                      # Shared infrastructure & core utilities
│   ├── config/                # Global configuration (e.g. API Base URLs)
│   ├── error/                 # Global error models (Failures & Freezed)
│   ├── network/               # Pre-configured Dio HTTP client
│   └── utils/                 # Helpers / Debug tools
└── features/                  # Business Features (Clean Architecture)
    ├── auth/                  # User authentication & session management
    ├── categories/            # Category catalog management
    ├── dashboard/             # Admin statistics & key metrics
    ├── orders/                # Order processing & lifecycle management
    ├── products/              # Product catalog CRUD & filtering
    └── promotions/            # Promotional offers & banner management
```

---

## 3. Détail des Modules & Fonctionnalités / Feature & Module Breakdown

### Auth / Authentification
- **FR** : Connexion/Inscription des utilisateurs (`Admin` / `Client`), génération/stockage du token JWT, protection des routes.
- **EN**: User Login/Registration (`Admin` / `Client`), JWT token storage, route guards.

### Categories / Catégories
- **FR** : CRUD complet des catégories de menus (Burgers, Boissons, Desserts, etc.).
- **EN**: Full CRUD for menu categories (Burgers, Drinks, Desserts, etc.).

### Products / Produits
- **FR** : Consultation, ajout, édition, suppression de produits avec images (via Cloudinary multipart/form-data) et filtrage par catégorie.
- **EN**: List, create, edit, delete products with Cloudinary image upload (multipart/form-data) and category filtering.

### Orders / Commandes
- **FR** : Prise de commande (sur place/livraison), sélection de table, suivi du statut (`pending`, `preparing`, `ready`, `delivered`, `cancelled`).
- **EN**: Order placement (dine-in/delivery), table number assignment, status tracking (`pending`, `preparing`, `ready`, `delivered`, `cancelled`).

### Promotions
- **FR** : Gestion des offres promotionnelles (dates de début/fin, tarifs réduits, produits associés).
- **EN**: Promotional offer management (start/end dates, discounted pricing, linked product IDs).

### Dashboard / Tableau de Bord
- **FR** : Graphiques et indicateurs clés de performance d'administration.
- **EN**: Charts and admin KPI dashboards.

### Virtual 360° / Visite Virtuelle
- **FR** : Immersion panoramique 360° (Hotspots, plan de masse, mode VR Cardboard).
- **EN**: Interactive 360° panoramic tour (Hotspots, floorplan, VR Cardboard mode).

---

## 4. Spécifications Backend & API (`snackyApi`) / Backend & API Specs (`snackyApi`)

### Configuration & URL de Base / Configuration & Base URL

- **Repository GitHub Backend** : [https://github.com/MohamedF2001/snackyApi](https://github.com/MohamedF2001/snackyApi)
- **Base URL (Déploiement Vercel)** : `https://snacky-api.vercel.app/api`
- **Base URL (Local)** : `http://localhost:3000/api`
- **Entête d'authentification JWT** : `Authorization: Bearer <token_jwt>`

---

### Endpoints API / API Endpoints

#### 1. Authentification (`/auth`)

| Méthode | Endpoint | Accès | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/auth/register` | Public | Inscription utilisateur (`nom`, `email`, `motDePasse`, `role`, `telephone`, `adresse`) |
| `POST` | `/auth/login` | Public | Connexion (`email`, `motDePasse`) -> retourne `token` & `user` |
| `GET` | `/auth/profile` | Authentifié | Profil de l'utilisateur connecté |

#### 2. Catégories (`/categories`)

| Méthode | Endpoint | Accès | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/categories` | Public | Lister toutes les catégories |
| `GET` | `/categories/:id` | Public | Obtenir une catégorie par son ID |
| `POST` | `/categories` | Admin | Créer une catégorie (`nom`, `description`) |
| `PUT` | `/categories/:id` | Admin | Modifier une catégorie |
| `DELETE` | `/categories/:id` | Admin | Supprimer une catégorie |

#### 3. Produits (`/produits`)

| Méthode | Endpoint | Accès | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/produits` | Authentifié | Lister tous les produits |
| `GET` | `/produits/:id` | Authentifié | Obtenir les détails d'un produit |
| `GET` | `/produits/categorie/:id` | Authentifié | Obtenir les produits filtrés par catégorie |
| `POST` | `/produits` | Admin | Créer un produit (Form Data: `nom`, `description`, `prix`, `categorie`, `image`) |
| `PUT` | `/produits/:id` | Admin | Modifier un produit |
| `DELETE` | `/produits/:id` | Admin | Supprimer un produit |

#### 4. Commandes (`/orders`)

| Méthode | Endpoint | Accès | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/orders` | Authentifié | Lister les commandes |
| `GET` | `/orders/:id` | Authentifié | Détails d'une commande |
| `POST` | `/orders` | Authentifié | Créer une commande (`nomClient`, `telephone`, `produits`, `coutTotal`, `surPlace`, `livraison`, `numeroTable`) |
| `PUT` | `/orders/:id` | Authentifié | Modifier une commande |
| `PUT` | `/orders/:id/status` | Admin | Mettre à jour le statut (`pending`, `preparing`, `ready`, `delivered`, `cancelled`) |
| `GET` | `/orders/status/:statut` | Admin | Filtrer les commandes par statut |
| `DELETE` | `/orders/:id` | Authentifié | Annuler/Supprimer une commande |

#### 5. Promotions (`/promotions`)

| Méthode | Endpoint | Accès | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/promotions` | Authentifié | Lister toutes les promotions |
| `GET` | `/promotions/:id` | Authentifié | Détails d'une promotion |
| `POST` | `/promotions` | Admin | Créer une promotion (`nom`, `tarif`, `produits`, `dateDebut`, `dateFin`) |
| `PUT` | `/promotions/:id` | Admin | Modifier une promotion |
| `DELETE` | `/promotions/:id` | Admin | Supprimer une promotion |

---

### Formats des Données & DTOs / Data Formats & DTOs

#### Exemple Objet Produit / Product Object Schema
```json
{
  "_id": "64f8a1b2c3d4e5f6g7h8i9j2",
  "nom": "Big Burger",
  "description": "Notre burger signature avec double steak",
  "prix": 12.50,
  "imageUrl": "https://res.cloudinary.com/demo/image/upload/v1234567890/produits/burger.jpg",
  "categorie": {
    "_id": "64f8a1b2c3d4e5f6g7h8i9j1",
    "nom": "Burgers",
    "description": "Nos délicieux burgers artisanaux"
  },
  "date": "2023-09-06T10:35:00.000Z"
}
```

#### Exemple Création de Commande / Create Order Schema
```json
{
  "nomClient": "Jean Dupont",
  "telephone": "0123456789",
  "produits": [
    {
      "produit": "64f8a1b2c3d4e5f6g7h8i9j2",
      "quantite": 2
    }
  ],
  "coutTotal": 25.00,
  "surPlace": true,
  "livraison": false,
  "numeroTable": "T05"
}
```

---

## 5. Gestion d'État & Navigation / State Management & Routing

- **State Management** : Riverpod (`flutter_riverpod`).
- **Routing** : GoRouter (`go_router`) avec `ShellRoute` pour le layout d'administration et `redirect` guard pour la sécurité d'accès.

---

## 6. Réseau & Gestion des Erreurs / Network & Error Handling

- **Dio Client** : Intercepteurs d'en-tête JWT (`Bearer`).
- **Handling** : Modèles d'échec typés via `fpdart` (`Either<Failure, T>`).

---

## 7. Design System, Thème & Ressources / Design System, Theme & Assets

- **Polices** : Poppins.
- **Thème** : Material 3 (`lib/const/app_theme.dart`).
- **Couleurs** : Primary Blue/Indigo (`#2A3990`), Statuts de commande (Vert, Orange, Bleu, Rouge).

---

## 8. Guide de Migration vers Next.js & Équivalences / Next.js Migration Guide & Equivalences

### 🇫🇷 Français
Ce guide fournit la correspondance directe entre le projet Flutter + `snackyApi` et une architecture moderne **Next.js (App Router)**.

#### Tableau d'Équivalence Technique

| Concept / Feature | Flutter / snackyApi | Equivalent Next.js 14+ |
| :--- | :--- | :--- |
| **Framework Frontend** | Flutter Web | **Next.js (App Router)** |
| **Backend API** | Node.js / Express (`snackyApi`) | **Next.js Route Handlers** (`app/api/`) ou REST direct vers `snacky-api.vercel.app/api` |
| **Base de Données** | MongoDB / Mongoose | **Prisma** ou **Mongoose** (si API réécrite) |
| **Routage** | `GoRouter` | **App Router File-System Navigation** |
| **Layouts** | `ShellRoute` (`AdminHomePage`) | **Next.js Layouts** (`app/(dashboard)/layout.tsx`) |
| **Authentification & Session**| JWT Bearer Token | **NextAuth.js (Auth.js)** ou **Lucia Auth** ou JWT Cookie HTTP-Only |
| **Data Fetching / Cache** | Riverpod + Dio | **TanStack Query (React Query)** |
| **Upload d'Images** | Multer + Cloudinary | **Uploadthing** ou **Cloudinary SDK Node** |
| **Formulaires & Validations** | Flutter Forms | **React Hook Form** + **Zod** |
| **Composants UI** | Material 3 Widgets | **Tailwind CSS** + **shadcn/ui** |
| **360° VR** | `panorama` package | **Three.js** ou **@photo-sphere-viewer/core** |

#### Variables d'Environnement Next.js (`.env.local`)
```env
NEXT_PUBLIC_API_URL=https://snacky-api.vercel.app/api
NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME=votre_cloud_name
```

---

### 🇬🇧 English

#### Technical Equivalences Matrix

| Concept / Feature | Flutter / snackyApi | Next.js 14+ Equivalent |
| :--- | :--- | :--- |
| **Frontend Framework** | Flutter Web | **Next.js (App Router)** |
| **Backend API** | Node.js / Express (`snackyApi`) | **Next.js Route Handlers** (`app/api/`) or direct REST to `snacky-api.vercel.app/api` |
| **Database** | MongoDB / Mongoose | **Prisma** or **Mongoose** (if API is rewritten) |
| **Routing** | `GoRouter` | **App Router File-System Navigation** |
| **Layouts** | `ShellRoute` (`AdminHomePage`) | **Next.js Layouts** (`app/(dashboard)/layout.tsx`) |
| **Authentication & Session** | JWT Bearer Token | **NextAuth.js (Auth.js)** or **Lucia Auth** or HTTP-Only JWT Cookie |
| **Data Fetching / Cache** | Riverpod + Dio | **TanStack Query (React Query)** |
| **Image Upload** | Multer + Cloudinary | **Uploadthing** or **Cloudinary Node SDK** |
| **Form Handling** | Flutter Forms | **React Hook Form** + **Zod** |
| **UI Components** | Material 3 Widgets | **Tailwind CSS** + **shadcn/ui** |
| **360° VR** | `panorama` package | **Three.js** or **@photo-sphere-viewer/core** |

#### Next.js Environment Setup (`.env.local`)
```env
NEXT_PUBLIC_API_URL=https://snacky-api.vercel.app/api
NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME=your_cloud_name
```
