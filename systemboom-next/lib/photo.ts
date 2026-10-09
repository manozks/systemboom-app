const PHOTO: Record<string, string> = { me: 'me', u_sita: 'cf1', u_anita: 'cf4', u_maya: 'cf4', u_deepa: 'cf1', u_bibek: 'cf5', u_prakash: 'cf5', u_rojan: 'cf5', u_arjun: 'cf5', u_dai: 'cf5', u_mom: 'cf4' };
const FACES = ['cf1', 'cf4', 'cf5'];

/** Deterministic demo profile photo for a user id (business accounts keep initials). */
export const photoOf = (id: string, business?: boolean): string | null => PHOTO[id] ?? (business ? null : FACES[[...id].reduce((a, c) => a + c.charCodeAt(0), 0) % FACES.length]);
