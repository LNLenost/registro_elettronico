import { createHash, randomBytes } from 'node:crypto'
import { initializeApp } from 'firebase-admin/app'
import { getFirestore } from 'firebase-admin/firestore'
import { defineSecret } from 'firebase-functions/params'
import { onRequest } from 'firebase-functions/v2/https'
import type { Request, Response } from 'express'
import { encryptSessionToken } from './crypto.js'

initializeApp()
const db = getFirestore()
const classeVivaApiKey = defineSecret('CLASSEVIVA_API_KEY')
const sessionEncryptionKey = defineSecret('SESSION_ENCRYPTION_KEY')
const attempts = new Map<string, { count: number; resetAt: number }>()
const sessionMaxAge = 60 * 60 * 8

function hash(value: string) {
  return createHash('sha256').update(value).digest('hex')
}

function cookie(request: string | undefined, name: string) {
  return request?.split(';').map((item) => item.trim()).find((item) => item.startsWith(`${name}=`))?.slice(name.length + 1)
}

function limit(ip: string) {
  const now = Date.now()
  for (const [key, value] of attempts) if (value.resetAt <= now) attempts.delete(key)
  const current = attempts.get(ip) ?? { count: 0, resetAt: now + 15 * 60_000 }
  current.count += 1
  attempts.set(ip, current)
  return current.count <= 8
}

function sessionCookie(value: string, maxAge = sessionMaxAge) {
  return `cv_session=${value}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=${maxAge}`
}

async function session(request: Request, response: Response): Promise<void> {
  const token = cookie(request.headers.cookie, 'cv_session')
  if (!token) {
    response.status(200).json({ authenticated: false })
    return
  }
  const snapshot = await db.collection('classevivaSessions').doc(hash(token)).get()
  if (!snapshot.exists || snapshot.data()?.expiresAt?.toMillis?.() <= Date.now()) {
    response.setHeader('Set-Cookie', sessionCookie('', 0))
    response.status(200).json({ authenticated: false })
    return
  }
  response.status(200).json({ authenticated: true, name: snapshot.data()?.name ?? 'Studente' })
}

export const classevivaApi = onRequest(
  { region: 'europe-west1', secrets: [classeVivaApiKey, sessionEncryptionKey] },
  async (request, response) => {
    response.setHeader('Cache-Control', 'no-store')
    if (request.method === 'GET' && request.path === '/api/session') {
      await session(request, response)
      return
    }

    if (request.method === 'DELETE' && request.path === '/api/session') {
      const token = cookie(request.headers.cookie, 'cv_session')
      if (token) await db.collection('classevivaSessions').doc(hash(token)).delete()
      response.setHeader('Set-Cookie', sessionCookie('', 0))
      response.status(204).end()
      return
    }

    if (request.method !== 'POST' || request.path !== '/api/session') {
      response.status(404).json({ error: 'Non trovato' })
      return
    }
    const ip = request.ip || 'unknown'
    if (!limit(ip)) {
      response.status(429).json({ error: 'Troppi tentativi. Riprova più tardi.' })
      return
    }

    const ident = typeof request.body?.ident === 'string' ? request.body.ident.trim() : ''
    const password = typeof request.body?.password === 'string' ? request.body.password : ''
    if (!ident || ident.length > 80 || !password || password.length > 256) {
      response.status(400).json({ error: 'Credenziali non valide' })
      return
    }

    try {
      const upstream = await fetch('https://web.spaggiari.eu/rest/v1/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'CVVS/std/4.2.3',
          'Z-Dev-Apikey': classeVivaApiKey.value(),
        },
        body: JSON.stringify({ ident, pass: password, uid: ident }),
      })
      const data = await upstream.json() as { token?: string; firstName?: string; lastName?: string }
      if (!upstream.ok || !data.token) {
        response.status(401).json({ error: 'Accesso ClasseViva non riuscito' })
        return
      }

      const opaque = randomBytes(32).toString('base64url')
      const encrypted = encryptSessionToken(data.token, sessionEncryptionKey.value())
      await db.collection('classevivaSessions').doc(hash(opaque)).set({
        token: encrypted.ciphertext,
        tokenIv: encrypted.iv,
        tokenTag: encrypted.tag,
        name: [data.firstName, data.lastName].filter(Boolean).join(' ') || 'Studente',
        expiresAt: new Date(Date.now() + sessionMaxAge * 1000),
      })
      response.setHeader('Set-Cookie', sessionCookie(opaque))
      response.status(200).json({ authenticated: true, name: [data.firstName, data.lastName].filter(Boolean).join(' ') || 'Studente' })
      return
    } catch {
      response.status(503).json({ error: 'Servizio ClasseViva non raggiungibile' })
    }
  },
)
