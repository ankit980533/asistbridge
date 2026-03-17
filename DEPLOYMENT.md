# Deployment Guide

## Step 1: Deploy Backend on Render.com

1. Go to https://render.com and sign up (free)

2. Click "New" → "Web Service"

3. Connect your GitHub repo (push this code to GitHub first)

4. Configure:
   - **Name**: assistbridge-backend
   - **Root Directory**: backend
   - **Runtime**: Java
   - **Build Command**: `./mvnw clean install -DskipTests`
   - **Start Command**: `java -jar target/assistbridge-backend-1.0.0.jar`

5. Add Environment Variables:
   - `SPRING_DATA_MONGODB_URI` = `mongodb+srv://asistbridge:ankitraj@asistbridge.b278da3.mongodb.net/assistbridge`
   - `JWT_SECRET` = (generate a random 64-char string)

6. Click "Create Web Service"

7. Wait for deployment. You'll get URL like: `https://assistbridge-backend.onrender.com`

---

## Step 2: Deploy Admin Dashboard on Vercel

1. Go to https://vercel.com and sign up (free)

2. Click "Add New" → "Project"

3. Import your GitHub repo

4. Configure:
   - **Root Directory**: admin-dashboard
   - **Framework Preset**: Next.js

5. Add Environment Variable:
   - `NEXT_PUBLIC_API_URL` = `https://assistbridge-backend.onrender.com/api`

6. Click "Deploy"

7. You'll get URL like: `https://assistbridge-admin.vercel.app`

---

## Step 3: Update Mobile App

Update `mobile/lib/utils/constants.dart`:

```dart
static const String baseUrl = 'https://assistbridge-backend.onrender.com/api';
```

---

## Push to GitHub First

```bash
# Initialize git if not done
git init

# Add all files
git add .

# Commit
git commit -m "Prepare for deployment"

# Add remote (create repo on GitHub first)
git remote add origin https://github.com/YOUR_USERNAME/assistbridge.git

# Push
git push -u origin main
```

---

## MongoDB Atlas Setup (Already Done)

Your connection string: `mongodb+srv://asistbridge:ankitraj@asistbridge.b278da3.mongodb.net/assistbridge`

Make sure to:
1. Go to MongoDB Atlas → Network Access
2. Add `0.0.0.0/0` to allow connections from anywhere (for Render)

---

## Notes

- Render free tier sleeps after 15 min of inactivity (first request takes ~30s to wake)
- Vercel free tier is generous for frontend
- MongoDB Atlas M0 is free forever (512MB storage)
