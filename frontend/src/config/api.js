// frontend/src/config/api.js
// Base URL of the backend API.
// Locally: http://localhost:5000/api. On Vercel: set VITE_API_URL in the project settings.
export const API_BASE = import.meta.env.VITE_API_URL || "http://localhost:5000/api";
