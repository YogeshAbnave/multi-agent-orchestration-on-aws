# 🚀 Local Development Quick Start

## TL;DR - Get Running in 3 Steps

```powershell
# 1. Install dependencies
cd "D:\CloudAge Projects\AWS use case project\multi-agent-orchestration-on-aws\multi-agent-orchestration-on-aws\multi-agent-orchestration-on-aws\multi-agent-orchestration-on-aws"
npm install

# 2. Environment is already set up with mock values
# (Optional: Get real values - see below)

# 3. Start dev server
npm run -w frontend dev
```

Open browser: **http://localhost:3000**

---

## 📋 What You Need to Know

### ✅ What Works with Mock Values
- UI development
- Component styling
- Page navigation
- Layout testing

### ❌ What Doesn't Work with Mock Values
- User authentication
- API calls to backend
- File uploads
- Real data

---

## 🔧 Get Real AWS Values (Optional)

### If Backend is Already Deployed:

```powershell
npm run develop
# Select: "Refresh Local Environment"
```

### If Backend is NOT Deployed:

```powershell
npm run develop
# Select: "Deploy CDK Stack(s)"
# Then: "Refresh Local Environment"
```

---

## 📁 Project Structure

```
multi-agent-orchestration-on-aws/
├── src/
│   ├── frontend/              ← Frontend React app
│   │   ├── .env              ← Environment variables (mock values included)
│   │   ├── src/              ← Source code
│   │   └── package.json
│   └── backend/              ← AWS CDK backend
│       └── lib/              ← Infrastructure code
├── package.json              ← Root package (workspaces)
└── tools/cli/                ← Development CLI
```

---

## 🎯 Common Commands

### From Project Root:

```powershell
# Install all dependencies
npm install

# Run frontend dev server
npm run -w frontend dev

# Build frontend for production
npm run -w frontend build

# Run development CLI (interactive menu)
npm run develop

# Build backend (compile TypeScript)
npm run -w backend build
```

### From Frontend Directory (`src/frontend`):

```powershell
# Run dev server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

---

## 🐛 Troubleshooting

### "vite is not recognized"
```powershell
# Install dependencies first
npm install
```

### "Cannot find module"
```powershell
# Install in both root and frontend
npm install
cd src/frontend
npm install
```

### "Environment variables not loading"
```powershell
# Restart dev server
# Ctrl+C to stop
npm run dev
```

### "Authentication errors"
```powershell
# Get real AWS values
npm run develop
# Select: "Refresh Local Environment"
```

### Port 3000 already in use
```powershell
# Use different port
npm run -w frontend dev -- --port 3001
```

---

## 📚 Detailed Documentation

- **Environment Setup:** `src/frontend/ENV-SETUP-README.md`
- **Full Local Guide:** `QUICK-START-LOCAL.md`
- **Deployment Guide:** `README-DEPLOYMENT.md`

---

## 🎨 Development Workflow

### UI Development Only (No AWS):
1. Use mock values (already in `.env`)
2. Run `npm run -w frontend dev`
3. Develop UI components
4. Test layouts and styling

### Full Stack Development (With AWS):
1. Deploy backend: `npm run develop` → Deploy CDK
2. Get environment: `npm run develop` → Refresh Local Environment
3. Run frontend: `npm run -w frontend dev`
4. Test with real AWS services

---

## 🔐 Environment Variables

Located in: `src/frontend/.env`

**Current Status:** ✅ Mock values included (UI development only)

**To get real values:**
```powershell
npm run develop
# Select: "Refresh Local Environment"
```

**To manually edit:**
```powershell
# Edit src/frontend/.env
# See src/frontend/ENV-SETUP-README.md for details
```

---

## ⚡ Quick Tips

1. **Hot Reload:** Vite automatically reloads on file changes
2. **Mock Data:** Use mock values for UI development
3. **Real Backend:** Deploy to AWS for full functionality
4. **Port Change:** Add `-- --port 3001` to change port
5. **Clean Install:** Delete `node_modules` and run `npm install`

---

## 🆘 Need Help?

1. Check `ENV-SETUP-README.md` for environment issues
2. Check `QUICK-START-LOCAL.md` for detailed setup
3. Check `README-DEPLOYMENT.md` for AWS deployment
4. Run `npm run develop` for interactive CLI

---

**Happy Coding! 🎉**
