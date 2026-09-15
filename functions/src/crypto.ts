import { createCipheriv, createDecipheriv, randomBytes } from 'node:crypto'

function key(secret: string) {
  const value = Buffer.from(secret, 'base64')
  if (value.length !== 32) throw new Error('SESSION_ENCRYPTION_KEY must be a 32-byte base64 key')
  return value
}

export function encryptSessionToken(token: string, secret: string) {
  const iv = randomBytes(12)
  const cipher = createCipheriv('aes-256-gcm', key(secret), iv)
  const encrypted = Buffer.concat([cipher.update(token, 'utf8'), cipher.final()])
  return { ciphertext: encrypted.toString('base64'), iv: iv.toString('base64'), tag: cipher.getAuthTag().toString('base64') }
}

export function decryptSessionToken(ciphertext: string, iv: string, tag: string, secret: string) {
  const decipher = createDecipheriv('aes-256-gcm', key(secret), Buffer.from(iv, 'base64'))
  decipher.setAuthTag(Buffer.from(tag, 'base64'))
  return Buffer.concat([decipher.update(Buffer.from(ciphertext, 'base64')), decipher.final()]).toString('utf8')
}
