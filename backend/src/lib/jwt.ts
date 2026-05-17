import jwt from 'jsonwebtoken'

const SECRET = process.env.JWT_SECRET || 'medinova_dev_secret'
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'medinova_refresh_secret'

export function signToken(payload: object, expiresIn = '7d') {
  return jwt.sign(payload, SECRET, { expiresIn } as jwt.SignOptions)
}

export function signRefreshToken(payload: object) {
  return jwt.sign(payload, REFRESH_SECRET, { expiresIn: '30d' } as jwt.SignOptions)
}

export function verifyToken(token: string): jwt.JwtPayload {
  return jwt.verify(token, SECRET) as jwt.JwtPayload
}

export function verifyRefreshToken(token: string): jwt.JwtPayload {
  return jwt.verify(token, REFRESH_SECRET) as jwt.JwtPayload
}
