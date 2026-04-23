import type { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';

import { getEnv } from './env.js';

/// Authenticated cashier context attached to the request after JWT verification.
/// All payment writes derive tenant/location/cashier from these fields, NOT
/// from request bodies — clients don't get to claim a different identity.
export interface CashierContext {
  id: string;
  tenantId: string | null;
  locationId: string | null;
  role: 'cashier' | 'manager' | 'admin';
  email?: string;
}

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      cashier?: CashierContext;
    }
  }
}

interface SupabaseClaims {
  sub: string;
  email?: string;
  role?: string; // Supabase role: anon | authenticated | service_role
  app_metadata?: {
    tenant_id?: string;
    location_id?: string;
    role?: 'cashier' | 'manager' | 'admin';
  };
}

/// Express middleware: verify a Supabase-issued JWT, attach [CashierContext]
/// to the request, and reject if the token is missing or invalid.
///
/// Usage:
///   app.use('/payments', requireCashier, paymentsRouter(stripe));
export function requireCashier(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  const header = req.header('Authorization') ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) {
    res.status(401).json({ error: 'unauthenticated' });
    return;
  }

  let claims: SupabaseClaims;
  try {
    claims = jwt.verify(token, getEnv().SUPABASE_JWT_SECRET, {
      algorithms: ['HS256'],
    }) as SupabaseClaims;
  } catch {
    res.status(401).json({ error: 'invalid_token' });
    return;
  }

  // Reject anon tokens — only signed-in cashiers can hit payment endpoints.
  if (claims.role !== 'authenticated' && claims.role !== 'service_role') {
    res.status(401).json({ error: 'unauthenticated' });
    return;
  }

  req.cashier = {
    id: claims.sub,
    tenantId: claims.app_metadata?.tenant_id ?? null,
    locationId: claims.app_metadata?.location_id ?? null,
    role: claims.app_metadata?.role ?? 'cashier',
    email: claims.email,
  };
  next();
}
