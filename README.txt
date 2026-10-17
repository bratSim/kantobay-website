KANTOBAY WEBSITE V3 — GitHub Pages + Supabase (Welten-Update)

INHALT
- index.html: mittelalterlich gestaltete, responsive Website mit DE/EN/ET
- config.js: öffentliche Supabase-Konfiguration (Platzhalter)
- setup.sql: Datenbankschema, Rollen, Auth-Trigger und Row Level Security
- KantoBayGrundgesetz.pdf: bereitgestellte Grundgesetz-PDF (wenn beim Export verfügbar)

FUNKTIONEN
- Startseite, Neuigkeiten, Welten, Grundgesetz, KantoBay Sender, Verwaltung
- Server-IP Kantobay.net; Whitelist-Hinweis; Discord https://discord.gg/RUP6wqU
- echte Serverkarte extern: https://map.kantobay.net/
- Weltenübersicht mit Farmwelt, Farmenwelt, Farmwelt Nether, world und world the end; Stadtteile vollständig aufgelistet; keine unnötige schematische Grafik
- News-Publishing über Supabase, Login/Signup, Rollen reader/editor/admin, Admin-Rollenverwaltung
- Grundgesetz-Zusammenfassung basiert auf dem bereitgestellten Dokument. Dokument selbst nennt den 07.02.2025 als Geltungsbeginn. Vor Livegang prüfen, ob eine neuere beschlossene Fassung existiert.

WICHTIG: STATISCHES HOSTING + BENUTZERKONTEN
GitHub Pages kann HTML/CSS/JS hosten, aber keine sichere Benutzerverwaltung oder Datenbank allein bereitstellen. Daher nutzt dieses Projekt Supabase als Backend-as-a-Service. Es ist nach Einrichtung verwendbar; die Zugangsdaten und der erste Administrator müssen von dir konfiguriert werden. Ich habe keine Konten oder Projekte in deinem Namen erstellt.

EINRICHTUNG
1. Erstelle ein Supabase-Projekt auf https://supabase.com/
2. Öffne Project Settings / API und kopiere die Project URL sowie den anon/public key.
3. Öffne config.js und ersetze:
   YOUR_SUPABASE_PROJECT_URL
   YOUR_SUPABASE_ANON_PUBLIC_KEY
   Verwende niemals den service_role key im Browser oder GitHub-Repository.
4. Öffne Supabase Dashboard > SQL Editor und führe den vollständigen Inhalt von setup.sql aus.
5. Erstelle den ersten Benutzer über die Website (Verwaltung > Konto erstellen). Falls E-Mail-Bestätigung aktiviert ist, bestätige die Mail.
6. In Supabase Dashboard > Authentication > Users die UUID des ersten Benutzers kopieren.
7. In Supabase SQL Editor einmalig ausführen:
   update public.profiles set role = 'admin' where id = 'DIE-UUID-HIER';
   Danach diese UUID-Zeile nicht öffentlich im Repository speichern.
8. Melde dich auf der Website an. Admin kann Rollen an vorhandene Konten vergeben; Redakteure können Beiträge erstellen/löschen; Leser können sich anmelden, aber nicht veröffentlichen.
9. GitHub: neues Repository erstellen und index.html, config.js, setup.sql, README.txt sowie PDF hochladen. Unter Settings > Pages GitHub Pages aktivieren (Deploy from a branch, main / root).
10. Supabase Authentication > URL Configuration: Site URL auf deine GitHub-Pages-URL setzen und Redirect URLs passend eintragen.
11. Teste in einem privaten Browserfenster: Besucher dürfen nur veröffentlichte Posts lesen; Leser dürfen keine Posts schreiben; Redakteure dürfen Inhalte bearbeiten; nur Admins dürfen Rollen ändern.

ROLLEN
- reader: angemeldeter Leser; keine Schreibrechte
- editor: Beiträge erstellen und löschen
- admin: Beiträge verwalten und Benutzerrollen zuweisen

SICHERHEIT UND OFFENE PUNKTE
- Keine Passwörter selbst speichern; Supabase Auth übernimmt Authentifizierung.
- RLS ist zwingend. Der öffentliche anon key ist für Browserbetrieb gedacht; die Datenbankregeln sind die eigentliche Zugriffskontrolle.
- Admin-Änderungen sind sensible Aktionen. Aktiviere E-Mail-Bestätigung, starke Passwörter und Schutz gegen automatisierte Registrierungen. Überlege, ob öffentliche Registrierung nach dem Erstellen der Teamkonten abgeschaltet werden soll.
- Die Rolle kann nur über die serverseitig geprüfte Admin-Funktion geändert werden; das erste Admin-Konto wird einmalig über SQL gebootstrapped.
- GitHub Pages ist öffentlich: alles, was ins Repository geladen wird, ist öffentlich. Keine Geheimnisse oder Service-Role-Keys committen.
- Vor Veröffentlichung Impressum und Datenschutzerklärung ergänzen und tatsächliche Datenverarbeitung prüfen.
- Der Grundgesetz-Bereich zeigt eine Zusammenfassung, nicht jeden Absatz vollständig. Für eine verbindliche Veröffentlichung den vollständigen Wortlaut und die aktuell gültige Fassung einsetzen.
- Sender-Seite enthält noch Platzhalter; echte Medienlinks und Sendeplan müssen ergänzt werden.
