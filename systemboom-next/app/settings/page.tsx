'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Bell, BellRing, CheckCheck, CircleHelp, CloudOff, Eye, Info, KeyRound, Laptop, Lock, LogOut, MessageSquare, Monitor, Palette, Shield, ShieldCheck, Smartphone, Trash2, User, Users } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Banner, Btn, Dialog, Field, IBtn, Label, LRow, Seg, Switch } from '@/components/kit';
import { useStore } from '@/lib/data/store';
import { useConnectivity } from '@/lib/connectivity';
import { U, useToast } from '@/lib/ui';

const TITLES: Record<string, string> = { profile: 'Profile', privacy: 'Privacy', security: 'Security', notifications: 'Notifications', devices: 'Devices', help: 'Help & support' };

function Tog({ icon, title, sub, on, set }: { icon: React.ReactNode; title: string; sub?: string; on: boolean; set: (v: boolean) => void }) {
  return <LRow icon={icon} title={title} sub={sub} chev={false} right={<Switch on={on} onChange={set} label={title} />} />;
}

function Detail({ s }: { s: string }) {
  const { state, me } = useStore();
  const toast = useToast();
  const u = state.users[me];
  const [name, setName] = useState(u.name);
  const [about, setAbout] = useState(u.about ?? '');
  const [privacy, setPrivacy] = useState({ lastSeen: 'contacts', readReceipts: true, online: true });
  const [notif, setNotif] = useState({ messages: true, groups: true, calls: true, previews: true, sound: true });
  const [twoStep, setTwoStep] = useState(false);
  const [removeDevice, setRemoveDevice] = useState<string | null>(null);
  const [devices, setDevices] = useState([
    { id: 'd1', icon: <Smartphone />, name: 'iPhone 15 · This device', meta: 'Kathmandu · active now', me: true },
    { id: 'd2', icon: <Laptop />, name: 'MacBook Pro', meta: 'Kathmandu · 2 hours ago' },
    { id: 'd3', icon: <Monitor />, name: 'Web · Chrome', meta: 'Lalitpur · yesterday' },
  ]);
  switch (s) {
    case 'profile': return (
      <div className="stack">
        <div style={{ textAlign: 'center' }}><div style={{ display: 'inline-block' }}><Avatar name={name || 'You'} size={230} /></div></div>
        <Field label="Display name"><input value={name} onChange={(e) => setName(e.target.value)} /></Field>
        <Field label="About"><input value={about} onChange={(e) => setAbout(e.target.value)} /></Field>
        <Field label="Phone"><input value={u.phone ?? ''} readOnly /></Field>
        <Btn kind="primary" block onClick={() => toast('Profile saved')}>Save changes</Btn>
      </div>);
    case 'privacy': return (<>
      <Banner>Choose who can see your activity. Changes apply instantly.</Banner>
      <Label>Last seen &amp; online</Label>
      <Seg value={privacy.lastSeen} onChange={(v) => setPrivacy((p) => ({ ...p, lastSeen: v }))} options={[{ value: 'everyone', label: 'Everyone' }, { value: 'contacts', label: 'Contacts' }, { value: 'nobody', label: 'Nobody' }]} />
      <div style={{ height: U(18) }} />
      <Tog icon={<Eye />} title="Show online status" on={privacy.online} set={(v) => setPrivacy((p) => ({ ...p, online: v }))} />
      <Tog icon={<CheckCheck />} title="Read receipts" sub="If off, you won’t send or receive them" on={privacy.readReceipts} set={(v) => setPrivacy((p) => ({ ...p, readReceipts: v }))} />
      <LRow icon={<Shield />} title="Blocked contacts" sub="0 blocked" onClick={() => toast('Blocked list (prototype)')} />
    </>);
    case 'security': return (<>
      <Banner tone="ok" icon={<ShieldCheck />}>Private chats and all Anonymous communication are end-to-end encrypted. Standard chats are secured in transit and at rest.</Banner>
      <div style={{ height: U(18) }} />
      <Tog icon={<KeyRound />} title="Two-step verification" sub="Add a PIN for extra protection" on={twoStep} set={(v) => { setTwoStep(v); toast(v ? 'Two-step verification on' : 'Two-step verification off'); }} />
      <LRow icon={<ShieldCheck />} title="Encryption" sub="View security code & verify" onClick={() => toast('Security code (prototype)')} />
      <LRow icon={<Shield />} title="Login alerts" sub="Get notified of new sign-ins" onClick={() => toast('Login alerts on')} />
    </>);
    case 'notifications': return (<>
      <Tog icon={<MessageSquare />} title="Message notifications" on={notif.messages} set={(v) => setNotif((n) => ({ ...n, messages: v }))} />
      <Tog icon={<Users />} title="Group notifications" on={notif.groups} set={(v) => setNotif((n) => ({ ...n, groups: v }))} />
      <Tog icon={<Bell />} title="Call notifications" on={notif.calls} set={(v) => setNotif((n) => ({ ...n, calls: v }))} />
      <Tog icon={<Eye />} title="Message previews" sub="Show text in notifications" on={notif.previews} set={(v) => setNotif((n) => ({ ...n, previews: v }))} />
      <Tog icon={<BellRing />} title="Sound" on={notif.sound} set={(v) => setNotif((n) => ({ ...n, sound: v }))} />
    </>);
    case 'devices': return (<>
      <Banner>You’re signed in on these devices. Remove any you don’t recognise.</Banner>
      <div style={{ height: U(18) }} />
      {devices.map((d) => (
        <LRow key={d.id} icon={d.icon} title={d.name} sub={d.meta} chev={false}
          right={d.me ? <span className="pill" style={{ ['--t' as string]: '#35d07f' }}>This device</span> : <IBtn label={`Remove ${d.name}`} small tone="danger" onClick={() => setRemoveDevice(d.id)}><Trash2 /></IBtn>} />
      ))}
      <div style={{ height: U(10) }} />
      <Btn kind="ghost" block icon={<LogOut />} onClick={() => { setDevices((d) => d.filter((x) => x.me)); toast('Logged out of all other devices'); }}>Log out all other devices</Btn>
      <Dialog open={!!removeDevice} onClose={() => setRemoveDevice(null)} title="Remove device?" text={`${devices.find((d) => d.id === removeDevice)?.name ?? 'Device'} will be signed out immediately.`} confirm="Remove"
        onConfirm={() => { setDevices((d) => d.filter((x) => x.id !== removeDevice)); toast('Device removed'); setRemoveDevice(null); }} />
    </>);
    default: return (<>
      <LRow icon={<CircleHelp />} title="FAQ" sub="Answers to common questions" onClick={() => toast('Help centre (prototype)')} />
      <LRow icon={<Bell />} title="Contact support" sub="support@systemboom.app" onClick={() => toast('Support contacted')} />
      <p className="t-mute" style={{ textAlign: 'center', marginTop: U(30) }}>SYSTEMBOOM · v1.0 prototype</p>
    </>);
  }
}

