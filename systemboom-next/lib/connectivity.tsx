'use client';

import { createContext, useContext, useState, type ReactNode } from 'react';

/** "Simulate offline" demo switch (Settings) — sends fail with retry, payments can't complete. */
const Ctx = createContext<{ online: boolean; simulateOffline: boolean; setSimulateOffline: (v: boolean) => void }>({ online: true, simulateOffline: false, setSimulateOffline: () => {} });

export function ConnectivityProvider({ children }: { children: ReactNode }) {
  const [off, setOff] = useState(false);
  return <Ctx.Provider value={{ online: !off, simulateOffline: off, setSimulateOffline: setOff }}>{children}</Ctx.Provider>;
}

export const useConnectivity = () => useContext(Ctx);
export const useOnline = () => useContext(Ctx).online;
