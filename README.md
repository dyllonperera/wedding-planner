# Wedding & Homecoming Planner

A shared planning tracker for two events — Wedding and Homecoming — covering vendors,
budget, checklist, and guest list. Anyone you share the link + credentials with can
open it and edit live (no login screen, so keep the link private).

## What it tracks (per event, kept separate)

- **Vendors** — category, name, contact, status (researching → contacted → booked →
  deposit paid → paid in full), price, deposit paid, notes.
- **Budget** — planned vs. actual per line item, with running totals and remaining
  balance.
- **Checklist** — tasks with due dates, auto-sorted so overdue/incomplete items float
  to the top; due dates turn red if overdue.
- **Guests** — side, RSVP status, plus-one, dietary notes, with a live headcount.

The top of the page has a ribbon tab to flip between **Wedding** — ivory, warm gold,
and rose gold, for the day function — and **Homecoming** — ivory, navy, and burgundy,
for the night function — plus a date field and countdown stamp for each.

## Everything added in this round

- **Live ticking countdown** — the hero stamp now counts down in real hours:minutes:seconds, not just days.
- **Milestone confetti** — the screen bursts into celebration automatically at 100/50/30/7/1/0 days left, and whenever a section hits 100% (every vendor booked, every task done, every guest confirmed). Each milestone only fires once per event (tracked locally per device).
- **Achievement pop-ups** — a little page-turn card announces each milestone, paired with the confetti.
- **Live presence** — since you and your fiancée share this app, a small "so-and-so is here" chip appears top-left when you're both viewing at once, and shows which world (Wedding/Homecoming) they're looking at. The first time each of you unlocks the app, it'll ask for a name once — that's all it needs.
- **Mood board** — a new tab per event for inspiration photos. Needs one extra one-time SQL step — see below.
- **Animated budget donut chart** — appears at the top of the Budget tab, breaking down planned spend by category.
- **Printable day-of run sheet** — the "🖨 Print day-of run sheet" button opens your browser's print dialog with a clean vendor/task/headcount summary. Choose "Save as PDF" there for a PDF copy.
- **Guest RSVP page + QR code** — the Guests tab now shows a QR code and shareable link (`rsvp.html?event=wedding` or `?event=homecoming`). Guests scan it, fill in their own RSVP, and it lands straight in your guest list. No PIN on that page — it's meant to be shared.

### One extra step: mood board storage

The Mood Board tab needs a storage bucket that isn't in your Supabase project yet. In your Supabase dashboard → **SQL Editor** → run just this (don't re-run the whole `schema.sql` — the rest already exists in your project and re-running it will error on duplicate policies):

```sql
insert into storage.buckets (id, name, public)
values ('moodboard', 'moodboard', true)
on conflict (id) do nothing;

create policy "moodboard anon read" on storage.objects for select using (bucket_id = 'moodboard');
create policy "moodboard anon upload" on storage.objects for insert with check (bucket_id = 'moodboard');
create policy "moodboard anon delete" on storage.objects for delete using (bucket_id = 'moodboard');
```

`schema.sql` in this folder has been updated too, so a brand-new Supabase project set up from scratch would get this automatically — this step is only needed because your project already exists.

### New file: rsvp.html

Upload `rsvp.html` to your repo alongside the others — it needs to sit next to `config.js` since it reuses the same Supabase credentials. No extra setup beyond that.

### One more step: party size + private invites

Guests are now private and per-person/household rather than one open link. This needs a
small database change — in Supabase → **SQL Editor**, run:

```sql
alter table guests add column if not exists party_size integer not null default 1;
update guests set party_size = 2 where plus_one = true and party_size = 1;
```

That adds a "how many people does this entry cover" number (defaults to 1), and
carries over anyone previously marked as a plus-one into a party of 2. The old
`plus_one` column is left in place untouched, just unused going forward.

**How it works now:** each row in the Guests tab — "Sam", "Mr & Mrs Perera", "Mr Ajith
and family" — has its own **Party size** you set manually (1, 2, 4, whatever's right).
Tap the 🔗 on any row to copy that person's own private RSVP link, which opens already
addressed to them by name — no open link, no strangers adding themselves. They just
confirm and adjust their own party size if needed. The Her side / His side capacity
bars now count total people (party size summed), not just entries.

