# CineAdviento 🎬🍕

Calendario de adviento de pelis y cenas para iPhone. SwiftUI con **Liquid Glass**, iOS 26 o superior (funciona en iOS 27.x).

## Funciones

- **Tus propios calendarios**: eliges fechas (fines de semana, solo sábados, viernes y sábados o todos los días) y si hay especial de Nochebuena. Incluye de ejemplo el calendario «Pelis y Comidas 2026».
- **Peli por plan**: buscador de TMDB (títulos, sinopsis en español, pósters y nota) y catálogo navideño incluido que funciona sin internet.
- **Menú por plan**: 21 menús por categorías con tiempo de preparación, consejo y lista de la compra. También puedes crear los tuyos.
- **Ruleta** para cuando no os decidís: la peli ganadora se puede poner en el próximo plan libre o en el plan que estás editando.
- **Animación mágica** al abrir la puerta del día: el regalo tiembla, explota en estrellas y aparecen la peli y la cena.
- **Avisos locales** (funcionan con la app cerrada): 19:00 del día anterior, 10:00 del día, **hora de empezar a cocinar según el menú** y hora de la peli.
- **Premium** (pago único con StoreKit 2): calendarios y ruleta ilimitados. Gratis: 2 calendarios y 6 pelis en la ruleta.

## Instalar en el iPhone

1. Abre `ios/CineAdviento/CineAdviento.xcodeproj`.
2. En la barra lateral, pulsa el proyecto azul **CineAdviento** → en **TARGETS** elige **CineAdviento** → pestaña **Signing & Capabilities** → marca *Automatically manage signing* → en **Team** elige tu Apple ID.
   Si no aparece: *Xcode → Settings → Accounts → +* y añade tu Apple ID.
   Si dice que el bundle id está ocupado, cambia `com.cineadviento.app` por otro (p. ej. `com.tunombre.cineadviento`).
3. Elige «iPhone de Jorge» como destino y pulsa ▶︎.
4. En el iPhone: *Ajustes → Privacidad y seguridad → Modo de desarrollador* y *Ajustes → General → VPN y gestión de dispositivos* → confía en tu certificado.

Con Apple ID gratuito la app caduca a los 7 días (se reinstala con ▶︎ y no se pierden los datos).

## TMDB (buscador de películas)

IMDb no tiene API pública gratuita. La app usa **TMDB**, que es gratis para uso personal:
1. Crea una cuenta en themoviedb.org → *Ajustes → API* → pide una clave.
2. Pégala en la app (*Ajustes → Buscador de películas*) o en `Services/Secrets.swift` para que vaya incluida en la app.

Para **vender** la app, TMDB exige una licencia comercial y mostrar su atribución (ya está en Ajustes).

## Para publicarla en el App Store

- Cuenta de desarrollador de Apple (99 $/año).
- En App Store Connect, crea la compra no consumible `com.cineadviento.premium`.
- Comprueba que tienes derechos sobre las ilustraciones del calendario de ejemplo (salen de tu póster) y sobre los títulos y personajes de las películas que uses en el marketing.

## Compilación automática

`.github/workflows/ios.yml` compila la app en un Mac de GitHub en cada push.
