import './App.css'
import { useEffect, useMemo, useRef, useState } from 'react'
import { Client } from '@stomp/stompjs'
import SockJS from 'sockjs-client'

type LoginResponse = {
  message: string
  userId: string
  username: string
}

type UserProfile = {
  userId: string
  username: string
  firstName: string
  lastName: string
  profilePicture?: string | null
  bio?: string | null
  isVerified?: boolean
  phoneNumber?: string | null
}

type MessageStatus = 'SENT' | 'DELIVERED' | 'READ'

type Message = {
  id?: string
  authorName: string
  receiverName: string
  message: string
  timestamp: string
  status?: MessageStatus
}

// Use Vite dev-server proxy to avoid browser CORS issues.
// If you later deploy the frontend separately, set these env vars to full URLs.
const USER_API_BASE = import.meta.env.VITE_USER_API_BASE ?? ''
const CHAT_API_BASE = import.meta.env.VITE_CHAT_API_BASE ?? ''
const WS_BASE = import.meta.env.VITE_WS_URL ?? '/ws'

function App() {
  const [usernameOrEmail, setUsernameOrEmail] = useState('')
  const [password, setPassword] = useState('')
  const [auth, setAuth] = useState<{ userId: string; username: string } | null>(() => {
    const raw = localStorage.getItem('connecta.auth')
    if (!raw) return null
    try {
      return JSON.parse(raw)
    } catch {
      return null
    }
  })

  const [friends, setFriends] = useState<UserProfile[]>([])
  const [activePeer, setActivePeer] = useState<UserProfile | null>(null)
  const [messages, setMessages] = useState<Message[]>([])
  const [draft, setDraft] = useState('')
  const [status, setStatus] = useState<string>('')
  const [showEmoji, setShowEmoji] = useState(false)
  const [showStickers, setShowStickers] = useState(false)

  const stompRef = useRef<Client | null>(null)
  const scrollRef = useRef<HTMLDivElement | null>(null)

  const fullName = useMemo(() => {
    if (!activePeer) return ''
    return `${activePeer.firstName ?? ''} ${activePeer.lastName ?? ''}`.trim() || activePeer.username
  }, [activePeer])

  useEffect(() => {
    if (!auth) return
    localStorage.setItem('connecta.auth', JSON.stringify(auth))
  }, [auth])

  useEffect(() => {
    if (!auth) return

    // Connect once after login.
    const client = new Client({
      webSocketFactory: () => {
        // SockJS uses HTTP(S) URL, but still connects to the same endpoint.
        const url = `${WS_BASE}?username=${encodeURIComponent(auth.username)}`
        return new SockJS(url)
      },
      reconnectDelay: 1500,
      heartbeatIncoming: 10000,
      heartbeatOutgoing: 10000,
      onConnect: () => {
        setStatus('Connected')
        client.subscribe('/user/queue/messages', (frame) => {
          try {
            const msg = JSON.parse(frame.body) as Message
            setMessages((prev) => mergeMessage(prev, msg))
          } catch {
            // ignore
          }
        })
      },
      onStompError: () => setStatus('STOMP error'),
      onWebSocketClose: () => setStatus('Disconnected'),
      onWebSocketError: () => setStatus('WebSocket error'),
    })

    stompRef.current = client
    client.activate()

    return () => {
      client.deactivate()
      stompRef.current = null
    }
  }, [auth])

  useEffect(() => {
    if (!auth) return
    void loadFriends()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [auth?.username])

  useEffect(() => {
    if (!auth || !activePeer) return
    void loadChatHistory(auth.username, activePeer.username)
  }, [auth, activePeer])

  useEffect(() => {
    scrollRef.current?.scrollIntoView({ block: 'end', behavior: 'smooth' })
  }, [messages.length])

  async function login(e: React.FormEvent) {
    e.preventDefault()
    setStatus('Logging in…')
    const res = await fetch(`${USER_API_BASE}/api/user/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ usernameOrEmail, password }),
    })
    const data = (await res.json()) as LoginResponse
    if (!res.ok) {
      setStatus(data?.message || 'Login failed')
      return
    }
    setAuth({ userId: data.userId, username: data.username })
    setStatus('Logged in')
  }

  async function loadFriends() {
    const res = await fetch(`${USER_API_BASE}/api/user/fetchusers`)
    const list = (await res.json()) as UserProfile[]
    setFriends(list.filter((u) => u.username !== auth?.username))
  }

  async function loadChatHistory(authorName: string, receiverName: string) {
    setStatus('Loading chat…')
    const url =
      `${CHAT_API_BASE}/api/chat/chatHistory?authorName=${encodeURIComponent(authorName)}` +
      `&receiverName=${encodeURIComponent(receiverName)}`
    const res = await fetch(url)
    const list = (await res.json()) as any[]
    const normalized: Message[] = list.map((m) => ({
      id: m.id,
      authorName: m.authorName,
      receiverName: m.receiverName,
      message: m.message,
      timestamp: typeof m.timestamp === 'string' ? m.timestamp : new Date(m.timestamp).toISOString(),
      status: m.status,
    }))
    setMessages(normalized.sort((a, b) => a.timestamp.localeCompare(b.timestamp)))
    setStatus('Ready')
  }

  function send() {
    if (!auth || !activePeer) return
    const text = draft.trim()
    if (!text) return

    const msg: Message = {
      authorName: auth.username,
      receiverName: activePeer.username,
      message: text,
      timestamp: new Date().toISOString(),
      status: 'SENT',
    }

    setDraft('')
    setMessages((prev) => mergeMessage(prev, { ...msg, id: crypto.randomUUID() }))

    const client = stompRef.current
    if (client?.connected) {
      client.publish({
        destination: '/app/private-message',
        body: JSON.stringify(msg),
      })
    } else {
      // REST fallback
      void fetch(`${CHAT_API_BASE}/api/chat/send`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(msg),
      })
    }
  }

  function sendSticker(id: string) {
    if (!auth || !activePeer) return
    const msg: Message = {
      authorName: auth.username,
      receiverName: activePeer.username,
      message: `sticker:${id}`,
      timestamp: new Date().toISOString(),
      status: 'SENT',
    }

    setMessages((prev) => mergeMessage(prev, { ...msg, id: crypto.randomUUID() }))

    const client = stompRef.current
    if (client?.connected) {
      client.publish({
        destination: '/app/private-message',
        body: JSON.stringify(msg),
      })
    } else {
      void fetch(`${CHAT_API_BASE}/api/chat/send`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(msg),
      })
    }
  }

  function logout() {
    localStorage.removeItem('connecta.auth')
    setAuth(null)
    setActivePeer(null)
    setMessages([])
    setStatus('Logged out')
  }

  if (!auth) {
    return (
      <div className="shell">
        <div className="card">
          <div className="brand">
            <div className="dot" />
            <div>
              <div className="title">Connecta</div>
              <div className="subtitle">Web chat</div>
            </div>
          </div>
          <form onSubmit={login} className="form">
            <label>
              Username or email
              <input value={usernameOrEmail} onChange={(e) => setUsernameOrEmail(e.target.value)} />
            </label>
            <label>
              Password
              <input
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                type="password"
                autoComplete="current-password"
              />
            </label>
            <button type="submit">Sign in</button>
          </form>
          <div className="hint">{status}</div>
          <div className="hint small">
            Configure endpoints with <code>VITE_USER_API_BASE</code>, <code>VITE_CHAT_API_BASE</code>,{' '}
            <code>VITE_WS_URL</code>.
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="app">
      <aside className="sidebar">
        <div className="me">
          <div>
            <div className="meName">{auth.username}</div>
            <div className="meSub">{status || '—'}</div>
          </div>
          <button className="ghost" onClick={logout}>
            Log out
          </button>
        </div>

        <div className="sectionTitle">Friends</div>
        <div className="list">
          {friends.map((f) => (
            <button
              key={f.userId}
              className={`row ${activePeer?.userId === f.userId ? 'active' : ''}`}
              onClick={() => setActivePeer(f)}
            >
              <div className="avatar">{(f.firstName?.[0] ?? f.username?.[0] ?? '?').toUpperCase()}</div>
              <div className="rowText">
                <div className="rowTitle">{`${f.firstName ?? ''} ${f.lastName ?? ''}`.trim() || f.username}</div>
                <div className="rowSub">@{f.username}</div>
              </div>
            </button>
          ))}
        </div>
      </aside>

      <main className="chat">
        <div className="chatHeader">
          <div className="chatTitle">{activePeer ? fullName : 'Select a friend'}</div>
          {activePeer && <div className="chatSub">@{activePeer.username}</div>}
        </div>

        <div className="chatBody">
          {activePeer ? (
            <>
              {messages
                .filter((m) => isInThread(m, auth.username, activePeer.username))
                .map((m, idx) => (
                  <div key={m.id ?? `${m.timestamp}-${idx}`} className={`bubbleRow ${m.authorName === auth.username ? 'me' : 'them'}`}>
                    <div className="bubble">
                      <div className="bubbleText">{renderMessage(m.message)}</div>
                      <div className="bubbleMeta">{formatTime(m.timestamp)}</div>
                    </div>
                  </div>
                ))}
              <div ref={scrollRef} />
            </>
          ) : (
            <div className="empty">
              Pick someone from the left to start chatting.
              <div className="emptySub">Real-time messages arrive via STOMP on `/user/queue/messages`.</div>
            </div>
          )}
        </div>

        <div className="chatInput">
          <div className="toolRow">
            <button
              className="tool"
              disabled={!activePeer}
              onClick={() => {
                setShowEmoji((v) => !v)
                setShowStickers(false)
              }}
              title="Emoji"
              type="button"
            >
              🙂
            </button>
            <button
              className="tool"
              disabled={!activePeer}
              onClick={() => {
                setShowStickers((v) => !v)
                setShowEmoji(false)
              }}
              title="Stickers"
              type="button"
            >
              🏷️
            </button>
          </div>
          <input
            disabled={!activePeer}
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter') send()
            }}
            placeholder={activePeer ? 'Message…' : 'Select a friend to message'}
          />
          <button disabled={!activePeer || !draft.trim()} onClick={send}>
            Send
          </button>
        </div>
        {activePeer && showEmoji && (
          <div className="picker">
            {['😀', '😅', '😂', '😍', '😘', '😎', '😭', '😤', '🤯', '👍', '🙏', '🔥', '✨', '🎉', '💯', '❤️'].map((e) => (
              <button key={e} className="pick" onClick={() => setDraft((d) => d + e)} type="button">
                {e}
              </button>
            ))}
          </div>
        )}
        {activePeer && showStickers && (
          <div className="picker">
            {[
              ['party', '🥳'],
              ['lol', '😂'],
              ['love', '😍'],
              ['fire', '🔥'],
              ['ok', '👌'],
              ['sad', '😢'],
              ['wow', '🤯'],
              ['thumbs', '👍'],
            ].map(([id, preview]) => (
              <button key={id} className="pick big" onClick={() => sendSticker(id)} type="button" title={id}>
                {preview}
              </button>
            ))}
          </div>
        )}
      </main>
    </div>
  )
}

export default App

function isInThread(m: Message, a: string, b: string) {
  const x = m.authorName
  const y = m.receiverName
  return (x === a && y === b) || (x === b && y === a)
}

function mergeMessage(prev: Message[], msg: Message): Message[] {
  // Best-effort dedupe: server messages may not have ids in our websocket payload.
  const key = `${msg.authorName}|${msg.receiverName}|${msg.timestamp}|${msg.message}`
  const exists = prev.some((m) => `${m.authorName}|${m.receiverName}|${m.timestamp}|${m.message}` === key)
  if (exists) return prev
  return [...prev, msg].sort((a, b) => a.timestamp.localeCompare(b.timestamp))
}

function formatTime(iso: string) {
  const d = new Date(iso)
  if (Number.isNaN(d.getTime())) return ''
  return d.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })
}

function renderMessage(text: string): React.ReactNode {
  const stickerId = parseStickerId(text)
  if (stickerId) {
    return <span style={{ fontSize: 46, lineHeight: '52px' }}>{stickerEmoji(stickerId)}</span>
  }
  return text
}

function parseStickerId(text: string): string | null {
  if (!text.startsWith('sticker:')) return null
  const id = text.slice('sticker:'.length).trim()
  return id ? id : null
}

function stickerEmoji(id: string): string {
  switch (id) {
    case 'party':
      return '🥳'
    case 'lol':
      return '😂'
    case 'love':
      return '😍'
    case 'fire':
      return '🔥'
    case 'ok':
      return '👌'
    case 'sad':
      return '😢'
    case 'wow':
      return '🤯'
    case 'thumbs':
      return '👍'
    default:
      return '✨'
  }
}
