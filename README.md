# Auth App - Rails 8 Native Authentication MVP

Proyecto base con autenticacion nativa de Rails 8, registro de usuarios, inicio de sesion y recuperacion de contrasena con Action Mailer.

## Requisitos

- Ruby 3.4+
- Rails 8.1+
- PostgreSQL 14+

## Setup local

1. Copia variables de entorno:

```bash
cp .env.example .env
```

2. Define credenciales en tu entorno (PowerShell):

```powershell
$env:PGHOST="localhost"
$env:PGPORT="5432"
$env:PGUSER="postgres"
$env:PGPASSWORD="tu_password"

$env:APP_HOST="localhost"
$env:APP_PORT="3000"

$env:SMTP_ADDRESS="smtp.gmail.com"
$env:SMTP_PORT="587"
$env:SMTP_DOMAIN="localhost"
$env:SMTP_USER="tu_correo@gmail.com"
$env:SMTP_PASS="tu_app_password"
$env:SMTP_AUTH="plain"
```

3. Instala dependencias y prepara DB:

```bash
bundle install
ruby bin/rails db:create
ruby bin/rails db:migrate
```

4. Inicia el servidor:

```bash
bin/dev
```

## Flujo de autenticacion

- Registro: `/registration/new`
- Login: `/session/new`
- Recuperacion: `/passwords/new`

Las contrasenas se guardan encriptadas mediante `has_secure_password` en la columna `password_digest`.

## Probar envio de correo

Con una cuenta de usuario creada:

```bash
ruby bin/rails console
UserMailer.reset_password(User.first).deliver_now
```

## Estructura MVP por componente

```
app/
	components/
		auth/
		layout/
		ui/
	controllers/
	mailers/
	models/
	views/
```

## GitHub

```bash
git init
git add .
git commit -m "feat: rails native auth mvp"
git branch -M main
git remote add origin <tu_repo_github>
git push -u origin main
```

## Deploy en Render

Este repo incluye:

- `Procfile`
- `render.yaml`

Pasos:

1. Sube el proyecto a GitHub.
2. En Render, crea un servicio desde el repo.
3. Carga variables de entorno necesarias (`SECRET_KEY_BASE`, SMTP y DB).
4. Ejecuta deploy.

### SMTP recomendado en Render (practico)

Para evitar timeouts con Gmail SMTP desde Render, usa Brevo como proveedor transaccional.

Variables recomendadas en Render:

```env
SMTP_PROVIDER=brevo
SMTP_ADDRESS=smtp-relay.brevo.com
SMTP_PORT=587
SMTP_DOMAIN=smtp-brevo.com
SMTP_AUTH=login
SMTP_TLS=false
SMTP_OPEN_TIMEOUT=30
SMTP_READ_TIMEOUT=30
SMTP_USER=<tu_login_brevo>
SMTP_PASS=<tu_smtp_key_brevo>
SMTP_FROM=<sender_verificado_en_brevo>
```

Con esta configuracion, puedes enviar correos de recuperacion a cualquier destinatario Gmail.
