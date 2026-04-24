import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  console.warn('Supabase URL or Anon Key is missing. Check your Vercel Environment Variables.')
}

// Export a dummy client if keys are missing to prevent app-wide crashes
export const supabase = (supabaseUrl && supabaseAnonKey) 
  ? createClient(supabaseUrl, supabaseAnonKey)
  : {
      auth: {
        getSession: async () => ({ data: { session: null }, error: null }),
        onAuthStateChange: () => ({ data: { subscription: { unsubscribe: () => {} } } }),
        signInWithPassword: async () => ({ error: { message: 'Supabase not configured' } }),
        signUp: async () => ({ error: { message: 'Supabase not configured' } }),
        signOut: async () => ({ error: null }),
      },
      from: () => ({
        select: () => ({
          eq: () => ({ single: async () => ({ data: null, error: null }), order: () => ({ data: [], error: null }) }),
          order: () => ({ data: [], error: null }),
          is: () => ({ data: [], error: null }),
        }),
        insert: async () => ({ error: { message: 'Supabase not configured' } }),
        update: () => ({ eq: async () => ({ error: { message: 'Supabase not configured' } }) }),
        upsert: async () => ({ error: { message: 'Supabase not configured' } }),
      }),
      storage: {
        from: () => ({
          upload: async () => ({ error: { message: 'Supabase not configured' } }),
          getPublicUrl: () => ({ data: { publicUrl: '' } }),
        }),
      },
      channel: () => ({
        on: () => ({ subscribe: () => {} }),
      }),
      removeChannel: () => {},
    };


