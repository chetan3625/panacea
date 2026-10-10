# Panacea Backend

This backend is built with Node.js, Express.js, and MongoDB.

## Setup

1. Update the values in `.env`.
2. Start MongoDB locally or provide a remote MongoDB connection string.
3. Run the server:

```bash
npm install
npm run dev
```

## API Endpoints

### Auth

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`

### Patients

- `GET /api/patients`
- `POST /api/patients`
- `GET /api/patients/:id`

## Example .env

```env
PORT=5000
MONGO_URI=mongodb://127.0.0.1:27017/panacea
JWT_SECRET=your_super_secret_key
CLIENT_URL=http://localhost:3000
NODE_ENV=development
```
