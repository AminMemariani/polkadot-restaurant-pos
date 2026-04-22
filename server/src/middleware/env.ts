import { readFileSync, existsSync } from 'node:fs';
import { resolve } from 'node:path';

export interface Env {
  PORT: number;
  STRIPE_SECRET_KEY: string;
  STRIPE_WEBHOOK_SECRET: string;
  ALLOWED_ORIGINS: string[];
}

let cached: Env | null = null;

/// Read environment from process.env, falling back to a `.env` file in the
/// project root. Keep dependency-free so the server boots in containers
/// where dotenv isn't installed.
export function getEnv(): Env {
  if (cached) return cached;

  loadDotEnvIfPresent();

  const required = (name: string): string => {
    const v = process.env[name];
    if (!v) throw new Error(`Missing required env var: ${name}`);
    return v;
  };

  cached = {
    PORT: Number(process.env.PORT ?? 8080),
    STRIPE_SECRET_KEY: required('STRIPE_SECRET_KEY'),
    STRIPE_WEBHOOK_SECRET: required('STRIPE_WEBHOOK_SECRET'),
    ALLOWED_ORIGINS: (process.env.ALLOWED_ORIGINS ?? '')
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean),
  };
  return cached;
}

function loadDotEnvIfPresent(): void {
  const path = resolve(process.cwd(), '.env');
  if (!existsSync(path)) return;
  const text = readFileSync(path, 'utf8');
  for (const raw of text.split('\n')) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;
    const eq = line.indexOf('=');
    if (eq === -1) continue;
    const key = line.slice(0, eq).trim();
    let value = line.slice(eq + 1).trim();
    // Strip surrounding quotes
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    if (process.env[key] === undefined) process.env[key] = value;
  }
}
