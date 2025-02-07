en cours
build 26 dev
- ci.yml : suppression de l'étape d'upload de l'artefact 

build 25 dev
- correction cy.yml (result-bundle-path et path)

build 24 dev
- suppression du @MainActor pour les classes de tests : gestion au niveau des appels de fonctions et des valeurs
- mise en commentaire de tous les tests sauf testAddMedicine pour investigation blocage ci

build 23 dev
- suppression du code (déjà commenté) des tests utilisant le framework Testing
- modification des view models et des vues pour utiliser des fonctions "async/await"
- refonte des tests unitaires 

build 22 dev
- correction : texte en anglais pour l'alerte dans addMedicineSheet
- ci : ajout de Node.js et Firebase Tools, démarrage des émulateurs Firebase

build 21 dev
- ajout du path pour GoogleService-info.plist dans ci.yml

build 20 dev
- création d'un secret Github pour GoogleService-info.plist. Ajout d'une injection (du secret) dans ci.yml

build 19 dev
- réécriture des tests unitaires avec l'ancien framework XCTest car Testing n'est pas supporté par github actions !

correction et push du projet deux fois suite à des erreurs dans le fichier ci.yml
(mauvais nom de projet et mauvais nom du scheme)

build 18 dev
- mise en place de l'intégration continue sur Github : création du fichier ci.yml dans le projet et d’une pull request sur github.

build 17 dev
- refactorisation et correction/amélioration des tests unitaires (deux fichiers SessionStoreTests et MedicineStockViewModelTest, création de users et de medicines de test, valides et invalides...)
- tests UI

build 16 dev
- ajout d'un popup pour indiquer la bonne création d'un nouveau médicament
- revue de la configuration de l’émulateur local Firebase et ajout dans MedicConfig d’un flag pour son utilisation 
- création d’un plan de test personnalisé 
- ajout des éléments d'accessibilité et aussi des identifiers pour les tests ui

build 15 dev
- installation d'un serveur local Firebase pour les tests, début d'implémentation des tests unitaires
- correction bug : bouton suppression de médicament MedicineDetailView (qui avait disparu)
- amélioration : rechargement historique immédiat quand on modifie le stock en mode lazy dans MedicineDetailView
- amélioration : quand on ajoute un nouveau médicament à partir de la liste d'une Aisle, elle est présélectionnée comme destination par défaut. 
- correction bug de navigation après création d'un nouveau médicament et navigation vers le détail (NavigationStack vs NavigationView)
- amélioration : à la suppression d'un médicament on revient à la page précédente (Aisle ou All). Si c'est le dernier d'une Aisle dont on vient, on remonte à tab Aisles 

build 14 dev
-  implémentation du lazy loading pour medicine

build 13 dev
-  implémentation du lazy loading pour l'history

build 12 dev
- signup : vérification locale des contraintes du mot de passe
- tri et recherche : déplacement de la logique de tri et recherche dans MedicineStockViewModel, et création d’une fonction « Firebase »
- création d'un fichier pour les enum (SortOption, loadingStrategy)
- création d'une structure MedicConfig pour configurer des choix (notamment lemode de tri, de chargement) 

build 11 dev
- History : Ajout de l’utilisateur (adresse email) à l’origine d’un changement
- indicateurs de chargement de données : indicateur isLoading dans MedicineStockViewModel, et progress view lors des appels à fetchMedicinesAndAisles et fetchHistory ; séparation du chargement initial et de la mise à jour via le listener ; modifications dans les vues qui appellent ces fonctions pour afficher une progress view pendant le chargement

build 10 dev
- création de composants toolbar : MedicNavigationToolbar pour la navigation et MedicActionsToolbar pour les boutons + d’ajout de médicament et la déconnexion 
- création d'un composant MedicineRowView utilisé dans AllMedicinesView et MedicineListView
- création de composants pour les sections de MedicineDetailView et pour les éléments de la liste d’historique

build 9 dev
- correction bugs navigation et intitulé des boutons « back »
- MedicineStockViewModel : création d’une fonction fetchMedicinesAndAisles à la place de fetchMedicines et fetchAisles

build 8 dev
- nouveau médicament : ajout fonction de création dans le view model et une sheet view pour la saisie

build 7 dev :
- Firestore : (ré)initialisation ?!
- Gestion des erreurs dans les vues avec des alertes
- Implémentation de la suppression d'un médicament dans MedicineDetailView avec fonction dans le view model : bouton - désactivé et bouton suppression ssi stock = 0

build 6 dev :
- amélioration de l'UI de MedicineListView et MedicineDetailView
- Revue de la gestion des stocks dans le MedicineStockViewModel et la MedicineDetailView
- Gestion des erreurs de MedicineStockViewModel
- Revue du projet Firebase : nouvelle clé API avec restrictions
- Dans MedicineStockViewModel, correction fetchAisles pour avoir le bon nombre de medicines immédiatement

build 5 dev :
- amélioration de l'UI de AisleListView et AllMedicinesView

build 4 dev :
- Simplification : supression de ContentView 
- MainTabView : ajout d'une toolbar (et une NavigationView) pour avoir un bouton de deconnexion toujours visible
- transfert du bouton medicineStore.addRandomMedicine dans la toolbar (et suppression dans les autres views)
- amélioration de l'UI de LoginView


build 3 dev :
- création et sélection d'une branche dev
- refactorisation MVVM : une seule instance de MedicineStockViewModel (dans MediStockApp)
- Suppression de AppDelegate.swift (l'init de Firebase se fait dans MediStockApp)
- Gestion des erreurs : création d'un fichier MedicError, gestion dans le view model SessionStore et affichage (alerte) dans la LoginView
- déconnexion user au lancement de l'app

build 2 :
- création projet Firebase (GestionStockMedicaments)
- Ajout GoogleService-Info.plist au projet MAIS pas dans Git
- Ajout Firebase Authentification + règles id/mdp + 1 user 
- correction .onchange dans MedicineDetailView (dépréciée)
- tests ok
