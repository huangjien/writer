Stage 1 together. If you want, I can also scaffold and run commands for you in your workspace.

**Project Overview**

- Flutter app with Supabase for content management and auth
- Clean reader UI with customizable font, size, spacing, theme
- Built-in TTS with continuous playback, looping across chapters
- Recent chapters tracking (last 3), reading progress and viewport tracking
- Multi-language UI and TTS voices
- Offline caching for downloaded chapters

**Prerequisites**

- Platforms: confirm target platforms (Android, iOS, Web, macOS)
- Accounts: a Supabase project ready (or I’ll help set it up)
- Local tooling: Flutter SDK, a device/emulator, optional Supabase CLI

**High-Level Plan**

- Stage 1: Environment setup + Flutter project scaffold
- Stage 2: Supabase project + schema + RLS policies
- Stage 3: Flutter dependencies and app architecture
- Stage 4: Reader UI scaffold with navigation and viewport tracking
- Stage 5: TTS engine integration and continuous playback controller
- Stage 6: Reading progress persistence (scroll/TTS positions)
- Stage 7: Recent chapters tracking and quick access UI
- Stage 8: Offline caching of chapters and sync strategy
- Stage 9: Multi-language UI and TTS voice switching
- Stage 10: Polishing, testing, and performance

If this plan looks good, we’ll proceed through each stage, confirming key decisions before moving on.

**Stage 1 — Setup & Scaffolding**

- Install Flutter (macOS): use official installer or `brew install --cask flutter`
- Verify install: `flutter doctor` and resolve any issues
- Enable web (optional): `flutter config --enable-web`
- Create project in your workspace:
    - `cd /Users/huangjien/workspace/authorconsole`
    - `flutter create writer`
    - `cd writer`
- Run in browser (fastest to preview): `flutter run -d chrome`

Tell me if you want me to run these commands for you now. Otherwise, once you’ve completed Stage 1, say “Stage 1 done” and we’ll proceed.

**Stage 2 — Supabase Setup**