### One more step: split vendor status into Status + Payment

Vendors now have two separate dropdowns — **Status** (Researching / Contacted /
Booked) and **Payment** (Not paid / Deposit paid / Paid in full) — instead of one
combined dropdown plus a separate checkbox. The deposit amount you enter now actually
shows up in its own column too (it was being collected but never displayed before).

Run this once in Supabase → **SQL Editor**:

```sql
alter table vendors add column if not exists payment_status text not null default 'unpaid';
update vendors set payment_status = 'paid_full' where status = 'paid_full';
update vendors set payment_status = 'deposit_paid' where status = 'paid_deposit' or (deposit_paid = true and payment_status = 'unpaid');
update vendors set status = 'booked' where status in ('paid_deposit','paid_full');
```

This adds the new column and carries your existing data over sensibly — anything
marked "Paid in full" or "Deposit paid" (via the old dropdown or the old checkbox)
keeps that payment info, with its booking Status reset to "Booked".

### One more step: RSVP deadline

Run this once in Supabase → **SQL Editor**:

```sql
alter table events add column if not exists rsvp_deadline date;
```

Set the deadline per event on the **Guests** tab — guests can change their response
right up to and including that date. After it passes, their RSVP link locks: they see
their final response but can no longer change it, so you know exactly who's coming
before offering spots to anyone on a backup list. Leave it blank and there's no
deadline — the link stays editable indefinitely.

The guest-facing RSVP page no longer asks for dietary notes or has a general notes
field, since it's buffet-style — that field's still there for your own internal use on
the **Guests** tab (now just labeled "Notes"), guests just don't see or fill it in
themselves anymore.

### One more step: vendor due dates + mood board categories

Run this once in Supabase → **SQL Editor**:

```sql
alter table vendors add column if not exists due_date date;

create table if not exists moodboard_categories (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references events(id),
  name text not null,
  created_at timestamptz not null default now()
);
alter table moodboard_categories enable row level security;
create policy "anon full access" on moodboard_categories for all using (true) with check (true);
```

**Vendors** now have a **Due** date column and a computed **Remaining** column (what's
left to pay — full price if unpaid, price minus deposit if a deposit's down, zero once
paid in full). An overdue due date turns red, same pattern as overdue tasks.

**Mood board** is now organized into categories you name yourself — "Décor," "Bride's
Dress," "Groom's Suit," whatever fits. Each category is its own tab with its own
photos; add as many as you like from the **+ New** button. Deleting a category deletes
its photos too, with a confirmation first.

**Photos are now a proper lightbox** — tap any photo to open it full-screen. Pinch to
zoom (or scroll-wheel/double-click on desktop), drag to pan while zoomed, swipe left or
right for the next/previous photo, and tap outside the image or the ✕ to close.

### Vendor documents (receipts, invoices, quotations)

No new SQL — this reuses the same storage bucket and policies the Mood Board already
set up. Each vendor row now has a **📎 Docs** button showing how many files are
attached. Tap it to open a panel scoped to just that vendor — add a deposit receipt,
invoice, or final quotation (PDF, JPG, or PNG), and it opens the exact same way as
mood board photos: real thumbnails, tap to view full-screen, zoom and swipe for
photos, rendered pages for PDFs.

### Backups (worth setting up — the free Supabase tier has none built in)

Supabase's free tier doesn't include automatic backups at all — that's a paid-tier
feature. Two things now cover that gap:

**1. Manual backup, anytime.** A **💾 Download full backup** button sits next to the
print button. Tap it and it downloads a single JSON file with everything — every
vendor, task, guest, and mood board category, for both events. Takes a few seconds,
no setup needed.

**2. Automatic daily backup.** `.github/workflows/backup.yml` in this folder runs
every night on GitHub's own servers and commits a dated snapshot straight into your
repo's `backups/` folder — genuinely automatic, no app needs to be open, and it costs
nothing (GitHub Actions is free for the usage a solo project generates). To turn it on:

1. Upload the whole `.github` folder (with `workflows/backup.yml` inside it) to your
   repo, same as the other files — GitHub should recognize it as an Actions workflow.
