# Snacky - Documentation Technique / Technical Documentation

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
4. [Gestion d'État & Navigation / State Management & Routing](#4-gestion-détat--navigation--state-management--routing)
5. [Réseau & Gestion des Erreurs / Network & Error Handling](#5-réseau--gestion-des-erreurs--network--error-handling)
6. [Design System, Thème & Ressources / Design System, Theme & Assets](#6-design-system-thème--ressources--design-system-theme--assets)
7. [Guide de Migration vers Next.js & Équivalences / Next.js Migration Guide & Equivalences](#7-guide-de-migration-vers-nextjs--équivalences--nextjs-migration-guide--equivalences)

---

## 1. Présentation Générale / Executive Summary

### 🇫🇷 Français
**Snacky** est une application multiplateforme de gestion et de commande de restauration rapide (Fast Food), initialement développée avec **Flutter**. Elle intègre un système d'administration complet (Tableau de bord, gestion du catalogue, commandes, promotions) ainsi qu'une expérience d'immersion virtuelle en 360° pour la présentation de locaux ou de restaurants.

L'objectif principal de ce document est de fournir une cartographie technique exhaustive de l'application Flutter existante afin d'en faciliter la réécriture, la migration ou la réimplémentation avec d'autres technologies web modernes comme **Next.js**.

### 🇬🇧 English
**Snacky** is a cross-platform fast-food management and ordering application initially built with **Flutter**. It features a comprehensive administration system (Dashboard, catalogue management, orders, promotions) alongside an immersive 360° virtual tour experience for showcasing restaurant premises.

The main purpose of this document is to provide an exhaustive technical mapping of the existing Flutter application in order to facilitate its re-engineering, migration, or re-implementation using modern web frameworks such as **Next.js**.

---

## 2. Architecture du Projet / Project Architecture

### 🇫🇷 Français
Le projet respecte les principes de la **Clean Architecture** modulée par fonctionnalité (*Feature-driven Architecture*). Chaque module métier est isolé et découpé en trois couches distinctes :

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
The project adheres to **Clean Architecture** principles structured in a **Feature-driven** format. Every business module is decoupled and segregated into three distinct layers:

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

#### 🇫🇷 Français
- **Description** : Gère la connexion des utilisateurs, le stockage du jeton de session et le contrôle d'accès aux routes protégées via `GoRouter`.
- **Composants Clés** :
  - `LoginPage` (`lib/features/auth/presentation/views/login_page.dart`) : Formulaire de connexion.
  - `AuthProvider` (`lib/features/auth/presentation/providers/auth_provider.dart`) : État d'authentification (`AuthState`), vérification de la persistance au démarrage.
  - `LoginUseCase` (`lib/features/auth/domain/usecases/login_usescase.dart`).
  - `AuthRemoteDataSource` (`lib/features/auth/data/datasources/auth_remote_data_source.dart`) : Appel de l'API POST `/login`.

#### 🇬🇧 English
- **Description**: Handles user login, session token persistence, and route protection via `GoRouter` redirect guards.
- **Key Components**:
  - `LoginPage` (`lib/features/auth/presentation/views/login_page.dart`): Form interface for user authentication.
  - `AuthProvider` (`lib/features/auth/presentation/providers/auth_provider.dart`): Manages `AuthState` and checks initial session status.
  - `LoginUseCase` (`lib/features/auth/domain/usecases/login_usescase.dart`).
  - `AuthRemoteDataSource` (`lib/features/auth/data/datasources/auth_remote_data_source.dart`): Makes POST requests to `/login`.

---

### Categories / Catégories

#### 🇫🇷 Français
- **Description** : Permet la consultation, la création et la suppression des catégories de menu (ex: Burgers, Boissons, Desserts).
- **Composants Clés** :
  - `CategorieListPage` & `CategoryCreatePage`.
  - `CategorieProvider` (`lib/features/categories/presentation/providers/categorie_provider.dart`).
  - Operations Async via `fpdart` (`Either<Failure, List<CategorieEntity>>`).

#### 🇬🇧 English
- **Description**: Supports viewing, creating, and deleting menu categories (e.g. Burgers, Drinks, Desserts).
- **Key Components**:
  - `CategorieListPage` & `CategoryCreatePage`.
  - `CategorieProvider` (`lib/features/categories/presentation/providers/categorie_provider.dart`).
  - Async operations handled via `fpdart` (`Either<Failure, List<CategorieEntity>>`).

---

### Products / Produits

#### 🇫🇷 Français
- **Description** : Gestion complète du catalogue de produits (liste, création, édition, détails, affichage par catégorie).
- **Composants Clés** :
  - `AllProductsPage`, `ProductCreatePage`, `ProductEditPage`, `DetailsProductPage`, `ProductsByCategoryPage`.
  - `ProductProvider` (`lib/features/products/presentation/providers/product_provider.dart`).
  - Modèle de données : `ProductModel` (`id`, `nom`, `description`, `prix`, `image`, `idCategorie`).

#### 🇬🇧 English
- **Description**: Complete product catalog management (listing, creation, edition, details, category filtering).
- **Key Components**:
  - `AllProductsPage`, `ProductCreatePage`, `ProductEditPage`, `DetailsProductPage`, `ProductsByCategoryPage`.
  - `ProductProvider` (`lib/features/products/presentation/providers/product_provider.dart`).
  - Data model: `ProductModel` (`id`, `name`, `description`, `price`, `image`, `categoryId`).

---

### Orders / Commandes

#### 🇫🇷 Français
- **Description** : Gestion du cycle de vie des commandes clients (filtrage par statut, création, modification, consultation des détails et informations clients).
- **Statuts supportés** : `pending` (En attente), `preparing` (En préparation), `ready` (Prête), `delivered` (Livrée), `cancelled` (Annulée).
- **Composants Clés** :
  - `OrderListPageWithFilters`, `OrderCreatePage`, `OrderDetailPageEnhanced`, `OrderEditPage`.
  - `OrderProvider` (`lib/features/orders/presentation/providers/order_provider.dart`).

#### 🇬🇧 English
- **Description**: Lifecycle management for customer orders (filtering by status, creation, modification, detailed view, customer information).
- **Supported Statuses**: `pending`, `preparing`, `ready`, `delivered`, `cancelled`.
- **Key Components**:
  - `OrderListPageWithFilters`, `OrderCreatePage`, `OrderDetailPageEnhanced`, `OrderEditPage`.
  - `OrderProvider` (`lib/features/orders/presentation/providers/order_provider.dart`).

---

### Promotions

#### 🇫🇷 Français
- **Description** : Gestion des offres promotionnelles actives sur l'application (remises, bannières, réductions).
- **Composants Clés** :
  - `AllPromotionPage`, `CreatePromotionPage`, `PromotionDetailPage`.
  - `PromotionProvider` (`lib/features/promotions/presentation/providers/promotion_provider.dart`).

#### 🇬🇧 English
- **Description**: Management of active promotional offers across the application (discounts, banners, deals).
- **Key Components**:
  - `AllPromotionPage`, `CreatePromotionPage`, `PromotionDetailPage`.
  - `PromotionProvider` (`lib/features/promotions/presentation/providers/promotion_provider.dart`).

---

### Dashboard / Tableau de Bord

#### 🇫🇷 Français
- **Description** : Vue d'ensemble statistique pour les administrateurs (chiffre d'affaires, volume de commandes, graphiques d'activité via `fl_chart`).
- **Composants Clés** :
  - `DashboardPage` (`lib/features/dashboard/dashboard_page.dart`).

#### 🇬🇧 English
- **Description**: Statistical overview for administrators (revenue, order volume, analytical charts powered by `fl_chart`).
- **Key Components**:
  - `DashboardPage` (`lib/features/dashboard/dashboard_page.dart`).

---

### Virtual 360° / Visite Virtuelle

#### 🇫🇷 Français
- **Description** : Module d'exploration interactive à 360 degrés des pièces ou locaux (Salon, Cuisine, Chambre) avec zones d'interaction (hotspots), mode stéréoscopique VR Cardboard et plan de masse interactif (*Floorplan*).
- **Composants Clés** :
  - `Virtual` (`lib/virtual.dart`) : Conteneur principal basé sur la bibliothèque `panorama`.
  - `SceneModel` : Modèle de changement de pièce et de gestion d'état UI.
  - `CardboardView` : Rendu côte-à-côte pour casques VR.

#### 🇬🇧 English
- **Description**: Interactive 360-degree exploration module for spaces (Living room, Kitchen, Bedroom) with interactive hotspots, VR Cardboard stereoscopic view mode, and interactive floorplan.
- **Key Components**:
  - `Virtual` (`lib/virtual.dart`): Main container utilizing the `panorama` package.
  - `SceneModel`: Manages room transitions and UI state.
  - `CardboardView`: Side-by-side rendering for mobile VR headsets.

---

## 4. Gestion d'État & Navigation / State Management & Routing

### 🇫🇷 Français
- **Gestion d'état** : L'application utilise **Flutter Riverpod** (`flutter_riverpod`).
  - Les `StateNotifierProvider` ou `NotifierProvider` exposent l'état réactif aux vues (`ConsumerWidget`, `ref.watch`, `ref.read`).
  - Programmation fonctionnelle pour le traitement des erreurs via `fpdart` (`Either<Failure, T>`).
- **Navigation & Routage** : **GoRouter** (`go_router`) est configuré dans `lib/app.dart`.
  - Utilisation d'un `ShellRoute` pour encapsuler l'interface d'administration avec un menu de navigation fixe (`AdminHomePage`).
  - Protection des routes via le callback `redirect` basés sur `authProvider`.

### 🇬🇧 English
- **State Management**: The application employs **Flutter Riverpod** (`flutter_riverpod`).
  - `StateNotifierProvider` or `NotifierProvider` instances expose reactive state to UI widgets (`ConsumerWidget`, `ref.watch`, `ref.read`).
  - Functional programming approach for robust error handling via `fpdart` (`Either<Failure, T>`).
- **Routing & Navigation**: Managed by **GoRouter** (`go_router`) configured in `lib/app.dart`.
  - Features a `ShellRoute` wrapping administrative views with a persistent shell layout (`AdminHomePage`).
  - Guards routes dynamically via `redirect` callbacks bound to `authProvider`.

---

## 5. Réseau & Gestion des Erreurs / Network & Error Handling

### 🇫🇷 Français
- **Client HTTP** : Basé sur **Dio** (`lib/core/network/api_client.dart`).
  - URL de base configurable (`AppConfig.baseUrl`).
  - Intercepteurs pour l'injection automatique des jetons d'authentification (`Bearer Token`).
- **Traitement des Erreurs** :
  - Classe `Failure` générée par **Freezed** (`lib/core/error/failures.dart`).
  - Typages de pannes : `ServerFailure`, `NetworkFailure`, `UnauthorizedFailure`, `NotFoundFailure`, `UnknownFailure`.

### 🇬🇧 English
- **HTTP Client**: Built with **Dio** (`lib/core/network/api_client.dart`).
  - Configurable Base URL (`AppConfig.baseUrl`).
  - HTTP Interceptors attached for automated Authorization (`Bearer Token`) header injection.
- **Error Handling**:
  - `Failure` class generated using **Freezed** (`lib/core/error/failures.dart`).
  - Failure types: `ServerFailure`, `NetworkFailure`, `UnauthorizedFailure`, `NotFoundFailure`, `UnknownFailure`.

---

## 6. Design System, Thème & Ressources / Design System, Theme & Assets

### 🇫🇷 Français
- **Polices** : Poppins (Light, Medium, Regular, Bold, Italic).
- **Thème** : Configuré dans `lib/const/app_theme.dart` (Material 3 enabled).
- **Palette de Couleurs** (`lib/const/app_colors.dart`) :
  - Couleur Primaire : Bleuté / Indigo (#2A3990 / #3F51B5).
  - Statuts des commandes : Vert (Livré), Orange (En préparation), Bleu (En attente), Rouge (Annulé).
- **Styles de Formulaires** (`lib/const/app_input_style.dart`) : Marges, bordures arrondies et styles de champs de texte réutilisables.

### 🇬🇧 English
- **Typography**: Poppins font family (Light, Medium, Regular, Bold, Italic).
- **Theme**: Configured in `lib/const/app_theme.dart` (Material 3 enabled).
- **Color Palette** (`lib/const/app_colors.dart`):
  - Primary Accent: Indigo / Deep Blue (#2A3990 / #3F51B5).
  - Order Status Colors: Green (Delivered), Orange (Preparing), Blue (Pending), Red (Cancelled).
- **Input Styling** (`lib/const/app_input_style.dart`): Reusable text field borders, padding, and focus decorators.

---

## 7. Guide de Migration vers Next.js & Équivalences / Next.js Migration Guide & Equivalences

### 🇫🇷 Français
Ce guide fournit la correspondance directe entre les composants Flutter de l'application Snacky et l'écosystème **Next.js (App Router)**.

#### Tableau d'Équivalence Technique

| Concept / Feature | Flutter (Snacky) | Equivalent Next.js / React |
| :--- | :--- | :--- |
| **Framework Web / App** | Flutter Web | **Next.js 14+ (App Router)** |
| **Langage** | Dart | **TypeScript** |
| **Routage & Navigation** | `GoRouter` (`lib/app.dart`) | **Next.js File-system Routing** (`app/` directory) |
| **Layouts Imbriqués** | `ShellRoute` (dans `app.dart`) | **Next.js Layouts** (`app/(admin)/layout.tsx`) |
| **Protection de Routes** | `redirect` Guard dans GoRouter | **Middleware Next.js** (`middleware.ts`) + Session Guard |
| **State Management UI** | Riverpod (`flutter_riverpod`) | **Zustand** ou **React Context** |
| **Data Fetching & Cache** | Riverpod + Dio | **TanStack Query (React Query)** + `fetch` / `axios` |
| **Formulaires & Validations** | Flutter Form + Controller | **React Hook Form** + **Zod** |
| **Composants UI / Design** | Material 3 + Custom Widgets | **Tailwind CSS** + **shadcn/ui** / **Radix UI** |
| **Graphiques Admin** | `fl_chart` | **Recharts** ou **Tremor** |
| **Visite Virtuelle 360°** | `panorama` (OpenGL / WebGL) | **Three.js** ou **@photo-sphere-viewer/core** |
| **Traitement des d'Erreurs**| `fpdart` (`Either<Failure, T>`) | **Result pattern** ou bloc `try/catch` typés |

#### Structure Recommandée pour le Projet Next.js

```
next-snacky/
├── app/                        # Next.js App Router
│   ├── (auth)/                 # Groupe de routes d'authentification
│   │   └── login/page.tsx
│   ├── (dashboard)/            # Groupe de routes d'administration avec layout partagé
│   │   ├── layout.tsx          # Équivalent du ShellRoute (AdminHomePage)
│   │   ├── page.tsx            # /admin (Dashboard)
│   │   ├── categories/
│   │   ├── products/
│   │   ├── orders/
│   │   ├── promotions/
│   │   └── settings/
│   ├── virtual/page.tsx        # Module Visite Virtuelle 360°
│   ├── api/                    # Route Handlers Next.js (Proxy API / Auth)
│   └── layout.tsx              # Root Layout
├── components/                 # Composants React réutilisables (shadcn/ui)
│   ├── ui/
│   ├── dashboard/
│   ├── orders/
│   └── virtual-tour/
├── lib/                        # Configuration & Utilitaires
│   ├── api-client.ts           # Instance Fetch / Axios préconfigurée
│   └── validations/            # Schémas de validation Zod
├── store/                      # Stores Zustand (Auth, Cart, UI)
└── types/                      # Interfaces TypeScript (Product, Order, User)
```

---

### 🇬🇧 English
This guide maps each Flutter concept from the Snacky project directly to the **Next.js (App Router)** ecosystem.

#### Technical Equivalences Matrix

| Concept / Feature | Flutter (Snacky) | Next.js / React Equivalent |
| :--- | :--- | :--- |
| **Web Framework** | Flutter Web | **Next.js 14+ (App Router)** |
| **Language** | Dart | **TypeScript** |
| **Routing & Navigation** | `GoRouter` (`lib/app.dart`) | **Next.js File-system Routing** (`app/` directory) |
| **Nested Layouts** | `ShellRoute` (in `app.dart`) | **Next.js Layouts** (`app/(admin)/layout.tsx`) |
| **Route Protection** | `redirect` Guard in GoRouter | **Next.js Middleware** (`middleware.ts`) + Session Guard |
| **UI State Management** | Riverpod (`flutter_riverpod`) | **Zustand** or **React Context** |
| **Data Fetching & Cache** | Riverpod + Dio | **TanStack Query (React Query)** + `fetch` / `axios` |
| **Forms & Validation** | Flutter Form + Controller | **React Hook Form** + **Zod** |
| **UI Components / Design** | Material 3 + Custom Widgets | **Tailwind CSS** + **shadcn/ui** / **Radix UI** |
| **Admin Charts** | `fl_chart` | **Recharts** or **Tremor** |
| **360° Virtual Tour** | `panorama` (OpenGL / WebGL) | **Three.js** or **@photo-sphere-viewer/core** |
| **Error Handling** | `fpdart` (`Either<Failure, T>`) | **Result pattern** or typed `try/catch` blocks |

#### Recommended Next.js Architecture Structure

```
next-snacky/
├── app/                        # Next.js App Router
│   ├── (auth)/                 # Auth route group
│   │   └── login/page.tsx
│   ├── (dashboard)/            # Dashboard route group with shared admin layout
│   │   ├── layout.tsx          # ShellRoute equivalent (AdminHomePage)
│   │   ├── page.tsx            # /admin (Dashboard)
│   │   ├── categories/
│   │   ├── products/
│   │   ├── orders/
│   │   ├── promotions/
│   │   └── settings/
│   ├── virtual/page.tsx        # 360° Virtual Tour page
│   ├── api/                    # Next.js Route Handlers (API proxy / Auth)
│   └── layout.tsx              # Root Layout
├── components/                 # Reusable UI React components (shadcn/ui)
│   ├── ui/
│   ├── dashboard/
│   ├── orders/
│   └── virtual-tour/
├── lib/                        # Infrastructure & Utilities
│   ├── api-client.ts           # Preconfigured Fetch / Axios instance
│   └── validations/            # Zod validation schemas
├── store/                      # Zustand state stores (Auth, Cart, UI)
└── types/                      # TypeScript definitions (Product, Order, User)
```
