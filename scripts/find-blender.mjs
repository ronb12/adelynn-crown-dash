/**
 * Resolve the Blender executable for FBX → GLB scripts.
 * Order: $BLENDER → scripts/blender-binary.path (one line) →
 *  Blender.app next to the repo folder (same parent as Adelynn Crown Dash) →
 *  /Applications/Blender.app → `which blender`
 */
import { spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

function readPathFile(file) {
  if (!fs.existsSync(file)) return null;
  const text = fs.readFileSync(file, 'utf8');
  for (const line of text.split(/\r?\n/)) {
    const t = line.trim();
    if (t && !t.startsWith('#')) return t;
  }
  return null;
}

export function findBlender() {
  if (process.env.BLENDER && fs.existsSync(process.env.BLENDER)) {
    return process.env.BLENDER;
  }

  const pathFile = path.join(__dirname, 'blender-binary.path');
  const fromFile = readPathFile(pathFile);
  if (fromFile && fs.existsSync(fromFile)) return fromFile;

  const root = path.join(__dirname, '..');
  const sibling = path.join(path.dirname(root), 'Blender.app', 'Contents', 'MacOS', 'Blender');
  if (fs.existsSync(sibling)) return sibling;

  if (process.platform === 'darwin') {
    const mac = '/Applications/Blender.app/Contents/MacOS/Blender';
    if (fs.existsSync(mac)) return mac;
  }

  const which = spawnSync('which', ['blender'], { encoding: 'utf8' });
  if (which.status === 0 && which.stdout.trim()) return which.stdout.trim();

  return null;
}
