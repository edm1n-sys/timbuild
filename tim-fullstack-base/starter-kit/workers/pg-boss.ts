import PgBoss from 'pg-boss'

const globalForBoss = globalThis as unknown as { boss: PgBoss | undefined }

export function getBoss() {
  if (!globalForBoss.boss) {
    globalForBoss.boss = new PgBoss(process.env.DATABASE_URL!)
  }
  return globalForBoss.boss
}

export async function startBoss() {
  const boss = getBoss()
  await boss.start()
  return boss
}

export async function stopBoss() {
  const boss = getBoss()
  await boss.stop()
}
