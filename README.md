# MonitorSchonung

Eine kleine native macOS-Menüleisten-App für Herberts Zwei-Monitor-Setup. Sie legt nach der eingestellten Zeit eine dunkle, halbtransparente und klickdurchlässige Fläche über den **BenQ PD3205U**. Beim Zurückbewegen des Mauszeigers auf diesen Monitor verschwindet die Fläche sofort. Die Hardware-Helligkeit, Farbprofile und Monitor-Presets werden nicht verändert.

## Voraussetzungen

- macOS 13 oder neuer
- Ein angeschlossener BenQ PD3205U als sekundärer Monitor

## Ohne Xcode über GitHub Actions bauen

Das ist derselbe Weg wie bei der Desktop-Uhr. Auf deinem Mac musst du keine Entwicklungsumgebung installieren.

1. Den Inhalt dieses Ordners in ein neues GitHub-Repository hochladen. Wichtig: Den versteckten Ordner `.github` samt `workflows/build.yml` mit hochladen.
2. Im Repository **Actions → MonitorSchonung bauen → Run workflow** wählen.
3. Nach erfolgreichem Lauf unten unter **Artifacts** `MonitorSchonung-Apple-Silicon` herunterladen.
4. Die heruntergeladene ZIP und danach `MonitorSchonung-Apple-Silicon.zip` entpacken. `MonitorSchonung.app` in **Programme** ziehen und starten.

GitHub erstellt die App für Apple Silicon. Sie ist nur ad hoc signiert, nicht mit einer Apple Developer ID notarisiert. macOS kann beim ersten Start eine Sicherheitsmeldung anzeigen. In diesem Fall die App einmal öffnen, dann **Systemeinstellungen → Datenschutz & Sicherheit → Dennoch öffnen** wählen.

## Optional: App in Xcode starten

Falls Xcode bereits installiert ist:

1. `MonitorSchonung.xcodeproj` in Xcode öffnen.
2. Oben das Ziel **MonitorSchonung** und **My Mac** auswählen.
3. Auf ▶ klicken. Beim ersten Start gegebenenfalls die Ausführung der lokal gebauten App bestätigen.
4. Das Display-Symbol in der Menüleiste anklicken. **Aktiv**, **Wartezeit** und **Abdunklung** einstellen.

Die App hat absichtlich kein Dock-Symbol. Zum Beenden im Menü **Beenden** wählen. Beim ersten Start ist sie aktiv, mit 10 Minuten Wartezeit und 65 % Abdunklung.

## Monitorwahl

Bei **Automatisch: PD3205U** wird nur dann abgedunkelt, wenn genau ein nicht als Hauptmonitor eingerichtetes Display mit `PD3205U` im macOS-Displaynamen gefunden wird. Falls macOS einen anderen Namen zeigt, den PD3205U im Menü **Monitor** manuell auswählen. Diese Wahl wird über die Display-UUID gespeichert. Ist der gewählte Monitor nicht verbunden oder wird zum Hauptmonitor, bleibt die Abdunklung aus. Nach dem Wiederanschließen wird die Anzeige neu geprüft.

Der Hauptmonitor erscheint nicht als wählbares Ziel. Wird ein Monitor ausgetauscht und unter derselben gespeicherten UUID von macOS erkannt, die Monitorwahl bitte prüfen.

## Wie die Zeit zählt

Die Wartezeit beginnt, sobald der Mauszeiger den Zielmonitor verlässt. Die App prüft seine Position etwa alle 50 ms. Wenn die Wartezeit verstrichen ist, blendet das Overlay in etwa 0,8 Sekunden ein. Es nimmt keine Klicks entgegen. Beim Betreten des Zielmonitors wird es ohne Ausblendanimation entfernt.

Das Overlay liegt auf einer hohen Fensterebene und kann dadurch über Fenstern und Vollbild-Apps erscheinen. macOS kann für bestimmte geschützte Inhalte oder Systemoberflächen abweichend zeichnen.

## GitHub-Upload

Den kompletten Ordner `MonitorSchonung` als Repository verwenden. In GitHub ein leeres Repository anlegen und die Dateien dieses Ordners hochladen; `build`, `DerivedData` und persönliche Xcode-Dateien gehören nicht dazu. Wer GitHub Desktop nutzt: **File → Add Local Repository** und diesen Ordner auswählen; falls angeboten **Create a Repository** wählen, danach **Publish repository**. Der versteckte Ordner `.github` gehört ausdrücklich dazu.

## Technische Hinweise

Die Einstellungen liegen in `UserDefaults`. Es gibt keine Netzwerkverbindung, keine Hilfsprogramme, keine Accessibility-Berechtigung und keinen Zugriff auf DDC/CI oder ICC-Profile. Die App nutzt `NSScreen`, `NSEvent.mouseLocation` und ein transparentes `NSWindow`.
