import { NOW } from './mock'

/* Calm time formatting. Uses a fixed Nepal offset (UTC+5:45) and a fixed demo "today" so
   the statically exported pages render the same on the server and in the browser. */
const OFFSET = (5 * 60 + 45) * 60_000
const pad = (n: number) => String(n).padStart(2, '0')
const local = (ts: number) => new Date(ts + OFFSET)
const dayStart = (ts: number) => Math.floor((ts + OFFSET) / 86_400_000)
const WEEK = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
const MONTH = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
const daysAgo = (ts: number) => Math.max(0, dayStart(Math.max(NOW, 0)) - dayStart(ts))

export function clockTime(ts: number): string {
  const d = local(ts)
  let h = d.getUTCHours()
  const ampm = h >= 12 ? 'PM' : 'AM'
  h = h % 12 || 12
  return `${pad(h)}:${pad(d.getUTCMinutes())} ${ampm}`
}

export function listTime(ts: number): string {
  const days = daysAgo(ts)
  if (days === 0) return clockTime(ts)
  if (days === 1) return 'Yesterday'
  if (days < 7) return WEEK[local(ts).getUTCDay()].slice(0, 3)
  const d = local(ts)
  return `${d.getUTCDate()} ${MONTH[d.getUTCMonth()]}`
}

export function dayLabel(ts: number): string {
  const days = daysAgo(ts)
  if (days === 0) return 'Today'
  if (days === 1) return 'Yesterday'
  if (days < 7) return WEEK[local(ts).getUTCDay()]
  const d = local(ts)
  return `${d.getUTCDate()} ${MONTH[d.getUTCMonth()]}`
}

export function callTime(ts: number): string {
  const days = daysAgo(ts)
  const d = local(ts)
  const prefix = days === 0 ? 'Today' : days === 1 ? 'Yesterday' : `${d.getUTCDate()} ${MONTH[d.getUTCMonth()]}`
  return `${prefix}, ${clockTime(ts)}`
}

export function money(n: number): string {
  const s = String(Math.round(n));
  const last = s.slice(-3);
  const rest = s.slice(0, -3).replace(/\B(?=(\d{2})+(?!\d))/g, ',');
  return `Rs ${rest ? rest + ',' : ''}${last}`;
}
