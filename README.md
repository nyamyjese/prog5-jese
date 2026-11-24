# PROG5 — Vérification de l'environnement

Ce dépôt contient le script qui vérifie que votre poste est prêt pour PROG5.
Le guide d'installation complet est sur le LMS : https://hei-lms.app

## Ce qui est vérifié

| Vérification    | Attendu                                                                     |
|-----------------|-----------------------------------------------------------------------------|
| Git             | Installé, avec `user.name` et `user.email` configurés                       |
| Java            | JDK 21 ou plus, Maven                                                       |
| TypeScript      | Node.js 24 LTS ou plus, npm                                                 |
| PHP             | PHP 8.4 ou plus, Composer, Symfony CLI, extensions requises par Symfony 7.4 |
| Base de données | Docker démarré, image `postgres:17` téléchargée                             |

## Lancer le script

Récupérez d'abord le dépôt (c'est déjà un premier test de Git) :

```bash
git clone git@github.com:hei-ryan/prog-5-setup.git
cd prog5-setup
```

**macOS, Linux ou WSL**

```bash
chmod +x check-env.sh
./check-env.sh
```

**Windows (PowerShell)**

```powershell
powershell -ExecutionPolicy Bypass -File .\check-env.ps1
```

Chaque ligne affiche `[OK]` ou `[KO]` avec la marche à suivre. Corrigez, puis relancez jusqu'à obtenir « Environnement
prêt pour PROG5 ».

## Rendre le résultat

Le script écrit sa sortie dans `check-env-result.txt`. Copiez ce fichier dans votre dépôt de binôme `prog5-[binôme]`,
puis :

```bash
git add check-env-result.txt
git commit -m "Vérification de l'environnement"
git push
```

## Conseil

L'image PostgreSQL pèse plusieurs centaines de Mo.

```bash
docker pull postgres:17
```
