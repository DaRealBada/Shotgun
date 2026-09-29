// Public Supabase settings. The anon key is safe to expose: row-level security
// in supabase/schema.sql is what protects the data.
window.SHOTGUN_CONFIG = {
  supabaseUrl: 'YOUR_SUPABASE_URL',        // e.g. https://abcd1234.supabase.co
  supabaseAnonKey: 'YOUR_SUPABASE_ANON_KEY'
};