2. In your repo → **Settings → Secrets and variables → Actions** → add two repository
   secrets:
   - `SUPABASE_URL` — same value as in `config.js`
   - `SUPABASE_ANON_KEY` — same value as in `config.js`
3. That's it. It runs automatically every day at 03:00 UTC, and keeps the most recent
   30 daily backups (older ones are cleaned up automatically so the repo doesn't grow
   forever). You can also trigger it manually anytime from your repo's **Actions** tab
   → "Daily data backup" → **Run workflow**.

**What's not covered:** both backups capture all your structured data (vendors,
tasks, guests, categories) but not the actual mood board photos or vendor documents
themselves — those live in Supabase Storage, which doesn't disappear on its own, but
isn't duplicated anywhere else either. If you ever want those included too, say the
word and I'll extend it.

### One more step: restricted family access

Run this once in Supabase → **SQL Editor**:

```sql
alter table events add column if not exists family_editable boolean not null default false;
```

This powers the two new restricted-access PINs — see the **Bride's Family / Groom's
Family access** section below for the full setup.

### One more step: reorder vendors

Run this once in Supabase → **SQL Editor**:
```sql
alter table vendors add column if not exists sort_order integer;
```

Each vendor row now has ▲▼ buttons to move it up or down — handy for putting your most
important or most-active vendors at the top of the list.

## Shared PIN login

