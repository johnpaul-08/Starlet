-- Migration: Create public.blog_post_saves table for bookmarking posts
CREATE TABLE IF NOT EXISTS public.blog_post_saves (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES public.blog_posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, post_id)
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.blog_post_saves ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow users to read own saves" ON public.blog_post_saves;
DROP POLICY IF EXISTS "Allow users to insert own saves" ON public.blog_post_saves;
DROP POLICY IF EXISTS "Allow users to delete own saves" ON public.blog_post_saves;

-- RLS Policies
CREATE POLICY "Allow users to read own saves" 
ON public.blog_post_saves FOR SELECT TO authenticated 
USING (auth.uid() = user_id);

CREATE POLICY "Allow users to insert own saves" 
ON public.blog_post_saves FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow users to delete own saves" 
ON public.blog_post_saves FOR DELETE TO authenticated 
USING (auth.uid() = user_id);
