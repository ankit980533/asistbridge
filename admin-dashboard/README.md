# AssistBridge Admin Dashboard

Next.js admin dashboard for AssistBridge platform.

## Requirements

- Node.js 18+
- npm or yarn

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env.local`:
```
NEXT_PUBLIC_API_URL=http://localhost:8080/api
```

## Run

```bash
# Development
npm run dev

# Build
npm run build

# Production
npm start
```

## Features

- Dashboard with statistics
- View and filter all help requests
- Assign volunteers to requests
- Manage users and volunteers
- Real-time updates

## Deployment

Deploy to Vercel:
```bash
npm install -g vercel
vercel
```

## Tech Stack

- Next.js 14
- React 18
- TailwindCSS
- Zustand (state management)
- Axios (HTTP client)
- Lucide React (icons)
