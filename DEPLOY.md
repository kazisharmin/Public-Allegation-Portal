# Running and deploying the Public Allegation Portal

The app has two parts, deployed as **two Vercel projects from this one repo**:

| Part | Folder | Hosted on |
| --- | --- | --- |
| Frontend (React + Vite) | `frontend/` | Vercel project #1 |
| Backend (Express API) | `backend/` | Vercel project #2 |
| Database (MySQL) + uploaded files | `backend/db/*.sql` | TiDB Cloud Starter (free, MySQL-compatible) |

Uploaded logos and attachments are stored in the database (`files` table) and served by
`GET /api/files/<token>/<name>`, so there is no separate file storage service.

The frontend forwards every `/api/...` request to the backend (see `frontend/vercel.json`),
so the browser only talks to one domain. That keeps cookies first-party and avoids CORS problems.

## Demo accounts (from `db/seed.sql`)

All passwords: `Demo@1234`

| Role | Email |
| --- | --- |
| User | `demo@portal.test` |
| Organization (public) | `city@greenfield.test` |
| Organization (private) | `registrar@northbridge.test` |

---

## 1. Run it on your laptop

1. Create a MySQL database (XAMPP, MySQL Workbench or the `mysql` command):
   ```sql
   CREATE DATABASE allegation_portal CHARACTER SET utf8mb4;
   ```
2. Load the tables and the demo data:
   ```bash
   mysql -u root -p allegation_portal < backend/db/schema.sql
   mysql -u root -p allegation_portal < backend/db/seed.sql
   ```
   (In MySQL Workbench: *File → Open SQL Script*, then run each file.)
3. Backend:
   ```bash
   cd backend
   cp .env.example .env      # then edit DB_PASS etc.
   npm install
   npm run dev               # http://localhost:5000/api/health should say "connected"
   ```
4. Frontend (new terminal):
   ```bash
   cd frontend
   npm install
   npm run dev               # open http://localhost:5173
   ```

---

## 2. Database: TiDB Cloud

1. Sign up at tidbcloud.com and create a **Starter** instance.
2. Click **Connect**, then copy host, port (4000), user and password.
3. Create a database called `allegation_portal`, then run `backend/db/schema.sql` and
   `backend/db/seed.sql` in TiDB's **SQL Editor** (paste and run each file).

## 3. Backend on Vercel

1. vercel.com → **Add New → Project** → import this repo.
2. **Root Directory:** `backend`. Leave the build settings empty; Vercel detects Express.
3. **Environment Variables:**

   | Name | Value |
   | --- | --- |
   | `DB_HOST` | your TiDB host |
   | `DB_PORT` | `4000` |
   | `DB_USER` | your TiDB user (looks like `xxxx.root`) |
   | `DB_PASS` | your TiDB password |
   | `DB_NAME` | `allegation_portal` |
   | `DB_SSL` | `true` |
   | `JWT_SECRET` | a long random string |
   | `CRON_SECRET` | another long random string |

4. **Deploy.** Then open `https://<backend>.vercel.app/api/health` and check that it says `"database":"connected"`.

The daily cleanup of withdrawn complaints runs through Vercel Cron (`backend/vercel.json`).

## 4. Frontend on Vercel

1. `frontend/vercel.json` forwards `/api` to `https://allegation-portal-api.vercel.app`. If your backend has a different domain, change it there.
2. In the frontend Vercel project (Root Directory `frontend`), add the environment variable
   `VITE_API_URL` = `/api`, then **redeploy**.
3. Open the site, log in with a demo account, and try filing a complaint.

## Limits

- Uploads: images, PDF, MP4, MP3, up to **4 MB** (Vercel caps request bodies at about 4.5 MB).
- Vercel Hobby cron runs at most once a day, which is enough for the 30-day cleanup.
