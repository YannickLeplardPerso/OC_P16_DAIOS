en cours
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
