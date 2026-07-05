-- Migration to add Git & AI Code Audit columns to project_submissions
ALTER TABLE project_submissions
  ADD COLUMN IF NOT EXISTS git_audit_status TEXT DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS ai_percentage INT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS commit_count INT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS audit_anomalies TEXT[] DEFAULT '{}';

-- Enable pg_net extension for HTTP requests
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Trigger function to invoke edge function
CREATE OR REPLACE FUNCTION public.trig_analyze_repo_on_submission()
RETURNS TRIGGER AS $$
DECLARE
  anon_key TEXT;
BEGIN
  -- Fetch the anon key dynamically from the Vault
  SELECT decrypted_secret INTO anon_key 
  FROM vault.decrypted_secrets 
  WHERE name = 'anon' 
  LIMIT 1;

  -- Fallback if not found under 'anon'
  IF anon_key IS NULL THEN
    SELECT decrypted_secret INTO anon_key 
    FROM vault.decrypted_secrets 
    WHERE name = 'anon_key' 
    LIMIT 1;
  END IF;

  -- Invoke the analyze-repo edge function via HTTP POST
  PERFORM
    net.http_post(
      url := 'https://pxgurlmrtoxlmlpiyqrj.supabase.co/functions/v1/analyze-repo',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'apikey', anon_key,
        'Authorization', 'Bearer ' || anon_key
      ),
      body := jsonb_build_object(
        'record', jsonb_build_object(
          'id', NEW.id,
          'github_url', NEW.github_url
        )
      )::text
    );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Bind the trigger to run AFTER INSERT on project_submissions
DROP TRIGGER IF EXISTS tr_analyze_repo_on_submission ON project_submissions;
CREATE TRIGGER tr_analyze_repo_on_submission
  AFTER INSERT ON project_submissions
  FOR EACH ROW
  EXECUTE FUNCTION public.trig_analyze_repo_on_submission();
