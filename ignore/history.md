en cours
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
