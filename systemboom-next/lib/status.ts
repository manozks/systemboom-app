import type { OrderStatus } from '@/lib/data/types';

export const STATUS_COLOR: Record<OrderStatus, string> = { pending_payment: '#ffb02e', confirmed: '#5ab8f2', shipped: '#a78bfa', out_for_delivery: '#ff9a3a', delivered: '#35d07f', completed: '#35d07f', cancelled: '#ff6a5a' };
export const statusLabel = (s: string) => s.replace(/_/g, ' ').replace(/^\w/, (c) => c.toUpperCase());