You and your fiancée unlock the app with one shared PIN — no separate accounts. Set it
in `config.js`:
```js
const APP_PIN = '1234';
```
Change `1234` to whatever you want. Once someone enters it correctly on a device, that
device stays unlocked (it's remembered in the browser) until someone taps **Lock** in
the top corner.

**Be clear-eyed about what this is and isn't.** This is a friendly speed bump, not real
security — `config.js` (PIN included) is downloaded to the browser like any other file
on the site, so anyone who opens dev tools and views the page source can read it. It
stops a random visitor or a phone left unlocked on a table from casually poking around;
it won't stop someone who deliberately goes looking. The real protection is what we set
up already: a private GitHub repo and an unlisted `.pages.dev` URL that only you two
have. Don't post the link anywhere public.

## Bride's Family / Groom's Family access

Two more PINs, each unlocking only **one** event — no world-switcher, no way to see the
other event at all. Set them in `config.js`:

```js
const BRIDE_FAMILY_PIN = '1111';
const BRIDE_FAMILY_EVENT = 'wedding';   // which event this PIN unlocks
const GROOM_FAMILY_PIN = '2222';
const GROOM_FAMILY_EVENT = 'homecoming'; // which event this PIN unlocks
```

Change the PINs to whatever you want, and swap the `_EVENT` lines if you want the
mapping the other way around — nothing else in the app needs to change.

**They're view-only by default.** Someone on a family PIN can browse everything in
their one event — vendors, checklist, guests, mood board — but every add/edit/delete/
upload is silently blocked, with a small message explaining why if they try. This is
enforced in the code that talks to the database, not just by hiding buttons, so it
holds even if someone pokes around in dev tools.

**You can flip it to editable, per event.** When you (the shared `APP_PIN`) are viewing
an event, a small toggle appears near the top — "Bride's Family can edit this event" /
"Groom's Family can edit this event". Switch it on and that family PIN gains full edit
access to that one event; switch it off and they're back to view-only. This is stored
in the database, so it applies immediately to anyone on that PIN, not just per-device.

**One SQL step** (also listed above) — adds the column this relies on:
```sql
alter table events add column if not exists family_editable boolean not null default false;
```

**The "who's this" picker (Nithara/Dyllon) only applies to the `APP_PIN`.** Family PINs
skip it entirely and drop straight into their event — there's no presence tracking or
name needed for a view-only guest. If you (admin) ever need to switch which of you is
using a shared device, there's a switch-profile icon top-right that takes you back to
the picker.

### Edit-history log

Every add, edit, or delete made by a family PIN (while it's switched to editable) gets
logged — who did it, when, and exactly what changed. A small clock icon appears
top-right for either of you (Nithara or Dyllon) to review it, filtered to whichever
event you're currently viewing.

One more SQL step, in Supabase → **SQL Editor**:
```sql
create table if not exists audit_log (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references events(id),
  actor text not null,
  action text not null,
  table_name text not null,
  record_label text,
  details text,
  created_at timestamptz not null default now()
);
alter table audit_log enable row level security;
create policy "anon full access" on audit_log for all using (true) with check (true);
```

Nothing you or Nithara do (as admin) gets logged here — only actions taken while on a
family PIN, since that's the access level this exists to keep an eye on.

## One-time setup (~10 minutes)

### 1. Create a Supabase project
Go to [supabase.com](https://supabase.com) → New project (free tier is plenty).

### 2. Run the schema
In your Supabase project → **SQL Editor** → New query → paste the entire contents
of `schema.sql` → **Run**. This creates the tables and seeds the two events.

### 3. Get your credentials
Project Settings → **API** → copy the **Project URL** and the **anon public** key.

### 4. Fill in `config.js`
Open `config.js` and replace the two placeholder values:
```js
const SUPABASE_URL = 'https://xxxxx.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOi...';
```
Keep `index.html` and `config.js` in the same folder — `index.html` loads `config.js`
automatically and never touches it again, so future edits to the app won't wipe your
credentials.

### 5. Host it on Cloudflare Pages (free, private, no credit limits)

This setup keeps your Supabase credentials private and never throttles you, unlike
Netlify's free tier (300 credits/month, ~20 deploys before it pauses your site).

**a. Create a private GitHub repo**
- Go to [github.com/new](https://github.com/new) → name it e.g. `wedding-planner` →
  set visibility to **Private** → Create repository.
- Upload `index.html`, `config.js` (with your real credentials filled in),
  `wrangler.jsonc`, `.assetsignore`, and `schema.sql` / `README.md` if you like —
  either via the GitHub web UI ("Add file → Upload files") or `git push` from
  Terminal if you're comfortable with git. **`.assetsignore` matters:** without it,
  Wrangler uploads your repo's `.git` folder as a public asset, which can leak commit
  history and file contents that were never meant to be served.

**b. Connect it to Cloudflare Pages**
- Go to [dash.cloudflare.com](https://dash.cloudflare.com) → sign up free → **Workers
  & Pages → Create → Connect to Git**.
- Authorize Cloudflare to access your GitHub account and select the private repo you
  just created (private repos work fine on the free plan).
- Cloudflare's current interface builds and deploys in two steps, using the included
  `wrangler.jsonc` file to know what to serve. Set:
  - **Build command:** leave blank
  - **Deploy command:** `npx wrangler deploy`
- Click **Save and Deploy**. You'll get a live URL like
  `wedding-planner-xyz.pages.dev` within a minute or two.
- Make sure `wrangler.jsonc` is in the same repo alongside `index.html`, `config.js`,
  and `schema.sql` — it's what tells Cloudflare "serve this folder as-is, no build
  step needed."

**c. Share the URL**
- Send that `.pages.dev` link to your partner/family — that's the whole app, live and
  editable by anyone who has it.
- Every time you push a change to the repo (or re-upload `index.html` via the GitHub
  web UI), Cloudflare redeploys automatically — free, unlimited, no credits to track.

**Optional: custom domain.** If you own a domain, Cloudflare Pages → your project →
Custom domains lets you point something like `ourwedding.yourdomain.com` at it, free.

## Security note

There's no per-person login — the anon key gives read/write access to anyone who has
the link. Two things protect that: (1) the GitHub repo holding `config.js` is private,
so the credentials themselves aren't publicly discoverable, and (2) the `.pages.dev`
URL is unguessable and unlisted. Don't post the URL publicly. If you want a second
layer of protection (e.g. before sharing the link more widely), a simple shared
passcode screen is a reasonable next step — see below.

## Extending it later

Some ideas if you want to keep building this out:
- A **seating chart** view once the guest list settles down.
- A **vendor payment timeline** (deposit due dates as checklist items, auto-created
  from the vendor tracker).
- **Export to PDF** for a printable day-of run sheet.
- A simple **passcode gate** (one shared password, stored in Supabase, checked before
  showing the app) if you want a light layer of privacy without full user accounts —
  just say the word and I'll add it.