function Settings() {
  const s = useSearchParams().get('s');
  const router = useRouter();
  const toast = useToast();
  const { state, me } = useStore();
  const { simulateOffline, setSimulateOffline } = useConnectivity();
  const [out, setOut] = useState(false);
  const mine = state.users[me];
  const sec = s && TITLES[s] ? s : null;
  return (
    <PageShell title={sec ? TITLES[sec] : 'Settings'} active="profile" dock={!sec}>
      {sec ? <Detail s={sec} /> : (<>
        <LRow icon={<Avatar name={mine.name} size={70} presence="online" />} title={mine.name} sub={mine.about} onClick={() => router.push('/profile/')} />
        <Label>Account</Label>
        <LRow icon={<User />} title="Profile" sub="Name, about, phone" onClick={() => router.push('/settings/?s=profile')} />
        <LRow icon={<Shield />} title="Privacy" sub="Last seen, read receipts, blocking" onClick={() => router.push('/settings/?s=privacy')} />
        <LRow icon={<Lock />} title="Security" sub="Encryption, two-step verification" onClick={() => router.push('/settings/?s=security')} />
        <LRow icon={<Bell />} title="Notifications" sub="Messages, groups, calls" onClick={() => router.push('/settings/?s=notifications')} />
        <LRow icon={<Smartphone />} title="Devices" sub="Linked devices & sessions" onClick={() => router.push('/settings/?s=devices')} />
        <Label>Preferences</Label>
        <LRow icon={<Palette />} title="Appearance" sub="Theme & display" onClick={() => router.push('/profile/')} />
        <LRow icon={<CircleHelp />} title="Help" sub="FAQ & support" onClick={() => router.push('/settings/?s=help')} />
        <LRow icon={<Info />} title="About" sub="SYSTEMBOOM Chat · Prototype" onClick={() => toast('SYSTEMBOOM Chat — Phase 2')} />
        <Label>Prototype</Label>
        <LRow icon={<CloudOff />} title="Simulate offline" sub="Demo the offline & retry experience" chev={false} right={<Switch on={simulateOffline} onChange={(v) => { setSimulateOffline(v); toast(v ? 'Offline mode simulated' : 'Back online'); }} label="Simulate offline" />} />
        <div style={{ height: U(20) }} />
        <Btn kind="danger" block icon={<LogOut />} onClick={() => setOut(true)}>Sign out</Btn>
        <Dialog open={out} onClose={() => setOut(false)} title="Sign out?" text="You’ll return to the welcome screen." confirm="Sign out" onConfirm={() => router.replace('/welcome/')} />
      </>)}
    </PageShell>
  );
}

export default function Page() { return <Suspense><Settings /></Suspense>; }
