import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { neon } from '@neondatabase/serverless';

const rootDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const schemaPath = path.join(rootDir, 'db', 'schema.sql');
const databaseUrl =
  process.env.DATABASE_URL ||
  process.env.POSTGRES_URL ||
  process.env.POSTGRES_PRISMA_URL;

if (!databaseUrl) {
  console.error('Missing DATABASE_URL. Set it to your Neon connection string and run again.');
  process.exit(1);
}

const schema = await fs.readFile(schemaPath, 'utf8');
const statements = schema
  .split(/;\s*(?:\n|$)/)
  .map(statement => statement.trim())
  .filter(Boolean);

const sql = neon(databaseUrl);

for (const statement of statements) {
  await sql.query(statement);
}

console.log(`Applied ${statements.length} Neon schema statements from ${schemaPath}`);

