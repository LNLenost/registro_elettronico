import { useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import './App.css'

type Session = { authenticated: boolean; name?: string }
type Section = 'Home' | 'Voti' | 'Agenda' | 'Circolari' | 'Altro'

const sections: Section[] = ['Home', 'Voti', 'Agenda', 'Circolari', 'Altro']

function App() {
  const [session, setSession] = useState<Session | null>(null)
  const [ident, setIdent] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [section, setSection] = useState<Section>('Home')

  useEffect(() => {
    fetch('/api/session', { credentials: 'same-origin' })
      .then((response) => response.ok ? response.json() : { authenticated: false })
      .then(setSession)
      .catch(() => setSession({ authenticated: false }))
  }, [])

  async function login(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError('')
    setLoading(true)
    try {
      const response = await fetch('/api/session', {
        method: 'POST',
        credentials: 'same-origin',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ident, password }),
      })
      const data = await response.json() as Session & { error?: string }
      if (!response.ok) throw new Error(data.error ?? 'Accesso non riuscito')
      setPassword('')
      setSession(data)
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Accesso non riuscito')
    } finally {
      setLoading(false)
    }
  }

  async function logout() {
    await fetch('/api/session', { method: 'DELETE', credentials: 'same-origin' })
    setSession({ authenticated: false })
    setIdent('')
  }

  if (session === null) return <main className="loading">Apertura Registro elettronico…</main>

  if (!session.authenticated) {
    return <main className="login-page">
      <section className="login-card" aria-labelledby="login-title">
        <div className="cap" aria-hidden="true">⌂</div>
        <p className="eyebrow">REGISTRO ELETTRONICO</p>
        <h1 id="login-title">Bentornato</h1>
        <p className="lead">Accedi con le tue credenziali ClasseViva.</p>
        <form onSubmit={login}>
          <label>Codice utente<input autoComplete="username" value={ident} onChange={(event) => setIdent(event.target.value)} required /></label>
          <label>Password<input autoComplete="current-password" type="password" value={password} onChange={(event) => setPassword(event.target.value)} required /></label>
          {error && <p className="error" role="alert">{error}</p>}
          <button disabled={loading} type="submit">{loading ? 'Accesso in corso…' : 'Accedi'}</button>
        </form>
        <p className="disclaimer">Client non ufficiale. Le credenziali vengono inviate solo al servizio ClasseViva tramite una sessione protetta.</p>
      </section>
    </main>
  }

  return <div className="app-shell">
    <aside className="sidebar">
      <div className="brand"><span>⌂</span><strong>Registro<br />elettronico</strong></div>
      <nav aria-label="Navigazione principale">{sections.map((item) => <button key={item} className={section === item ? 'nav active' : 'nav'} onClick={() => setSection(item)}>{item}</button>)}</nav>
      <button className="logout" onClick={logout}>Esci</button>
    </aside>
    <main className="content">
      <header><div><p className="eyebrow">ANNO SCOLASTICO</p><h1>{section}</h1></div><span className="profile">{session.name ?? 'Studente'}</span></header>
      <section className="notice"><h2>Sincronizzazione web in arrivo</h2><p>La sessione ClasseViva è attiva. Questa pagina usa lo stesso percorso dell’app; le sezioni dati saranno collegate una alla volta al backend Firebase, senza esporre password o token nel browser.</p></section>
      <section className="cards">
        <article><span>Voti</span><strong>Consulta valutazioni e materie</strong></article>
        <article><span>Agenda</span><strong>Eventi, compiti e lezioni</strong></article>
        <article><span>Circolari</span><strong>Avvisi e allegati scolastici</strong></article>
      </section>
    </main>
    <nav className="mobile-nav">{sections.map((item) => <button key={item} className={section === item ? 'active' : ''} onClick={() => setSection(item)}>{item}</button>)}</nav>
  </div>
}

export default App
