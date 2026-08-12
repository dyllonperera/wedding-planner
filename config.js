// ============================================================
// Your Supabase credentials — fill these in ONCE.
// Find them in Supabase → Project Settings → API Keys
//
// This file is separate from index.html on purpose: any future
// version of the app stays out of this file, so you never have
// to re-enter these values again.
// ============================================================
const SUPABASE_URL = 'https://nfanlugqwempmofnpbxm.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5mYW5sdWdxd2VtcG1vZm5wYnhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU0NjU1MzcsImV4cCI6MjEwMTA0MTUzN30.B1BPhTZpQibHv_AyLz-9fAQvKPTxSkGerJemHhUHus8';

// Shared PIN — you and your fiancée both use this one to unlock the app.
// Change it any time by editing this line and redeploying.
const APP_PIN = '0512';

// Restricted family access — each PIN only unlocks ONE event (no world-switcher,
// no other event visible), and is view-only by default. You (the APP_PIN admin)
// can flip a specific event to "family can edit" from inside the app.
//
// Swap which event each role sees just by changing the two _EVENT lines below —
// nothing else needs to change.
const BRIDE_FAMILY_PIN = '1111';
const BRIDE_FAMILY_EVENT = 'wedding'; // 'wedding' or 'homecoming'
const GROOM_FAMILY_PIN = '2222';
const GROOM_FAMILY_EVENT = 'homecoming'; // 'wedding' or 'homecoming'