- Create a new Supabase project at [supabase.com](http://supabase.com/) and grab:
    - `SUPABASE_URL`
    - `SUPABASE_ANON_KEY`
- Database schema (public content + user-specific data):
    - Novels and chapters (public readable when `is_public=true`)
    - User progress per chapter (private per user)
    - Optional: materialized view for “recent chapters” or compute from progress

SQL to apply in Supabase (Database → SQL Editor):

```
-- Novels
create table public.novels (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  author text,
  description text,
  cover_url text,
  language_code text not null default 'en',
  is_public boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Chapters
create table public.chapters (
  id uuid primary key default gen_random_uuid(),
  novel_id uuid not null references public.novels(id) on delete cascade,
  idx int not null,
  title text,
  content text not null,
  language_code text not null default 'en',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (novel_id, idx)
);

-- Progress per user and chapter
create table public.user_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  novel_id uuid not null references public.novels(id) on delete cascade,
  chapter_id uuid not null references public.chapters(id) on delete cascade,
  scroll_offset double precision not null default 0,
  tts_char_index int not null default 0,
  updated_at timestamptz not null default now(),
  primary key (user_id, chapter_id)
);

-- Policies: Public read on novels/chapters if is_public
alter table public.novels enable row level security;
create policy "Public read novels"
on public.novels for select
using (is_public = true);

alter table public.chapters enable row level security;
create policy "Public read chapters"
on public.chapters for select
using (exists (
  select 1 from public.novels n
  where n.id = chapters.novel_id and n.is_public = true
));

-- Policies: per-user read/write on progress
alter table public.user_progress enable row level security;
create policy "Read own progress"
on public.user_progress for select
using (auth.uid() = user_progress.user_id);

create policy "Upsert own progress"
on public.user_progress for insert
with check (auth.uid() = user_progress.user_id);

create policy "Update own progress"
on public.user_progress for update
using (auth.uid() = user_progress.user_id)
with check (auth.uid() = user_progress.user_id);

```

We can add more later (e.g., tags, favorites, downloads meta) as needed.

**Stage 3 — Flutter Dependencies & Architecture**

- Add packages:
    - `supabase_flutter` for DB/auth
    - `flutter_tts` for text-to-speech
    - `go_router` for routing
    - `hooks_riverpod` or `riverpod` for state management
    - `isar` (or `hive`) for offline caching; add `isar_flutter_libs`
    - `shared_preferences` for small settings (font size, theme)
    - `intl` for localization
- Suggested folder structure:
    - `lib/app.dart` and `lib/main.dart`
    - `lib/core/` (supabase client, models, services)
    - `lib/features/reader/` (screens, widgets, controllers)
    - `lib/features/library/` (listing novels/chapters, recent)
    - `lib/features/settings/` (language, TTS voice, theme)
    - `lib/state/` (providers)
    - `lib/routing/` (go_router setup)
- Supabase init in `main.dart`:
    - `Supabase.initialize(url: ..., anonKey: ...)`
    - Load from `-dart-define` or a `.env` loader with care (avoid committing secrets)

**Stage 4 — Reader UI Scaffold**

- Reader page with:
    - Title bar: novel title, chapter navigation, TTS controls
    - Scrollable text with viewport tracking
    - Quick access to recent chapters (last 3 by `user_progress.updated_at`)
- Navigation:
    - `go_router` routes: `/library`, `/novel/:id`, `/novel/:id/chapter/:idx`, `/settings`

**Stage 5 — TTS Integration & Playback**

- Use `flutter_tts`: initialize, set language/voice/rate, `speak`, `pause`, `stop`
- Build `TtsController`:
    - Input: chapter content list (for current and next)
    - Segmentation: sentence/paragraph chunks to avoid long calls
    - Events: handle “completed” to advance to next chunk/chapter
    - Looping: when last chapter ends, go to first if loop enabled
    - Persist `tts_char_index` regularly to `user_progress`

Skeleton idea:

```
class TtsController {
  final FlutterTts tts;
  bool looping;
  int charIndex;
  Future<void> speakChapter(String content);
  Future<void> nextChapter();
  Future<void> pause();
  Future<void> stop();
}

```

**Stage 6 — Progress & Viewport Tracking**

- For scroll: listen to `ScrollController` changes; debounce and persist `scroll_offset` to Supabase
- For TTS: persist `tts_char_index` on chunk completion or every N seconds
- Restore positions when opening a chapter

**Stage 7 — Recent Chapters**

- Query last 3 `user_progress` entries ordered by `updated_at desc`
- Show in Library and Reader header for quick navigation

**Stage 8 — Offline Reading**

- Cache chapters locally (e.g., `isar`):
    - `ChapterCache { chapterId, novelId, idx, title, content, updatedAt }`
- Sync strategy:
    - On chapter open: check local cache, compare `updated_at` with server
    - Download selected novel for offline via “Download” button
    - Evict LRU or by size limit

**Stage 9 — Multi-language**

- UI localization with `intl` and `flutter_localizations`
- TTS voice/language switching:
    - List voices per platform
    - Map app language preference to TTS language code

**Stage 10 — Testing & Polish**

- Widget tests for Reader scrolling and resume
- Unit tests for `TtsController` state machine
- Integration tests for Supabase data flows
- Performance: lazy-loading chapters, chunked TTS, caching

**Configuration Snippets**

- Run app with secrets:
    - `flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
- Access in code:
    - `const supabaseUrl = String.fromEnvironment('SUPABASE_URL');`
    - `const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');`

**Key Decisions To Confirm**

- Target platforms: Android/iOS/Web/macOS
- State management: Riverpod vs Bloc (I’ll default to Riverpod)
- Offline DB: `isar` vs `hive` (I’ll default to `isar`)
- Localization library: `intl` (default) vs `easy_localization`
- Public vs gated content: should novels be public readable?