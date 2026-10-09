'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Bell, HelpCircle, Laptop, Lock, LogOut, Shield, Smartphone, User } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Banner, Btn, Dialog, Field, Label, LRow, Switch } from '@/components/kit';
import { useStore } from '@/lib/data/store';
import { U, useToast } from '@/lib/ui';

const SECTIONS = [
  ['profile', 'Profile', 'Name, about, phone', <User key="p" />],
  ['privacy', 'Privacy', 'Who can see your info', <Shield key="v" />],
  ['security', 'Security', 'Encryption & verification', <Lock key="s" />],
  ['notifications', 'Notifications', 'Sounds, previews, mentions', <Bell key="n" />],
  ['devices', 'Linked devices', 'Where you are signed in', <Laptop key="d" />],
  ['help', 'Help & support', 'FAQ and contact', <HelpCircle key="h" />],
] as const;

function Toggle({ label, sub, init = true }: { label: string; sub?: string; init?: boolean }) {
  const [on, setOn] = useState(init);
  return <LRow title={label} sub={sub} chev={false} right={<Switch on={on} onChange={setOn} label={label} />} />;
}

function Section({ s }: { s: string }) {
  const { state, me } = useStore();
  const toast = useToast();
  const u = state.users[me];
  const [name, setName] = useState(u.name);
  const [about, setAbout] = useState(u.about ?? '');
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
      <Label>Visibility</Label>
      <Toggle label="Last seen & online" sub="Show when you were last active" />
      <Toggle label="Read receipts" sub="Let others see when you read" />
      <Toggle label="Profile photo" sub="Visible to contacts" />
      <Toggle label="Group invites" sub="Allow anyone to add me" init={false} />
    </>);
    case 'security': return (<>
      <Banner tone="ok" icon={<Lock />}>Private chats and the Anonymous environment are end-to-end encrypted. Standard chats are encrypted in transit.</Banner>
      <Label>Protection</Label>
      <Toggle label="Two-step verification" init={false} />
      <Toggle label="Screen lock" sub="Require biometrics to open" init={false} />
      <Toggle label="Security notifications" sub="Alert when a key changes" />
    </>);
    case 'notifications': return (<>
      <Toggle label="Message notifications" />
      <Toggle label="Show previews" sub="Hide content on the lock screen when off" />
      <Toggle label="Calls" sub="Ring for incoming calls" />
      <Toggle label="Order updates" />
      <Toggle label="Mentions & reactions" init={false} />
    </>);
    case 'devices': return (<>
      <LRow icon={<Smartphone />} title="This phone" sub="Active now · Kathmandu" chev={false} />
      <LRow icon={<Laptop />} title="Chrome on Windows" sub="Last active 2 days ago" chev={false} right={<Btn kind="ghost" size="sm" onClick={() => toast('Device signed out')}>Sign out</Btn>} />
    </>);
    default: return (<>
      <LRow icon={<HelpCircle />} title="FAQ" sub="Answers to common questions" onClick={() => toast('FAQ')} />
      <LRow icon={<Bell />} title="Contact support" sub="support@systemboom.app" onClick={() => toast('Support contacted')} />
      <p className="t-mute" style={{ textAlign: 'center', marginTop: U(30) }}>SYSTEMBOOM · v1.0 prototype</p>
    </>);
  }
}

function Settings() {
  const s = useSearchParams().get('s');
  const router = useRouter();
  const [out, setOut] = useState(false);
  const sec = SECTIONS.find((x) => x[0] === s);
  return (
    <PageShell title={sec ? sec[1] : 'Settings'} active="profile" dock={!sec}>
      {sec ? <Section s={sec[0]} /> : (<>
        {SECTIONS.map(([k, t, sub, ic]) => <LRow key={k} icon={ic} title={t} sub={sub} onClick={() => router.push(`/settings/?s=${k}`)} />)}
        <div style={{ height: U(20) }} />
        <Btn kind="danger" block icon={<LogOut />} onClick={() => setOut(true)}>Log out</Btn>
        <Dialog open={out} onClose={() => setOut(false)} title="Log out?" text="You can sign back in anytime." confirm="Log out" onConfirm={() => router.push('/welcome/')} />
      </>)}
    </PageShell>
  );
}

export default function Page() { return <Suspense><Settings /></Suspense>; }
