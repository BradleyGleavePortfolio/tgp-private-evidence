import 'reflect-metadata';
import { HealthController } from './src/health/health.controller';
(async () => {
  const prisma = { $queryRaw: () => new Promise<never>(() => {}) };
  const controller = new HealthController(prisma as never);
  const res = { status: (code: number) => { console.log('status', code); return res; } };
  const outcome = controller.readiness(res as never);
  const winner = await Promise.race([
    outcome.then(() => 'settled'),
    new Promise((resolve) => setTimeout(() => resolve('still pending after 6000ms (> fly timeout 5s)'), 6000)),
  ]);
  console.log(`head=${process.env.HEAD} readiness outcome: ${winner}`);
  process.exit(0);
})();
