# CineAdviento 🎬🍕

Calendario de adviento de pelis y cenas para iPhone (iOS 17+, pensado para 14 Pro Max en adelante). SwiftUI, sin dependencias ni servidor.

## Qué hace

- 15 puertas (fines de semana desde el 7 nov + especial Nochebuena). Cada una se abre a las 00:00 de su día.
- Al llegar el día, la app abre sola la puerta: el regalo tiembla, explota en estrellas y revela la peli, la cena, el tiempo de preparación y la lista de la compra.
- **Avisos locales** (funcionan con la app cerrada y sin internet). Con la peli a las 21:00 por defecto:
  - 19:00 del día anterior: «haz la compra».
  - 10:00 del día: «hoy se abre una puerta».
  - **Hora de empezar a cocinar** según cada receta (p. ej. pizza 4 h → 17:00; Nochebuena 6 h → 15:00).
  - A la hora de la peli.
- Ajustes: hora de la peli, activar/desactivar avisos, aviso de prueba y «modo prueba» para abrir todas las puertas y ver la animación.

## Instalar en tu iPhone

1. En el Mac abre `ios/CineAdviento/CineAdviento.xcodeproj` (Xcode 16 o superior).
2. Target **CineAdviento** → *Signing & Capabilities* → *Team*: tu Apple ID (vale uno gratuito).
   Si dice que el bundle id está ocupado, cambia `com.cineadviento.app` por otro tuyo.
3. Conecta el iPhone por cable, selecciónalo como destino y pulsa ▶︎.
4. En el iPhone: *Ajustes → Privacidad y seguridad → Modo de desarrollador* (actívalo) y en
   *Ajustes → General → VPN y gestión de dispositivos* confía en tu certificado.
5. Abre la app y **permite las notificaciones**.

Con Apple ID gratuito la app **caduca a los 7 días**: hay que volver a conectar el iPhone y pulsar ▶︎
(las puertas abiertas se conservan). Con cuenta de pago (99 $/año) dura un año.

## Plan B: `CalendarioAdviento.ics`

El mismo calendario como eventos con alarmas (hora de cocinar + día anterior) para la app Calendario.
Envíalo al iPhone (AirDrop/correo) y ábrelo. Úsalo **en lugar de** los avisos de la app, no a la vez,
o te llegarán duplicados.
