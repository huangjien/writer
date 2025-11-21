/*
 * Import a novel and its chapters from a directory of Markdown files into Supabase.
 *
 * Usage:
 *   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... \
 *   node scripts/import_novel_from_md.js \
 *     --dir "/Users/huangjien/workspace/blog/Content" \
 *     --title "随遇而安" \
 *     --author "Jien Huang" \
 *     --lang zh
 *
 * Requirements:
 * - Uses Supabase service role key (bypasses RLS for inserts/updates)
 * - Expects chapter files named "<number>_<title>.md" (e.g., 1_开篇.md)
 */

const fs = require('fs');
const path = require('path');
const { createClient } = require('@supabase/supabase-js');

const ENV = {
  SUPABASE_URL: process.env.SUPABASE_URL,
  SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY,
};

function die(message, error) {
  console.error(`Error: ${message}`);
  if (error) console.error(error);
  process.exit(1);
}

function parseArgs(argv) {
  const args = { dir: undefined, title: undefined, author: undefined, lang: 'zh' };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--dir') args.dir = argv[++i];
    else if (a === '--title') args.title = argv[++i];
    else if (a === '--author') args.author = argv[++i];
    else if (a === '--lang') args.lang = argv[++i];
    else die(`Unknown argument: ${a}`);
  }
  return args;
}

function assertEnv() {
  if (!ENV.SUPABASE_URL) die('SUPABASE_URL env var is required');
  if (!ENV.SUPABASE_SERVICE_ROLE_KEY) die('SUPABASE_SERVICE_ROLE_KEY env var is required');
  // Validate that the provided key is a service role key to avoid RLS errors
  try {
    const parts = ENV.SUPABASE_SERVICE_ROLE_KEY.split('.');
    if (parts.length !== 3) die('SUPABASE_SERVICE_ROLE_KEY does not look like a JWT');
    // Decode base64url payload
    const b64 = parts[1].replace(/-/g, '+').replace(/_/g, '/');
    const pad = b64.length % 4 === 2 ? '==' : b64.length % 4 === 3 ? '=' : '';
    const json = Buffer.from(b64 + pad, 'base64').toString('utf8');
    const payload = JSON.parse(json);
    if (payload.role !== 'service_role') {
      die(`Provided key role is "${payload.role}", expected "service_role". Use the Service Role key from Supabase Project Settings → API.`);
    }
  } catch (e) {
    die('Failed to validate SUPABASE_SERVICE_ROLE_KEY', e);
  }
}

function assertArgs(args) {
  if (!args.dir) die('--dir is required');
  if (!args.title) die('--title is required');
  if (!args.author) die('--author is required');
}

function parseChapterFilename(fileName) {
  // Expected format: "<number>_<title>.md". Exactly one underscore separator.
  const ext = path.extname(fileName);
  if (ext.toLowerCase() !== '.md') return null;
  const base = path.basename(fileName, ext);
  const parts = base.split('_');
  if (parts.length !== 2) return null;
  const idx = Number.parseInt(parts[0].trim(), 10);
  if (!Number.isFinite(idx)) return null;
  const title = parts[1].trim();
  return { idx, title };
}

function loadChaptersFromDir(dirPath) {
  const entries = fs.readdirSync(dirPath, { withFileTypes: true });
  const chapters = [];
  for (const entry of entries) {
    if (!entry.isFile()) continue;
    const fileName = entry.name;
    const parsed = parseChapterFilename(fileName);
    if (!parsed) continue; // skip non-matching files
    const fullPath = path.join(dirPath, fileName);
    const content = fs.readFileSync(fullPath, 'utf8');
    chapters.push({ idx: parsed.idx, title: parsed.title, content, fileName });
  }
  // Sort by idx ascending
  chapters.sort((a, b) => a.idx - b.idx);
  if (chapters.length === 0) die('No matching chapter files found in directory');
  return chapters;
}

async function ensureNovel(client, { title, author, lang }) {
  const { data: existing, error: selectErr } = await client
    .from('novels')
    .select('id')
    .eq('title', title)
    .eq('author', author)
    .limit(1)
    .maybeSingle();
  if (selectErr) die('Failed to query existing novel', selectErr);
  if (existing && existing.id) {
    console.log(`Found existing novel: ${existing.id}`);
    return existing.id;
  }
  const { data: inserted, error: insertErr } = await client
    .from('novels')
    .insert({ title, author, language_code: lang, is_public: true })
    .select('id')
    .single();
  if (insertErr) die('Failed to insert novel', insertErr);
  console.log(`Created novel: ${inserted.id}`);
  return inserted.id;
}

async function upsertChapter(client, chapter, novelId, lang) {
  const payload = {
    novel_id: novelId,
    idx: chapter.idx,
    title: chapter.title,
    content: chapter.content,
    language_code: lang,
  };
  const { error } = await client
    .from('chapters')
    .upsert(payload, { onConflict: 'novel_id,idx' });
  if (error) die(`Failed to upsert chapter idx=${chapter.idx} (${chapter.fileName})`, error);
}

async function main() {
  assertEnv();
  const args = parseArgs(process.argv);
  assertArgs(args);

  const client = createClient(ENV.SUPABASE_URL, ENV.SUPABASE_SERVICE_ROLE_KEY);

  const chapters = loadChaptersFromDir(args.dir);
  console.log(`Loaded ${chapters.length} chapters from ${args.dir}`);

  const novelId = await ensureNovel(client, { title: args.title, author: args.author, lang: args.lang });

  let count = 0;
  for (const ch of chapters) {
    await upsertChapter(client, ch, novelId, args.lang);
    count++;
    console.log(`Upserted chapter idx=${ch.idx} title="${ch.title}"`);
  }
  console.log(`Import completed. Novel=${args.title} chapters=${count}`);
}

main().catch((e) => die('Unhandled error during import', e));