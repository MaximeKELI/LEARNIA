#!/usr/bin/env python3
"""
Script d'analyse de code pour le projet Learnia Backend
Équivalent à 'flutter analyze' pour Python/FastAPI
"""

import subprocess
import sys
from pathlib import Path


def run_command(command, description):
    """Exécute une commande et affiche le résultat"""
    print(f"\n{'='*60}")
    print(f"🔍 {description}")
    print(f"{'='*60}")
    
    try:
        result = subprocess.run(
            command, 
            shell=True, 
            capture_output=True, 
            text=True,
            cwd=Path(__file__).parent
        )
        
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)
            
        if result.returncode == 0:
            print(f"✅ {description} - SUCCÈS")
        else:
            print(f"❌ {description} - ÉCHEC (code: {result.returncode})")
            
        return result.returncode == 0
        
    except Exception as e:
        print(f"❌ Erreur lors de l'exécution: {e}")
        return False


def main():
    """Fonction principale d'analyse"""
    print("🚀 Analyse du code Learnia Backend")
    print("Équivalent à 'flutter analyze' pour Python/FastAPI")
    
    # Vérifier que nous sommes dans le bon répertoire
    if not Path("app").exists():
        print("❌ Erreur: Ce script doit être exécuté depuis le répertoire "
              "learnia-backend")
        sys.exit(1)
    
    success_count = 0
    total_checks = 0
    
    # 1. Vérification de la syntaxe avec Python
    print("\n📝 Vérification de la syntaxe Python...")
    result = subprocess.run(
        "python -m py_compile app/main.py",
        shell=True,
        capture_output=True,
        text=True
    )
    if result.returncode == 0:
        print("✅ Syntaxe Python - OK")
        success_count += 1
    else:
        print(f"❌ Erreur de syntaxe: {result.stderr}")
    total_checks += 1
    
    # 2. Formatage avec Black
    success = run_command(
        "black --check app/",
        "Vérification du formatage (Black)"
    )
    if success:
        success_count += 1
    total_checks += 1
    
    # 3. Organisation des imports avec isort
    success = run_command(
        "isort --check-only app/",
        "Vérification de l'organisation des imports (isort)"
    )
    if success:
        success_count += 1
    total_checks += 1
    
    # 4. Analyse statique avec flake8
    success = run_command(
        "flake8 app/",
        "Analyse statique (flake8)"
    )
    if success:
        success_count += 1
    total_checks += 1
    
    # 5. Vérification des types avec mypy (optionnel)
    print("\n" + "="*60)
    print("🔍 Vérification des types (mypy)")
    print("="*60)
    try:
        result = subprocess.run(
            "mypy app/",
            shell=True,
            capture_output=True,
            text=True,
            timeout=30
        )
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)
        
        if result.returncode == 0:
            print("✅ Vérification des types - OK")
            success_count += 1
        else:
            print("⚠️  Vérification des types - Avertissements détectés")
        total_checks += 1
    except subprocess.TimeoutExpired:
        print("⏰ Vérification des types - Timeout (ignoré)")
    except Exception as e:
        print(f"❌ Erreur mypy: {e}")
    
    # 6. Vérification des dépendances
    print("\n" + "="*60)
    print("📦 Vérification des dépendances")
    print("="*60)
    try:
        result = subprocess.run(
            "pip check",
            shell=True,
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            print("✅ Dépendances - OK")
            success_count += 1
        else:
            print(f"❌ Conflit de dépendances: {result.stderr}")
        total_checks += 1
    except Exception as e:
        print(f"❌ Erreur vérification dépendances: {e}")
    
    # Résumé final
    print("\n" + "="*60)
    print("📊 RÉSUMÉ DE L'ANALYSE")
    print("="*60)
    print(f"✅ Succès: {success_count}/{total_checks}")
    print(f"❌ Échecs: {total_checks - success_count}/{total_checks}")
    
    if success_count == total_checks:
        print("\n🎉 Toutes les vérifications ont réussi !")
        print("Votre code est prêt pour la production.")
    else:
        print(f"\n⚠️  {total_checks - success_count} problème(s) détecté(s)")
        print("Corrigez les erreurs avant de continuer.")
    
    return success_count == total_checks


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1) 